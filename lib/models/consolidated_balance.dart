import 'package:expenser/models/account_model.dart';
import 'package:expenser/models/exchange_rates.dart';

/// Sum of all account balances expressed in one display currency.
///
/// Converted figures use indicative mid-market rates and are estimates.
class ConsolidatedBalance {
  const ConsolidatedBalance({
    required this.currency,
    required this.total,
    this.convertedCurrencies = const {},
    this.unconverted = const {},
    this.ratesUpdatedAt,
    this.ratesStale = false,
  });

  final String currency;

  /// Total in [currency], excluding [unconverted] balances.
  final double total;

  /// Foreign currencies that were converted into [currency].
  final Set<String> convertedCurrencies;

  /// Native totals per currency that had no rate and are excluded.
  final Map<String, double> unconverted;

  final DateTime? ratesUpdatedAt;
  final bool ratesStale;

  bool get isEstimate => convertedCurrencies.isNotEmpty;
  bool get isPartial => unconverted.isNotEmpty;

  factory ConsolidatedBalance.compute({
    required List<AccountModel> accounts,
    required Map<String, double> balances,
    required String currency,
    ExchangeRates? rates,
    bool ratesStale = false,
  }) {
    // Sum per currency first so each currency is converted exactly once.
    final perCurrency = <String, double>{};
    for (final account in accounts) {
      final balance = balances[account.id] ?? account.initialBalance;
      perCurrency.update(
        account.currencyCode,
        (sum) => sum + balance,
        ifAbsent: () => balance,
      );
    }

    var total = 0.0;
    final converted = <String>{};
    final unconverted = <String, double>{};
    perCurrency.forEach((code, amount) {
      if (code == currency) {
        total += amount;
        return;
      }
      final rate = rates?.rate(code, currency);
      if (rate == null) {
        unconverted[code] = amount;
      } else {
        total += amount * rate;
        converted.add(code);
      }
    });

    return ConsolidatedBalance(
      currency: currency,
      total: total,
      convertedCurrencies: converted,
      unconverted: unconverted,
      ratesUpdatedAt: converted.isEmpty ? null : rates?.updatedAt,
      ratesStale: converted.isNotEmpty && ratesStale,
    );
  }
}
