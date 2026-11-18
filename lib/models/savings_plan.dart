import 'package:expenser/models/recurring_frequency.dart';
import 'package:expenser/models/savings_goal_model.dart';
import 'package:expenser/models/savings_reminder_schedule.dart';

/// What it takes to reach a goal on time with regular payments.
class SavingsPlan {
  const SavingsPlan({
    required this.frequency,
    required this.payments,
    required this.perPayment,
    required this.remaining,
  });

  final RecurringFrequency frequency;

  /// Payment periods left, including the current one if still unpaid.
  final int payments;

  /// Minimum per payment, rounded up to the cent so the total covers
  /// [remaining].
  final double perPayment;

  final double remaining;

  double get perMonth => monthlySavingsEquivalent(frequency, perPayment);
}

/// Payment periods (days, Monday-start weeks or calendar months) from
/// [start]'s period through [targetDate]'s, inclusive.
int savingsPeriodsBetween(
  RecurringFrequency frequency,
  DateTime start,
  DateTime targetDate,
) {
  final end = DateTime(targetDate.year, targetDate.month, targetDate.day + 1);
  var count = 0;
  for (
    var cursor = start;
    cursor.isBefore(end);
    cursor = startOfNextSavingsPeriod(frequency, cursor)
  ) {
    count++;
  }
  return count;
}

/// The plan to save [targetAmount] by [targetDate], or null when nothing is
/// left to save or no payment periods remain (the date has passed).
///
/// Payments start at [startAt] when it is later than [now]. When
/// [paidThisPeriod] is true the current period is already covered.
SavingsPlan? savingsPlan({
  required RecurringFrequency frequency,
  required double targetAmount,
  required double savedAmount,
  required DateTime targetDate,
  required DateTime now,
  DateTime? startAt,
  bool paidThisPeriod = false,
}) {
  final remaining = targetAmount - savedAmount;
  if (remaining <= 0) return null;

  var from = paidThisPeriod ? startOfNextSavingsPeriod(frequency, now) : now;
  if (startAt != null && startAt.isAfter(from)) from = startAt;

  final payments = savingsPeriodsBetween(frequency, from, targetDate);
  if (payments == 0) return null;
  return SavingsPlan(
    frequency: frequency,
    payments: payments,
    perPayment: roundUpToCents(remaining / payments),
    remaining: remaining,
  );
}

double roundUpToCents(double amount) =>
    // The epsilon stops values like 5.0000000001 from rounding up a cent.
    (amount * 100 - 1e-9).ceil() / 100;

/// Average amount per calendar month for a regular payment.
double monthlySavingsEquivalent(RecurringFrequency frequency, double amount) =>
    switch (frequency) {
      RecurringFrequency.daily => amount * 365.25 / 12,
      RecurringFrequency.weekly => amount * 365.25 / 7 / 12,
      RecurringFrequency.monthly => amount,
    };

extension SavingsGoalPlan on SavingsGoalModel {
  /// The plan from today, given what has been saved so far.
  SavingsPlan? currentPlan(DateTime now) {
    final frequency = savingsFrequency;
    if (frequency == null) return null;
    return savingsPlan(
      frequency: frequency,
      targetAmount: targetAmount,
      savedAmount: savedAmount,
      targetDate: targetDate,
      now: now,
      startAt: reminderAt,
      paidThisPeriod: contributedThisPeriod(now),
    );
  }
}
