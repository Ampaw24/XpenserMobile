import 'package:expenser/models/recurring_frequency.dart';
import 'package:expenser/models/savings_goal_model.dart';
import 'package:intl/intl.dart';

/// Monthly reminders above this day would skip shorter months.
const maxMonthlyReminderDay = 28;

/// Next reminder strictly after [now], in local wall-clock time.
///
/// The time of day comes from [anchor]; weekly reminders repeat on its
/// weekday and monthly ones on its day of month (capped at
/// [maxMonthlyReminderDay]).
DateTime nextReminderAfter(
  RecurringFrequency frequency,
  DateTime anchor,
  DateTime now,
) {
  DateTime at(int year, int month, int day) =>
      DateTime(year, month, day, anchor.hour, anchor.minute);

  switch (frequency) {
    case RecurringFrequency.daily:
      final today = at(now.year, now.month, now.day);
      return today.isAfter(now) ? today : at(now.year, now.month, now.day + 1);
    case RecurringFrequency.weekly:
      final daysAhead = (anchor.weekday - now.weekday) % 7;
      final candidate = at(now.year, now.month, now.day + daysAhead);
      return candidate.isAfter(now)
          ? candidate
          : at(now.year, now.month, now.day + daysAhead + 7);
    case RecurringFrequency.monthly:
      final day =
          anchor.day > maxMonthlyReminderDay
              ? maxMonthlyReminderDay
              : anchor.day;
      final candidate = at(now.year, now.month, day);
      return candidate.isAfter(now)
          ? candidate
          : at(now.year, now.month + 1, day);
  }
}

/// First moment of the period after the one containing [now].
DateTime startOfNextSavingsPeriod(RecurringFrequency frequency, DateTime now) =>
    switch (frequency) {
      RecurringFrequency.daily => DateTime(now.year, now.month, now.day + 1),
      RecurringFrequency.weekly => DateTime(
        now.year,
        now.month,
        now.day - (now.weekday - DateTime.monday) + 7,
      ),
      RecurringFrequency.monthly => DateTime(now.year, now.month + 1),
    };

/// Whether [a] and [b] fall in the same reminder period. Weeks start Monday.
bool isSameSavingsPeriod(RecurringFrequency frequency, DateTime a, DateTime b) {
  switch (frequency) {
    case RecurringFrequency.daily:
      return a.year == b.year && a.month == b.month && a.day == b.day;
    case RecurringFrequency.weekly:
      DateTime weekStart(DateTime d) =>
          DateTime(d.year, d.month, d.day - (d.weekday - DateTime.monday));
      return weekStart(a) == weekStart(b);
    case RecurringFrequency.monthly:
      return a.year == b.year && a.month == b.month;
  }
}

extension SavingsGoalSchedule on SavingsGoalModel {
  /// True once money has been added in the current reminder period.
  bool contributedThisPeriod(DateTime now) {
    final frequency = savingsFrequency;
    final last = lastContributionAt;
    if (frequency == null || last == null) return false;
    return isSameSavingsPeriod(frequency, last, now);
  }
}

/// Next reminder for a goal with [SavingsGoalModel.hasReminder]. Never
/// before the chosen start, and skips the current period once the user has
/// already added money in it.
DateTime nextReminderFor(SavingsGoalModel goal, DateTime now) {
  final frequency = goal.savingsFrequency!;
  final anchor = goal.reminderAt!;
  var from = now;
  if (goal.contributedThisPeriod(now)) {
    from = startOfNextSavingsPeriod(frequency, now);
  }
  if (anchor.isAfter(from)) from = anchor;
  // nextReminderAfter is exclusive, so step back to include [from] itself.
  return nextReminderAfter(
    frequency,
    anchor,
    from.subtract(const Duration(seconds: 1)),
  );
}

String savingsPeriodName(RecurringFrequency frequency) => switch (frequency) {
  RecurringFrequency.daily => 'today',
  RecurringFrequency.weekly => 'this week',
  RecurringFrequency.monthly => 'this month',
};

String savingsPeriodNoun(RecurringFrequency frequency) => switch (frequency) {
  RecurringFrequency.daily => 'day',
  RecurringFrequency.weekly => 'week',
  RecurringFrequency.monthly => 'month',
};

/// e.g. "Weekly on Monday at 9:00 AM".
String reminderScheduleLabel(RecurringFrequency frequency, DateTime anchor) {
  final time = DateFormat.jm().format(anchor);
  return switch (frequency) {
    RecurringFrequency.daily => 'Daily at $time',
    RecurringFrequency.weekly =>
      'Weekly on ${DateFormat.EEEE().format(anchor)} at $time',
    RecurringFrequency.monthly =>
      'Monthly on day ${anchor.day > maxMonthlyReminderDay ? maxMonthlyReminderDay : anchor.day} at $time',
  };
}
