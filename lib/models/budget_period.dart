/// How long a budget runs. Fixed periods start on the 1st of a month and span
/// [months] whole calendar months; [custom] uses user-picked dates.
enum BudgetPeriodType {
  monthly('Monthly', 'monthly', 1),
  quarterly('Quarterly', 'quarterly', 3),
  semiAnnual('Semi-Annual', 'semi_annual', 6),
  annual('Annual', 'annual', 12),
  custom('Custom', 'custom', null);

  const BudgetPeriodType(this.label, this.value, this.months);

  final String label;

  /// Persisted value (see `BudgetModel.period`).
  final String value;
  final int? months;

  static BudgetPeriodType fromValue(String? value) => values.firstWhere(
    (p) => p.value == value,
    orElse: () => BudgetPeriodType.monthly,
  );
}

/// [closed] means the user stopped the budget before its end date.
enum BudgetStatus { upcoming, active, ended, closed }

/// Inclusive range of whole local calendar days a budget covers.
class BudgetDateRange {
  BudgetDateRange(DateTime start, DateTime end)
    : start = _dateOnly(start),
      end = _dateOnly(end);

  /// Fixed-period range beginning on the 1st of [anchor]'s month.
  factory BudgetDateRange.forPeriod(BudgetPeriodType period, DateTime anchor) {
    final months = period.months ?? 1;
    return BudgetDateRange(
      DateTime(anchor.year, anchor.month),
      DateTime(anchor.year, anchor.month + months, 0),
    );
  }

  final DateTime start;
  final DateTime end;

  /// Midnight after [end]; transactions must be strictly before this.
  DateTime get endExclusive => DateTime(end.year, end.month, end.day + 1);

  /// Calendar days covered, independent of daylight-saving shifts.
  int get lengthInDays =>
      DateTime.utc(
        endExclusive.year,
        endExclusive.month,
        endExclusive.day,
      ).difference(DateTime.utc(start.year, start.month, start.day)).inDays;

  bool get isValid => !end.isBefore(start);

  bool contains(DateTime moment) =>
      !moment.isBefore(start) && moment.isBefore(endExclusive);

  BudgetStatus statusAt(DateTime moment) {
    if (moment.isBefore(start)) return BudgetStatus.upcoming;
    if (moment.isBefore(endExclusive)) return BudgetStatus.active;
    return BudgetStatus.ended;
  }

  /// Days left including today; 0 once ended.
  int daysLeftAt(DateTime moment) {
    final today = _dateOnly(moment);
    if (today.isAfter(end)) return 0;
    final from = today.isBefore(start) ? start : today;
    return BudgetDateRange(from, end).lengthInDays;
  }

  /// The period that contains [today], for renewing an ended budget. A fixed
  /// period closed early renews into the period after this one instead.
  BudgetDateRange renewedFor(BudgetPeriodType period, DateTime today) {
    if (period != BudgetPeriodType.custom) {
      final current = BudgetDateRange.forPeriod(period, today);
      if (!current.start.isAfter(end)) {
        return BudgetDateRange.forPeriod(period, endExclusive);
      }
      return current;
    }
    final from = _dateOnly(today);
    return BudgetDateRange(
      from,
      DateTime(from.year, from.month, from.day + lengthInDays - 1),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BudgetDateRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
