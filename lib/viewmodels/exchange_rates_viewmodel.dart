import 'package:expenser/data/repositories/exchange_rate_repository.dart';
import 'package:expenser/data/repositories/interfaces/i_exchange_rate_repository.dart';
import 'package:expenser/models/exchange_rates.dart';
import 'package:expenser/services/currency/currency_api_exception.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RatesStatus { loading, ready, failure }

class ExchangeRatesState {
  final RatesStatus status;
  final ExchangeRates? rates;

  /// Rates come from an expired cache because the last refresh failed.
  final bool isStale;
  final bool isRefreshing;
  final String? errorMessage;

  const ExchangeRatesState({
    this.status = RatesStatus.loading,
    this.rates,
    this.isStale = false,
    this.isRefreshing = false,
    this.errorMessage,
  });

  ExchangeRatesState copyWith({
    RatesStatus? status,
    ExchangeRates? rates,
    bool? isStale,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ExchangeRatesState(
      status: status ?? this.status,
      rates: rates ?? this.rates,
      isStale: isStale ?? this.isStale,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

/// App-wide exchange rates: serves the cache instantly, refreshes on first
/// use and on app resume. Network is hit only when the cache TTL expired.
class ExchangeRatesNotifier extends Notifier<ExchangeRatesState> {
  late IExchangeRateRepository _repository;

  @override
  ExchangeRatesState build() {
    _repository = ref.watch(exchangeRateRepositoryProvider);
    final lifecycle = AppLifecycleListener(onResume: ensureFresh);
    ref.onDispose(lifecycle.dispose);

    final cached = _repository.cachedRates();
    Future.microtask(ensureFresh);
    return ExchangeRatesState(
      status: cached == null ? RatesStatus.loading : RatesStatus.ready,
      rates: cached,
    );
  }

  /// Fetches only if the cache is older than its TTL.
  Future<void> ensureFresh() => _load();

  /// User-initiated refresh; throttled by the repository.
  Future<void> refresh() => _load(forceRefresh: true);

  Future<void> retry() {
    state = state.copyWith(status: RatesStatus.loading, clearError: true);
    return _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    if (state.isRefreshing) return;
    if (state.rates != null) state = state.copyWith(isRefreshing: true);
    try {
      final result = await _repository.getRates(forceRefresh: forceRefresh);
      state = state.copyWith(
        status: RatesStatus.ready,
        rates: result.rates,
        isStale: result.isStale,
        isRefreshing: false,
        clearError: true,
      );
    } on CurrencyApiException catch (error) {
      final hasRates = state.rates != null;
      state = state.copyWith(
        status: hasRates ? RatesStatus.ready : RatesStatus.failure,
        isStale: hasRates,
        isRefreshing: false,
        errorMessage: error.userMessage,
      );
    }
  }
}

final exchangeRatesProvider =
    NotifierProvider<ExchangeRatesNotifier, ExchangeRatesState>(
      ExchangeRatesNotifier.new,
    );
