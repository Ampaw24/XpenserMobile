import 'package:expenser/models/budget_model.dart';
import 'package:expenser/models/budget_period.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BudgetDateRange.forPeriod', () {
    test('monthly covers the whole anchor month', () {
      final r = BudgetDateRange.forPeriod(
        BudgetPeriodType.monthly,
        DateTime(2026, 2, 17, 15),
      );
      expect(r.start, DateTime(2026, 2, 1));
      expect(r.end, DateTime(2026, 2, 28));
      expect(r.lengthInDays, 28);
    });

    test('quarterly and annual span whole months across a year boundary', () {
      final q = BudgetDateRange.forPeriod(
        BudgetPeriodType.quarterly,
        DateTime(2026, 11, 13),
      );
      expect(q.start, DateTime(2026, 11, 1));
      expect(q.end, DateTime(2027, 1, 31));

      final a = BudgetDateRange.forPeriod(
        BudgetPeriodType.annual,
        DateTime(2026, 11, 13),
      );
      expect(a.end, DateTime(2027, 10, 31));
    });
  });

  group('BudgetDateRange', () {
    final range = BudgetDateRange(
      DateTime(2026, 11, 1),
      DateTime(2026, 11, 30),
    );

    test('includes the whole last day and nothing after it', () {
      expect(range.contains(DateTime(2026, 11, 1)), isTrue);
      expect(range.contains(DateTime(2026, 11, 30, 23, 59, 59)), isTrue);
      expect(range.contains(DateTime(2026, 12, 1)), isFalse);
      expect(range.contains(DateTime(2026, 10, 31, 23, 59)), isFalse);
    });

    test('reports status and days left', () {
      expect(range.statusAt(DateTime(2026, 10, 31)), BudgetStatus.upcoming);
      expect(range.statusAt(DateTime(2026, 11, 13, 9)), BudgetStatus.active);
      expect(range.statusAt(DateTime(2026, 12, 1)), BudgetStatus.ended);
      expect(range.daysLeftAt(DateTime(2026, 11, 13, 9)), 18);
      expect(range.daysLeftAt(DateTime(2026, 11, 30, 22)), 1);
      expect(range.daysLeftAt(DateTime(2026, 12, 2)), 0);
    });

    test('rejects an end date before the start', () {
      expect(
        BudgetDateRange(DateTime(2026, 5, 2), DateTime(2026, 5, 1)).isValid,
        isFalse,
      );
    });

    test('renewing a fixed period moves to the period containing today', () {
      final renewed = range.renewedFor(
        BudgetPeriodType.monthly,
        DateTime(2027, 2, 9),
      );
      expect(renewed.start, DateTime(2027, 2, 1));
      expect(renewed.end, DateTime(2027, 2, 28));
    });

    test('renewing a custom range keeps its length and starts today', () {
      final custom = BudgetDateRange(
        DateTime(2026, 3, 1),
        DateTime(2026, 3, 14),
      );
      final renewed = custom.renewedFor(
        BudgetPeriodType.custom,
        DateTime(2026, 4, 20, 18),
      );
      expect(renewed.start, DateTime(2026, 4, 20));
      expect(renewed.lengthInDays, 14);
    });
  });

  group('BudgetModel.dateRange', () {
    BudgetModel budget({String? period, DateTime? start, DateTime? end}) =>
        BudgetModel(
          id: 'b',
          categoryId: 'c',
          limitAmount: 100,
          month: 9,
          year: 2026,
          createdAt: DateTime(2026, 9, 5),
          period: period,
          startDate: start,
          endDate: end,
        );

    test('uses saved dates when present', () {
      final b = budget(
        period: 'custom',
        start: DateTime(2026, 9, 10),
        end: DateTime(2026, 10, 9),
      );
      expect(b.dateRange.start, DateTime(2026, 9, 10));
      expect(b.dateRange.end, DateTime(2026, 10, 9));
    });

    test('older budgets without dates use their period from their month', () {
      final quarterly = budget(period: 'quarterly');
      expect(quarterly.dateRange.start, DateTime(2026, 9, 1));
      expect(quarterly.dateRange.end, DateTime(2026, 11, 30));

      final legacyMonthly = budget();
      expect(legacyMonthly.dateRange.end, DateTime(2026, 9, 30));
    });
  });
}
