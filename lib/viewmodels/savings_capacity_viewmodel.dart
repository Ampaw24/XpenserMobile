import 'package:expenser/data/repositories/transaction_repository.dart';
import 'package:expenser/models/savings_affordability.dart';
import 'package:expenser/models/savings_plan.dart';
import 'package:expenser/viewmodels/account_viewmodel.dart';
import 'package:expenser/viewmodels/savings_goal_viewmodel.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:expenser/viewmodels/transaction_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Money the user has left to save each month, in their preferred
/// currency: recent average surplus minus what other active goals already
/// commit. Null when there is too little history to estimate.
///
/// The argument is the goal being edited, which is left out of the
/// commitments (null for a new goal).
final savingsCapacityProvider = Provider.autoDispose.family<double?, String?>((
  ref,
  editingGoalId,
) {
  // Watched only to recompute when transactions change; the list itself
  // may be filtered, so all records come from the repository.
  ref.watch(transactionProvider);
  final accounts = ref.watch(accountProvider).accounts;
  final currency = ref.watch(
    settingsProvider.select((s) => s.preferredCurrency),
  );
  final goals = ref.watch(savingsGoalProvider);

  final surplus = averageMonthlySurplus(
    transactions: ref.read(transactionRepositoryProvider).getAll(),
    accountCurrencies: {for (final a in accounts) a.id: a.currencyCode},
    currency: currency,
    now: DateTime.now(),
  );
  if (surplus == null) return null;

  var committed = 0.0;
  for (final goal in goals) {
    final frequency = goal.savingsFrequency;
    final amount = goal.contributionAmount;
    if (goal.id == editingGoalId || goal.isCompleted) continue;
    if (frequency == null || amount == null) continue;
    committed += monthlySavingsEquivalent(frequency, amount);
  }
  return surplus - committed;
});
