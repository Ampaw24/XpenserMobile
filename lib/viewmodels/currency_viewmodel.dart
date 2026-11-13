import 'package:expenser/models/exchange_rates.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrencyState {
  final String fromCurrency;
  final String toCurrency;
  final double amount;

  const CurrencyState({
    this.fromCurrency = 'USD',
    this.toCurrency = 'GHS',
    this.amount = 0.0,
  });

  /// Units of [toCurrency] per one [fromCurrency]; null if unavailable.
  double? rateFrom(ExchangeRates? rates) =>
      rates?.rate(fromCurrency, toCurrency);

  double? resultFrom(ExchangeRates? rates) {
    final rate = rateFrom(rates);
    return rate == null ? null : amount * rate;
  }

  CurrencyState copyWith({
    String? fromCurrency,
    String? toCurrency,
    double? amount,
  }) {
    return CurrencyState(
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      amount: amount ?? this.amount,
    );
  }
}

class CurrencyNotifier extends AutoDisposeNotifier<CurrencyState> {
  static const currencies = [
    'USD',
    'GHS',
    'EUR',
    'GBP',
    'JPY',
    'CAD',
    'AUD',
    'CHF',
    'CNY',
    'NGN',
    'KES',
    'ZAR',
    'INR',
    'BRL',
    'MXN',
    'SGD',
    'AED',
    'SAR',
    'EGP',
    'XOF',
  ];

  /// Currencies the given rates can convert; full list before first load.
  static List<String> supportedBy(ExchangeRates? rates) {
    if (rates == null) return currencies;
    return [
      for (final code in currencies)
        if (rates.supports(code)) code,
    ];
  }

  @override
  CurrencyState build() => const CurrencyState();

  void setFromCurrency(String currency) =>
      state = state.copyWith(fromCurrency: currency);

  void setToCurrency(String currency) =>
      state = state.copyWith(toCurrency: currency);

  void setAmount(double amount) => state = state.copyWith(amount: amount);

  void swapCurrencies() {
    state = state.copyWith(
      fromCurrency: state.toCurrency,
      toCurrency: state.fromCurrency,
    );
  }
}

final currencyProvider =
    NotifierProvider.autoDispose<CurrencyNotifier, CurrencyState>(
      CurrencyNotifier.new,
    );
