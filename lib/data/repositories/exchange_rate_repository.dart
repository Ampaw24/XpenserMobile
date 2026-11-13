import 'dart:convert';

import 'package:expenser/core/config/fastforex_config.dart';
import 'package:expenser/data/datasources/hive_service.dart';
import 'package:expenser/data/repositories/interfaces/i_exchange_rate_repository.dart';
import 'package:expenser/models/exchange_rates.dart';
import 'package:expenser/services/currency/currency_api_exception.dart';
import 'package:expenser/services/currency/fastforex_api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ExchangeRateRepository implements IExchangeRateRepository {
  ExchangeRateRepository({
    required FastForexApiClient client,
    required Box<String> cacheBox,
    String base = FastForexConfig.rateBase,
    Duration ttl = FastForexConfig.cacheTtl,
    Duration minRefreshInterval = FastForexConfig.minRefreshInterval,
    DateTime Function() clock = DateTime.now,
  }) : _client = client,
       _box = cacheBox,
       _base = base,
       _ttl = ttl,
       _minRefreshInterval = minRefreshInterval,
       _clock = clock;

  final FastForexApiClient _client;
  final Box<String> _box;
  final String _base;
  final Duration _ttl;
  final Duration _minRefreshInterval;
  final DateTime Function() _clock;

  /// Shares one network call between concurrent callers.
  Future<ExchangeRates>? _inFlight;

  String get _cacheKey => 'rates_$_base';

  @override
  ExchangeRates? cachedRates() {
    final raw = _box.get(_cacheKey);
    if (raw == null) return null;
    try {
      return ExchangeRates.fromCacheJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (error) {
      debugPrint('Discarding unreadable exchange-rate cache: $error');
      _box.delete(_cacheKey);
      return null;
    }
  }

  @override
  Future<ExchangeRatesResult> getRates({bool forceRefresh = false}) async {
    final cached = cachedRates();
    if (cached != null && _isReusable(cached, forceRefresh)) {
      return (rates: cached, isStale: false);
    }
    try {
      return (rates: await _fetchAndCache(), isStale: false);
    } on CurrencyApiException catch (error) {
      debugPrint('Exchange-rate refresh failed: $error');
      if (cached != null) return (rates: cached, isStale: true);
      rethrow;
    }
  }

  bool _isReusable(ExchangeRates cached, bool forceRefresh) {
    final age = _clock().toUtc().difference(cached.fetchedAt);
    if (age.isNegative) return false;
    return age < (forceRefresh ? _minRefreshInterval : _ttl);
  }

  Future<ExchangeRates> _fetchAndCache() {
    return _inFlight ??= () async {
      try {
        final rates = await _client.fetchAll(base: _base);
        await _box.put(_cacheKey, jsonEncode(rates.toCacheJson()));
        return rates;
      } finally {
        _inFlight = null;
      }
    }();
  }
}

final exchangeRateRepositoryProvider = Provider<IExchangeRateRepository>(
  (ref) => ExchangeRateRepository(
    client: ref.watch(fastForexApiClientProvider),
    cacheBox: HiveService.box<String>(HiveService.exchangeRates),
  ),
);
