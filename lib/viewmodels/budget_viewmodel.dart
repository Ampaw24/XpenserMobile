import 'package:expenser/core/providers/sync_version_provider.dart';
import 'package:expenser/data/repositories/budget_repository.dart';
import 'package:expenser/data/repositories/transaction_repository.dart';
import 'package:expenser/models/budget_model.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:expenser/services/firebase_user_data_service.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Groups all category allocations belonging to one wizard creation.
class BudgetPlan {
  final String planId;
  final String? accountId;
  final String period;
  final String? notes;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<BudgetModel> allocations;

  const BudgetPlan({
    required this.planId,
    required this.accountId,
    required this.period,
    required this.notes,
    required this.startDate,
    required this.endDate,
    required this.allocations,
  });

  double get totalLimit =>
      allocations.fold(0, (sum, b) => sum + b.limitAmount);

  double totalSpent(Map<String, double> spent) =>
      allocations.fold(0, (sum, b) => sum + (spent[b.categoryId] ?? 0));

  double spentPercent(Map<String, double> spent) {
    final limit = totalLimit;
    if (limit <= 0) return 0;
    return (totalSpent(spent) / limit).clamp(0.0, 1.0);
  }
}

class BudgetState {
  final List<BudgetModel> budgets;
  final Map<String, double> spent;

  const BudgetState({this.budgets = const [], this.spent = const {}});

  Map<String, double> get percentages {
    final result = <String, double>{};
    for (final b in budgets) {
      final s = spent[b.categoryId] ?? 0;
      result[b.categoryId] =
          b.limitAmount > 0 ? (s / b.limitAmount).clamp(0.0, 1.0) : 0;
    }
    return result;
  }

  /// Groups current-month budgets by their planId (or individual id as fallback).
  List<BudgetPlan> get plans {
    final now = DateTime.now();
    final current = budgets
        .where((b) => b.month == now.month && b.year == now.year)
        .toList();

    final grouped = <String, List<BudgetModel>>{};
    for (final b in current) {
      final key = b.planId ?? b.id;
      grouped.putIfAbsent(key, () => []).add(b);
    }

    return grouped.entries.map((e) {
      final first = e.value.first;
      return BudgetPlan(
        planId: e.key,
        accountId: first.accountId,
        period: first.period ?? 'monthly',
        notes: first.notes,
        startDate: first.startDate,
        endDate: first.endDate,
        allocations: e.value,
      );
    }).toList();
  }

  BudgetState copyWith({
    List<BudgetModel>? budgets,
    Map<String, double>? spent,
  }) =>
      BudgetState(budgets: budgets ?? this.budgets, spent: spent ?? this.spent);
}

class BudgetNotifier extends Notifier<BudgetState> {
  @override
  BudgetState build() {
    ref.watch(syncVersionProvider);
    final now = DateTime.now();
    final budgets = ref.read(budgetRepositoryProvider).getAll();
    final from = DateTime(now.year, now.month, 1);
    final to = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final txs = ref.read(transactionRepositoryProvider).getByDateRange(from, to);
    final spent = <String, double>{};
    for (final t in txs.where((t) => t.type == TransactionType.expense)) {
      spent[t.categoryId] = (spent[t.categoryId] ?? 0) + t.amount;
    }
    return BudgetState(budgets: budgets, spent: spent);
  }

  void _load() {
    final now = DateTime.now();
    final budgets = ref.read(budgetRepositoryProvider).getAll();
    state = state.copyWith(budgets: budgets);
    _refreshSpent(now.month, now.year);
  }

  void _refreshSpent(int month, int year) {
    final txRepo = ref.read(transactionRepositoryProvider);
    final from = DateTime(year, month, 1);
    final to = DateTime(year, month + 1, 0, 23, 59, 59);
    final txs = txRepo.getByDateRange(from, to);
    final spent = <String, double>{};
    for (final t in txs.where((t) => t.type == TransactionType.expense)) {
      spent[t.categoryId] = (spent[t.categoryId] ?? 0) + t.amount;
    }
    state = state.copyWith(spent: spent);
  }

  void refresh() => _load();

  Future<void> addBudget(BudgetModel b) async {
    await ref.read(budgetRepositoryProvider).add(b);
    _load();
    _mirror((svc, uid) => svc.saveBudget(uid, b));
  }

  Future<void> addPlan(List<BudgetModel> allocations) async {
    for (final b in allocations) {
      await ref.read(budgetRepositoryProvider).add(b);
      _mirror((svc, uid) => svc.saveBudget(uid, b));
    }
    _load();
  }

  Future<void> updateBudget(BudgetModel b) async {
    await ref.read(budgetRepositoryProvider).update(b);
    _load();
    _mirror((svc, uid) => svc.saveBudget(uid, b));
  }

  Future<void> deleteBudget(String id) async {
    await ref.read(budgetRepositoryProvider).delete(id);
    _load();
    _mirror((svc, uid) => svc.deleteBudget(uid, id));
  }

  Future<void> deletePlan(String planId) async {
    final toDelete = state.budgets
        .where((b) => (b.planId ?? b.id) == planId)
        .toList();
    for (final b in toDelete) {
      await ref.read(budgetRepositoryProvider).delete(b.id);
      _mirror((svc, uid) => svc.deleteBudget(uid, b.id));
    }
    _load();
  }

  void _mirror(
    Future<void> Function(FirebaseUserDataService svc, String uid) fn,
  ) {
    final uid = ref.read(settingsProvider).uid;
    if (uid == null) return;
    fn(ref.read(firebaseUserDataServiceProvider), uid)
        .catchError((e) => debugPrint('RTDB budget: $e'));
  }
}

final budgetProvider = NotifierProvider<BudgetNotifier, BudgetState>(
  BudgetNotifier.new,
);
