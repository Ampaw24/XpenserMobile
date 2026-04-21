import 'package:expenser/data/repositories/savings_goal_repository.dart';
import 'package:expenser/models/savings_goal_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SavingsGoalNotifier extends Notifier<List<SavingsGoalModel>> {
  @override
  List<SavingsGoalModel> build() {
    return ref.read(savingsGoalRepositoryProvider).getAll();
  }

  void refresh() {
    state = ref.read(savingsGoalRepositoryProvider).getAll();
  }

  Future<void> addGoal(SavingsGoalModel goal) async {
    await ref.read(savingsGoalRepositoryProvider).add(goal);
    refresh();
  }

  Future<void> updateGoal(SavingsGoalModel goal) async {
    await ref.read(savingsGoalRepositoryProvider).update(goal);
    refresh();
  }

  Future<void> deleteGoal(String id) async {
    await ref.read(savingsGoalRepositoryProvider).delete(id);
    refresh();
  }

  Future<void> addContribution(String goalId, double amount) async {
    final repo = ref.read(savingsGoalRepositoryProvider);
    final goal = repo.getById(goalId);
    if (goal == null) return;
    final updated = goal.copyWith(savedAmount: goal.savedAmount + amount);
    await repo.update(updated);
    refresh();
  }
}

final savingsGoalProvider =
    NotifierProvider<SavingsGoalNotifier, List<SavingsGoalModel>>(
        SavingsGoalNotifier.new);
