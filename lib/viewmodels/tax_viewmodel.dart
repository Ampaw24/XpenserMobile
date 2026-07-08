import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TaxCountry { ghana, usa, uk, canada, nigeria }

extension TaxCountryExt on TaxCountry {
  String get label {
    switch (this) {
      case TaxCountry.ghana:
        return 'Ghana';
      case TaxCountry.usa:
        return 'United States';
      case TaxCountry.uk:
        return 'United Kingdom';
      case TaxCountry.canada:
        return 'Canada';
      case TaxCountry.nigeria:
        return 'Nigeria';
    }
  }

  String get currency {
    switch (this) {
      case TaxCountry.ghana:
        return 'GHS';
      case TaxCountry.usa:
        return 'USD';
      case TaxCountry.uk:
        return 'GBP';
      case TaxCountry.canada:
        return 'CAD';
      case TaxCountry.nigeria:
        return 'NGN';
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
  // bracket-by-bracket breakdown for the table UI
  final List<({String label, double taxable, double rate, double tax})> breakdown;

  const TaxState({
    this.country = TaxCountry.ghana,
    this.filingStatus = 'Single',
    this.income = 0.0,
    this.taxOwed = 0.0,
    this.afterTaxIncome = 0.0,
    this.effectiveRate = 0.0,
    this.breakdown = const [],
  });

  TaxState copyWith({
    TaxCountry? country,
    String? filingStatus,
    double? income,
    double? taxOwed,
    double? afterTaxIncome,
    double? effectiveRate,
    List<({String label, double taxable, double rate, double tax})>? breakdown,
  }) {
    return TaxState(
      country: country ?? this.country,
      filingStatus: filingStatus ?? this.filingStatus,
      income: income ?? this.income,
      taxOwed: taxOwed ?? this.taxOwed,
      afterTaxIncome: afterTaxIncome ?? this.afterTaxIncome,
      effectiveRate: effectiveRate ?? this.effectiveRate,
      breakdown: breakdown ?? this.breakdown,
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
    final (tax, breakdown) = switch (state.country) {
      TaxCountry.ghana => _calcGhana(income),
      TaxCountry.usa => _calcUsa(income, state.filingStatus),
      TaxCountry.uk => _calcUk(income),
      TaxCountry.canada => _calcCanada(income),
      TaxCountry.nigeria => _calcNigeria(income),
    };
    final effective = income > 0 ? (tax / income) * 100 : 0.0;
    state = state.copyWith(
      taxOwed: tax,
      afterTaxIncome: income - tax,
      effectiveRate: effective,
      breakdown: breakdown,
    );
  }

  (double, List<({String label, double taxable, double rate, double tax})>)
      _calcGhana(double income) {
    // Ghana PAYE 2024 (annual GHS)
    const brackets = [
      (4380.0, 0.0, 'First 4,380'),
      (1320.0, 0.05, 'Next 1,320'),
      (1560.0, 0.10, 'Next 1,560'),
      (38000.0, 0.175, 'Next 38,000'),
      (192000.0, 0.25, 'Next 192,000'),
      (double.infinity, 0.30, 'Remainder'),
    ];
    return _progressive(income, brackets);
  }

  (double, List<({String label, double taxable, double rate, double tax})>)
      _calcUsa(double income, String status) {
    // US 2024 single brackets
    const single = [
      (11600.0, 0.10, '10% on first \$11,600'),
      (47150.0, 0.12, '12% on next \$35,550'),
      (100525.0, 0.22, '22% on next \$53,375'),
      (191950.0, 0.24, '24% on next \$91,425'),
      (243725.0, 0.32, '32% on next \$51,775'),
      (609350.0, 0.35, '35% on next \$365,625'),
      (double.infinity, 0.37, '37% on remainder'),
    ];
    const married = [
      (23200.0, 0.10, '10% on first \$23,200'),
      (94300.0, 0.12, '12% on next \$71,100'),
      (201050.0, 0.22, '22% on next \$106,750'),
      (383900.0, 0.24, '24% on next \$182,850'),
      (487450.0, 0.32, '32% on next \$103,550'),
      (731200.0, 0.35, '35% on next \$243,750'),
      (double.infinity, 0.37, '37% on remainder'),
    ];
    final brackets = status.startsWith('Married') ? married : single;
    return _progressive(income, brackets);
  }

  (double, List<({String label, double taxable, double rate, double tax})>)
      _calcUk(double income) {
    // UK 2024/25 (GBP)
    const personalAllowance = 12570.0;
    if (income <= personalAllowance) return (0.0, []);
    const brackets = [
      (12570.0, 0.0, 'Personal Allowance'),
      (50270.0, 0.20, '20% Basic Rate'),
      (125140.0, 0.40, '40% Higher Rate'),
      (double.infinity, 0.45, '45% Additional Rate'),
    ];
    return _progressive(income, brackets);
  }

  (double, List<({String label, double taxable, double rate, double tax})>)
      _calcCanada(double income) {
    // Canada 2024 federal (CAD)
    const brackets = [
      (55867.0, 0.15, '15% on first \$55,867'),
      (111733.0, 0.205, '20.5% on next \$55,866'),
      (154906.0, 0.26, '26% on next \$43,173'),
      (220000.0, 0.29, '29% on next \$65,094'),
      (double.infinity, 0.33, '33% on remainder'),
    ];
    return _progressive(income, brackets);
  }

  (double, List<({String label, double taxable, double rate, double tax})>)
      _calcNigeria(double income) {
    // Nigeria PAYE 2024 (annual NGN)
    const brackets = [
      (300000.0, 0.07, '7% on first ₦300,000'),
      (600000.0, 0.11, '11% on next ₦300,000'),
      (1100000.0, 0.15, '15% on next ₦500,000'),
      (1600000.0, 0.19, '19% on next ₦500,000'),
      (3200000.0, 0.21, '21% on next ₦1,600,000'),
      (double.infinity, 0.24, '24% on remainder'),
    ];
    return _progressive(income, brackets);
  }

  (double, List<({String label, double taxable, double rate, double tax})>)
      _progressive(
    double income,
    List<(double, double, String)> brackets,
  ) {
    double tax = 0.0;
    double prev = 0.0;
    final breakdown =
        <({String label, double taxable, double rate, double tax})>[];
    for (final (limit, rate, label) in brackets) {
      if (income <= prev) break;
      final taxable = (income < limit ? income : limit) - prev;
      final bracketTax = taxable * rate;
      tax += bracketTax;
      if (taxable > 0) {
        breakdown.add((
          label: label,
          taxable: taxable,
          rate: rate,
          tax: bracketTax,
        ));
      }
      prev = limit;
      if (limit == double.infinity) break;
    }
    return (tax, breakdown);
  }
}

final taxProvider = NotifierProvider<TaxNotifier, TaxState>(TaxNotifier.new);
