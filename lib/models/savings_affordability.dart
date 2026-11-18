import 'package:expenser/models/category_model.dart';
import 'package:expenser/models/savings_plan.dart';
import 'package:expenser/models/transaction_model.dart';
import 'package:expenser/models/transaction_type.dart';

/// Average income minus spending per month over up to [months] complete
/// months before [now], counting only accounts in [currency].
///
/// Transfers and savings contributions are left out: they move money but
/// aren't income or spending. Returns null without any income in that
/// window, since the estimate would be meaningless.
double? averageMonthlySurplus({
  required List<TransactionModel> transactions,
  required Map<String, String> accountCurrencies,
  required String currency,
  required DateTime now,
  int months = 3,
}) {
  final windowStart = DateTime(now.year, now.month - months);
  final windowEnd = DateTime(now.year, now.month);
  var income = 0.0;
  var spending = 0.0;
  final activeMonths = <int>{};

  for (final t in transactions) {
    if (t.date.isBefore(windowStart) || !t.date.isBefore(windowEnd)) continue;
    if (accountCurrencies[t.accountId] != currency) continue;
    if (t.type == TransactionType.income) {
      income += t.amount;
    } else if (t.type == TransactionType.expense &&
        t.categoryId != CategoryModel.savingsId) {
      spending += t.amount;
    } else {
      continue;
    }
    activeMonths.add(t.date.year * 12 + t.date.month);
  }

  if (income <= 0) return null;
  return (income - spending) / activeMonths.length;
}

enum SavingsFit {
  /// Not enough history to judge.
  unknown,
  fits,
  exceeds,
}

class SavingsAffordability {
  const SavingsAffordability({
    required this.fit,
    this.monthlyCapacity,
    this.suggestedTargetDate,
  });

  final SavingsFit fit;

  /// Money left over per month after other goals' commitments.
  final double? monthlyCapacity;

  /// When the goal could be reached saving the whole capacity, if the plan
  /// exceeds it and there is any capacity.
  final DateTime? suggestedTargetDate;
}

/// Compares [plan] with the user's [monthlyCapacity] (see
/// [averageMonthlySurplus], minus other goals' commitments).
SavingsAffordability assessSavingsPlan(
  SavingsPlan plan,
  double? monthlyCapacity,
  DateTime now,
) {
  if (monthlyCapacity == null) {
    return const SavingsAffordability(fit: SavingsFit.unknown);
  }
  if (plan.perMonth <= monthlyCapacity) {
    return SavingsAffordability(
      fit: SavingsFit.fits,
      monthlyCapacity: monthlyCapacity,
    );
  }
  DateTime? suggested;
  if (monthlyCapacity > 0) {
    final monthsNeeded = (plan.remaining / monthlyCapacity).ceil();
    suggested = DateTime(now.year, now.month + monthsNeeded, now.day);
  }
  return SavingsAffordability(
    fit: SavingsFit.exceeds,
    monthlyCapacity: monthlyCapacity,
    suggestedTargetDate: suggested,
  );
}
