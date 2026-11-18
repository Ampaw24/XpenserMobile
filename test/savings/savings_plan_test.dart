import 'package:expenser/models/category_model.dart';
import 'package:expenser/models/recurring_frequency.dart';
import 'package:expenser/models/savings_affordability.dart';
import 'package:expenser/models/savings_plan.dart';
import 'package:expenser/models/transaction_model.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:flutter_test/flutter_test.dart';

// Wednesday 18 Nov 2026, 10:00.
final _now = DateTime(2026, 11, 18, 10);
final _newYearsEve = DateTime(2026, 12, 31);

SavingsPlan? _plan(
  RecurringFrequency frequency, {
  double target = 200,
  double saved = 0,
  DateTime? targetDate,
  DateTime? startAt,
  bool paidThisPeriod = false,
}) => savingsPlan(
  frequency: frequency,
  targetAmount: target,
  savedAmount: saved,
  targetDate: targetDate ?? _newYearsEve,
  now: _now,
  startAt: startAt,
  paidThisPeriod: paidThisPeriod,
);

TransactionModel _tx(
  TransactionType type,
  double amount,
  DateTime date, {
  String accountId = 'ghs',
  String categoryId = 'food',
}) => TransactionModel(
  id: '$type-$amount-$date',
  amount: amount,
  type: type,
  categoryId: categoryId,
  accountId: accountId,
  date: date,
  createdAt: date,
);

void main() {
  group('savingsPlan', () {
    test('GHS 200 daily by 31 Dec from 18 Nov is 44 payments of 4.55', () {
      final plan = _plan(RecurringFrequency.daily)!;
      expect(plan.payments, 44); // 13 days left in Nov + 31 in Dec
      expect(plan.perPayment, 4.55); // 200 / 44 = 4.545… rounded up
      expect(plan.perPayment * plan.payments, greaterThanOrEqualTo(200));
    });

    test('weekly and monthly count Monday weeks and calendar months', () {
      // Weeks starting 16, 23, 30 Nov and 7, 14, 21, 28 Dec.
      expect(_plan(RecurringFrequency.weekly)!.payments, 7);
      expect(_plan(RecurringFrequency.monthly)!.payments, 2);
      expect(_plan(RecurringFrequency.monthly)!.perPayment, 100);
    });

    test('only plans for what is left to save', () {
      final plan = _plan(RecurringFrequency.monthly, saved: 50)!;
      expect(plan.remaining, 150);
      expect(plan.perPayment, 75);
    });

    test('skips the current period once it is paid', () {
      expect(
        _plan(RecurringFrequency.daily, paidThisPeriod: true)!.payments,
        43,
      );
    });

    test('starts counting from a later first payment date', () {
      expect(
        _plan(
          RecurringFrequency.daily,
          startAt: DateTime(2026, 12, 1, 9),
        )!.payments,
        31,
      );
    });

    test('is null once the target is reached or the date has passed', () {
      expect(_plan(RecurringFrequency.daily, saved: 200), isNull);
      expect(
        _plan(RecurringFrequency.daily, targetDate: DateTime(2026, 11, 17)),
        isNull,
      );
    });

    test('rounds up to the cent without overshooting exact amounts', () {
      expect(roundUpToCents(5.0), 5.0);
      expect(roundUpToCents(4.541), 4.55);
    });
  });

  group('averageMonthlySurplus', () {
    final accounts = {'ghs': 'GHS', 'usd': 'USD'};

    test('averages complete months and ignores savings and transfers', () {
      final transactions = [
        _tx(TransactionType.income, 1000, DateTime(2026, 9, 5)),
        _tx(TransactionType.expense, 600, DateTime(2026, 9, 10)),
        _tx(TransactionType.income, 1000, DateTime(2026, 10, 5)),
        _tx(TransactionType.expense, 800, DateTime(2026, 10, 10)),
        // Ignored: savings contribution, transfer, other currency, this month.
        _tx(
          TransactionType.expense,
          300,
          DateTime(2026, 10, 12),
          categoryId: CategoryModel.savingsId,
        ),
        _tx(TransactionType.transfer, 500, DateTime(2026, 10, 15)),
        _tx(
          TransactionType.income,
          9000,
          DateTime(2026, 10, 1),
          accountId: 'usd',
        ),
        _tx(TransactionType.expense, 999, DateTime(2026, 11, 2)),
      ];
      expect(
        averageMonthlySurplus(
          transactions: transactions,
          accountCurrencies: accounts,
          currency: 'GHS',
          now: _now,
        ),
        300, // (400 + 200) / 2 months with data
      );
    });

    test('is null without any recorded income', () {
      expect(
        averageMonthlySurplus(
          transactions: [
            _tx(TransactionType.expense, 100, DateTime(2026, 10, 10)),
          ],
          accountCurrencies: accounts,
          currency: 'GHS',
          now: _now,
        ),
        isNull,
      );
    });
  });

  group('assessSavingsPlan', () {
    // GHS 200 monthly over 2 months = 100/month.
    final plan = _plan(RecurringFrequency.monthly)!;

    test('fits when the monthly need is within capacity', () {
      expect(assessSavingsPlan(plan, 150, _now).fit, SavingsFit.fits);
    });

    test('flags a stretch and suggests when it could be reached', () {
      final result = assessSavingsPlan(plan, 50, _now);
      expect(result.fit, SavingsFit.exceeds);
      expect(result.suggestedTargetDate, DateTime(2027, 3, 18));
    });

    test('gives no suggestion when nothing is left over', () {
      final result = assessSavingsPlan(plan, -20, _now);
      expect(result.fit, SavingsFit.exceeds);
      expect(result.suggestedTargetDate, isNull);
    });

    test('is unknown without enough history', () {
      expect(assessSavingsPlan(plan, null, _now).fit, SavingsFit.unknown);
    });
  });

  test('monthly equivalents scale daily and weekly amounts', () {
    expect(
      monthlySavingsEquivalent(RecurringFrequency.daily, 10),
      closeTo(304.375, 0.001),
    );
    expect(
      monthlySavingsEquivalent(RecurringFrequency.weekly, 70),
      closeTo(304.375, 0.001),
    );
    expect(monthlySavingsEquivalent(RecurringFrequency.monthly, 70), 70);
  });
}
