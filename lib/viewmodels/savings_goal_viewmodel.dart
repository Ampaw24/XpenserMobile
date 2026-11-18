import 'package:expenser/core/providers/sync_version_provider.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/data/repositories/savings_goal_repository.dart';
import 'package:expenser/models/account_model.dart';
import 'package:expenser/models/category_model.dart';
import 'package:expenser/models/savings_goal_model.dart';
import 'package:expenser/models/transaction_model.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:expenser/services/firebase_user_data_service.dart';
import 'package:expenser/viewmodels/account_viewmodel.dart';
import 'package:expenser/viewmodels/insights_viewmodel.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:expenser/viewmodels/transaction_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

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

  /// The expense a contribution records against [account], for previewing
  /// (e.g. the overdraft check) before [commitContribution].
  TransactionModel contributionTransaction({
    required SavingsGoalModel goal,
    required double amount,
    required AccountModel account,
  }) {
    final now = DateTime.now();
    return TransactionModel(
      id: const Uuid().v4(),
      amount: amount,
      type: TransactionType.expense,
      categoryId: CategoryModel.savingsId,
      accountId: account.id,
      date: now,
      notes: 'Savings: ${goal.name}',
      createdAt: now,
    );
  }

  /// Records [transaction] as spending from its account, then adds its
  /// amount to [goalId]'s saved total.
  Future<void> commitContribution(
    String goalId,
    TransactionModel transaction,
  ) async {
    final repo = ref.read(savingsGoalRepositoryProvider);
    final goal = repo.getById(goalId);
    if (goal == null) throw StateError('Savings goal $goalId not found');

    final createdCategory =
        await ref.read(categoryRepositoryProvider).ensureSavingsCategory();
    if (createdCategory != null) {
      _mirror((svc, uid) => svc.saveCategory(uid, createdCategory));
    }
    await ref.read(transactionProvider.notifier).addTransaction(transaction);

    final updated = goal.copyWith(
      savedAmount: goal.savedAmount + transaction.amount,
      lastContributionAt: transaction.date,
      fundingAccountId: transaction.accountId,
    );
    await repo.update(updated);
    refresh();
    _mirror((svc, uid) => svc.saveSavingsGoal(uid, updated));
    ref.read(accountProvider.notifier).refresh();
    ref.read(insightsProvider.notifier).refresh();
  }

  void _mirror(
    Future<void> Function(FirebaseUserDataService svc, String uid) fn,
  ) {
    final uid = ref.read(settingsProvider).uid;
    if (uid == null) return;
    fn(
      ref.read(firebaseUserDataServiceProvider),
      uid,
    ).catchError((e) => debugPrint('RTDB savings: $e'));
  }
}

final savingsGoalProvider =
    NotifierProvider<SavingsGoalNotifier, List<SavingsGoalModel>>(
      SavingsGoalNotifier.new,
    );
