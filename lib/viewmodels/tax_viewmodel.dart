import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TaxCountry { ghana, usa, uk, canada }

extension TaxCountryExt on TaxCountry {
  String get label {
    switch (this) {
      case TaxCountry.ghana: return 'Ghana';
      case TaxCountry.usa: return 'United States';
      case TaxCountry.uk: return 'United Kingdom';
      case TaxCountry.canada: return 'Canada';
    }
  }

  String get currency {
    switch (this) {
      case TaxCountry.ghana: return 'GHS';
      case TaxCountry.usa: return 'USD';
      case TaxCountry.uk: return 'GBP';
      case TaxCountry.canada: return 'CAD';
    }
  }
}

class TaxState {
  final TaxCountry country;
  final String filingStatus;
  final double income;
  final double taxOwed;
  final double afterTaxIncome;
  final double effectiveRate;

  const TaxState({
    this.country = TaxCountry.ghana,
    this.filingStatus = 'Single',
    this.income = 0.0,
    this.taxOwed = 0.0,
    this.afterTaxIncome = 0.0,
    this.effectiveRate = 0.0,
  });

  TaxState copyWith({
    TaxCountry? country,
    String? filingStatus,
    double? income,
    double? taxOwed,
    double? afterTaxIncome,
    double? effectiveRate,
  }) {
    return TaxState(
      country: country ?? this.country,
      filingStatus: filingStatus ?? this.filingStatus,
      income: income ?? this.income,
      taxOwed: taxOwed ?? this.taxOwed,
      afterTaxIncome: afterTaxIncome ?? this.afterTaxIncome,
      effectiveRate: effectiveRate ?? this.effectiveRate,
    );
  }
}

class TaxNotifier extends Notifier<TaxState> {
  @override
  TaxState build() => const TaxState();

  void setCountry(TaxCountry country) {
    state = state.copyWith(country: country, filingStatus: 'Single');
    _recalculate(state.income);
  }

  void setFilingStatus(String status) {
    state = state.copyWith(filingStatus: status);
    _recalculate(state.income);
  }

  void calculate(double income) {
    state = state.copyWith(income: income);
    _recalculate(income);
  }

  void _recalculate(double income) {
    final tax = switch (state.country) {
      TaxCountry.ghana => _calcGhana(income),
      TaxCountry.usa => _calcUsa(income, state.filingStatus),
      TaxCountry.uk => _calcUk(income),
      TaxCountry.canada => _calcCanada(income),
    };
    final effective = income > 0 ? (tax / income) * 100 : 0.0;
    state = state.copyWith(
      taxOwed: tax,
      afterTaxIncome: income - tax,
      effectiveRate: effective,
    );
  }

  double _calcGhana(double income) {
    // Ghana PAYE 2024 (annual GHS)
    const brackets = [
      (4380.0, 0.0),
      (1320.0, 0.05),
      (1560.0, 0.10),
      (38000.0, 0.175),
      (192000.0, 0.25),
      (double.infinity, 0.30),
    ];
    return _progressive(income, brackets);
  }

  double _calcUsa(double income, String status) {
    // US 2024 single brackets
    const single = [
      (11600.0, 0.10),
      (47150.0, 0.12),
      (100525.0, 0.22),
      (191950.0, 0.24),
      (243725.0, 0.32),
      (609350.0, 0.35),
      (double.infinity, 0.37),
    ];
    const married = [
      (23200.0, 0.10),
      (94300.0, 0.12),
      (201050.0, 0.22),
      (383900.0, 0.24),
      (487450.0, 0.32),
      (731200.0, 0.35),
      (double.infinity, 0.37),
    ];
    final brackets = status.startsWith('Married') ? married : single;
    return _progressive(income, brackets);
  }

  double _calcUk(double income) {
    // UK 2024/25 (GBP)
    const personalAllowance = 12570.0;
    if (income <= personalAllowance) return 0.0;
    const brackets = [
      (12570.0, 0.0),
      (50270.0, 0.20),
      (125140.0, 0.40),
      (double.infinity, 0.45),
    ];
    return _progressive(income, brackets);
  }

  double _calcCanada(double income) {
    // Canada 2024 federal (CAD)
    const brackets = [
      (55867.0, 0.15),
      (111733.0, 0.205),
      (154906.0, 0.26),
      (220000.0, 0.29),
      (double.infinity, 0.33),
    ];
    return _progressive(income, brackets);
  }

  double _progressive(double income, List<(double, double)> brackets) {
    double tax = 0.0;
    double prev = 0.0;
    for (final (limit, rate) in brackets) {
      if (income <= prev) break;
      final taxable = (income < limit ? income : limit) - prev;
      tax += taxable * rate;
      prev = limit;
      if (limit == double.infinity) break;
    }
    return tax;
  }
}

final taxProvider =
    NotifierProvider<TaxNotifier, TaxState>(TaxNotifier.new);
