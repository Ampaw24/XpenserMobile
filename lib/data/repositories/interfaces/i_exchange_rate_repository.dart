import 'package:expenser/models/exchange_rates.dart';

/// Rates plus whether they came from an expired cache after a failed refresh.
typedef ExchangeRatesResult = ({ExchangeRates rates, bool isStale});

abstract class IExchangeRateRepository {
  /// Returns fresh cached rates when within TTL, otherwise fetches.
  /// Falls back to stale cache on failure; throws if no cache exists.
  /// [forceRefresh] bypasses the TTL (still throttled to avoid wasted calls).
  Future<ExchangeRatesResult> getRates({bool forceRefresh = false});

  /// Last cached rates, if any, without touching the network.
  ExchangeRates? cachedRates();
}
