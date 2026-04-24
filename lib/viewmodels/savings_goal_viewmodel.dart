import 'package:expenser/core/providers/sync_version_provider.dart';
import 'package:expenser/data/repositories/savings_goal_repository.dart';
import 'package:expenser/models/savings_goal_model.dart';
import 'package:expenser/services/firebase_user_data_service.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SavingsGoalNotifier extends Notifier<List<SavingsGoalModel>> {
  @override
  List<SavingsGoalModel> build() {
    ref.watch(syncVersionProvider);
    return ref.read(savingsGoalRepositoryProvider).getAll();
  }

  void refresh() {
    state = ref.read(savingsGoalRepositoryProvider).getAll();
  }

  Future<void> addGoal(SavingsGoalModel goal) async {
    await ref.read(savingsGoalRepositoryProvider).add(goal);
    refresh();
    _mirror((svc, uid) => svc.saveSavingsGoal(uid, goal));
  }

  Future<void> updateGoal(SavingsGoalModel goal) async {
    await ref.read(savingsGoalRepositoryProvider).update(goal);
    refresh();
    _mirror((svc, uid) => svc.saveSavingsGoal(uid, goal));
  }

  Future<void> deleteGoal(String id) async {
    await ref.read(savingsGoalRepositoryProvider).delete(id);
    refresh();
    _mirror((svc, uid) => svc.deleteSavingsGoal(uid, id));
  }

  Future<void> addContribution(String goalId, double amount) async {
    final repo = ref.read(savingsGoalRepositoryProvider);
    final goal = repo.getById(goalId);
    if (goal == null) return;
    final updated = goal.copyWith(savedAmount: goal.savedAmount + amount);
    await repo.update(updated);
    refresh();
    _mirror((svc, uid) => svc.saveSavingsGoal(uid, updated));
  }

  void _mirror(
      Future<void> Function(FirebaseUserDataService svc, String uid) fn) {
    final uid = ref.read(settingsProvider).uid;
    if (uid == null) return;
    fn(ref.read(firebaseUserDataServiceProvider), uid)
        .catchError((e) => debugPrint('RTDB savings: $e'));
  }
}

final savingsGoalProvider =
    NotifierProvider<SavingsGoalNotifier, List<SavingsGoalModel>>(
        SavingsGoalNotifier.new);
