import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrencyState {
  final String fromCurrency;
  final String toCurrency;
  final double amount;
  final double result;

  const CurrencyState({
    this.fromCurrency = 'USD',
    this.toCurrency = 'GHS',
    this.amount = 0.0,
    this.result = 0.0,
  });

  CurrencyState copyWith({
    String? fromCurrency,
    String? toCurrency,
    double? amount,
    double? result,
  }) {
    return CurrencyState(
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      amount: amount ?? this.amount,
      result: result ?? this.result,
    );
  }
}

class CurrencyNotifier extends Notifier<CurrencyState> {
  // Approximate rates relative to USD
  static const _usdRates = <String, double>{
    'USD': 1.0,
    'GHS': 15.20,
    'EUR': 0.92,
    'GBP': 0.79,
    'JPY': 149.50,
    'CAD': 1.36,
    'AUD': 1.53,
    'CHF': 0.90,
    'CNY': 7.24,
    'NGN': 1550.0,
    'KES': 129.0,
    'ZAR': 18.60,
    'INR': 83.10,
    'BRL': 4.97,
    'MXN': 17.15,
    'SGD': 1.34,
    'AED': 3.67,
    'SAR': 3.75,
    'EGP': 30.90,
    'XOF': 602.0,
  };

  static const currencies = [
    'USD', 'GHS', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD',
    'CHF', 'CNY', 'NGN', 'KES', 'ZAR', 'INR', 'BRL',
    'MXN', 'SGD', 'AED', 'SAR', 'EGP', 'XOF',
  ];

  @override
  CurrencyState build() => const CurrencyState();

  void setFromCurrency(String currency) {
    state = state.copyWith(fromCurrency: currency);
    _recalculate();
  }

  void setToCurrency(String currency) {
    state = state.copyWith(toCurrency: currency);
    _recalculate();
  }

  void setAmount(double amount) {
    state = state.copyWith(amount: amount);
    _recalculate();
  }

  void swapCurrencies() {
    state = state.copyWith(
      fromCurrency: state.toCurrency,
      toCurrency: state.fromCurrency,
    );
    _recalculate();
  }

  void convert(double amount) {
    state = state.copyWith(amount: amount);
    _recalculate();
  }

  void _recalculate() {
    if (state.fromCurrency == state.toCurrency) {
      state = state.copyWith(result: state.amount);
      return;
    }
    final fromRate = _usdRates[state.fromCurrency] ?? 1.0;
    final toRate = _usdRates[state.toCurrency] ?? 1.0;
    final inUsd = state.amount / fromRate;
    state = state.copyWith(result: inUsd * toRate);
  }
}

final currencyProvider =
    NotifierProvider<CurrencyNotifier, CurrencyState>(CurrencyNotifier.new);
