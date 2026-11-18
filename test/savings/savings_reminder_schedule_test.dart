import 'package:expenser/models/recurring_frequency.dart';
import 'package:expenser/models/savings_goal_model.dart';
import 'package:expenser/models/savings_reminder_schedule.dart';
import 'package:expenser/services/notification/savings_reminder_service.dart';
import 'package:flutter_test/flutter_test.dart';

SavingsGoalModel _goal({
  RecurringFrequency? frequency = RecurringFrequency.weekly,
  DateTime? reminderAt,
  DateTime? lastContributionAt,
  double? contributionAmount,
}) => SavingsGoalModel(
  id: 'goal-1',
  name: 'Laptop',
  targetAmount: 1000,
  savedAmount: 100,
  targetDate: DateTime(2027),
  colorHex: 'FF4CAF50',
  iconCodePoint: 1,
  createdAt: DateTime(2026),
  contributionAmount: contributionAmount,
  savingsFrequency: frequency,
  // Monday 2 Nov 2026, 9:00.
  reminderAt: reminderAt ?? DateTime(2026, 11, 2, 9),
  lastContributionAt: lastContributionAt,
);

void main() {
  // Wednesday 18 Nov 2026, 10:00.
  final now = DateTime(2026, 11, 18, 10);

  group('nextReminderAfter', () {
    final anchor = DateTime(2026, 11, 2, 9); // Monday 9:00

    test('daily rolls to tomorrow once today\'s time has passed', () {
      expect(
        nextReminderAfter(RecurringFrequency.daily, anchor, now),
        DateTime(2026, 11, 19, 9),
      );
      expect(
        nextReminderAfter(
          RecurringFrequency.daily,
          anchor,
          DateTime(2026, 11, 18, 8),
        ),
        DateTime(2026, 11, 18, 9),
      );
    });

    test('weekly repeats on the anchor weekday', () {
      expect(
        nextReminderAfter(RecurringFrequency.weekly, anchor, now),
        DateTime(2026, 11, 23, 9),
      );
    });

    test('monthly repeats on the anchor day and rolls over the year', () {
      expect(
        nextReminderAfter(
          RecurringFrequency.monthly,
          anchor,
          DateTime(2026, 12, 5),
        ),
        DateTime(2027, 1, 2, 9),
      );
    });

    test('monthly caps late days at the 28th', () {
      expect(
        nextReminderAfter(
          RecurringFrequency.monthly,
          DateTime(2026, 1, 31, 9),
          DateTime(2027, 2, 1),
        ),
        DateTime(2027, 2, 28, 9),
      );
    });
  });

  group('isSameSavingsPeriod', () {
    test('weeks start on Monday', () {
      final sunday = DateTime(2026, 11, 22, 23);
      final monday = DateTime(2026, 11, 23, 1);
      expect(
        isSameSavingsPeriod(RecurringFrequency.weekly, now, sunday),
        isTrue,
      );
      expect(
        isSameSavingsPeriod(RecurringFrequency.weekly, now, monday),
        isFalse,
      );
    });

    test('daily and monthly compare calendar days and months', () {
      expect(
        isSameSavingsPeriod(
          RecurringFrequency.daily,
          now,
          DateTime(2026, 11, 18, 23, 59),
        ),
        isTrue,
      );
      expect(
        isSameSavingsPeriod(
          RecurringFrequency.monthly,
          now,
          DateTime(2026, 12, 1),
        ),
        isFalse,
      );
    });
  });

  group('nextReminderFor', () {
    test('uses the next slot when nothing was added this period', () {
      expect(nextReminderFor(_goal(), now), DateTime(2026, 11, 23, 9));
    });

    test('skips the current period once money was added in it', () {
      final goal = _goal(
        frequency: RecurringFrequency.daily,
        lastContributionAt: DateTime(2026, 11, 18, 7),
      );
      expect(
        nextReminderFor(goal, DateTime(2026, 11, 18, 8)),
        DateTime(2026, 11, 19, 9),
      );
    });

    test('never fires before the chosen start date', () {
      final goal = _goal(
        frequency: RecurringFrequency.daily,
        reminderAt: DateTime(2026, 12, 1, 18),
      );
      expect(nextReminderFor(goal, now), DateTime(2026, 12, 1, 18));
    });
  });

  test('contributedThisPeriod needs both a schedule and a contribution', () {
    expect(_goal().contributedThisPeriod(now), isFalse);
    expect(
      _goal(
        lastContributionAt: DateTime(2026, 11, 16),
      ).contributedThisPeriod(now),
      isTrue,
    );
    expect(
      _goal(
        frequency: null,
        lastContributionAt: now,
      ).contributedThisPeriod(now),
      isFalse,
    );
  });

  test('reminder ids are stable, non-negative and distinct per goal', () {
    expect(savingsReminderId('goal-1'), savingsReminderId('goal-1'));
    expect(savingsReminderId('goal-1'), isNot(savingsReminderId('goal-2')));
    expect(savingsReminderId('goal-1'), greaterThanOrEqualTo(0));
  });

  test('goal plan fields round-trip through the sync map', () {
    final goal = _goal(
      contributionAmount: 50,
      lastContributionAt: DateTime(2026, 11, 16, 12),
    );
    final restored = SavingsGoalModel.fromMap(goal.toMap());
    expect(restored.contributionAmount, 50);
    expect(restored.savingsFrequency, RecurringFrequency.weekly);
    expect(restored.reminderAt, goal.reminderAt);
    expect(restored.lastContributionAt, goal.lastContributionAt);
  });

  test('goals synced before this change still load', () {
    final legacy =
        _goal().toMap()
          ..remove('savingsFrequency')
          ..remove('reminderAt');
    final restored = SavingsGoalModel.fromMap(legacy);
    expect(restored.hasReminder, isFalse);
    expect(restored.contributionAmount, isNull);
  });
}
