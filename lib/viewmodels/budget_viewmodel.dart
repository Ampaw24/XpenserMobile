import 'dart:async';

import 'package:expenser/core/providers/sync_version_provider.dart';
import 'package:expenser/data/repositories/budget_repository.dart';
import 'package:expenser/data/repositories/transaction_repository.dart';
import 'package:expenser/models/budget_model.dart';
import 'package:expenser/models/budget_period.dart';
import 'package:expenser/models/transaction_model.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:expenser/services/sync/budget_sync_service.dart';
import 'package:expenser/viewmodels/account_viewmodel.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:expenser/viewmodels/transaction_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

/// All category allocations created together in one wizard run.
class BudgetPlan {
  const BudgetPlan({
    required this.planId,
    required this.accountId,
    required this.period,
    required this.notes,
    required this.range,
    required this.currency,
    required this.allocations,
    required this.spentByBudgetId,
    this.closedAt,
  });

  final String planId;
  final String? accountId;
  final BudgetPeriodType period;
  final String? notes;
  final BudgetDateRange range;
  final String currency;
  final List<BudgetModel> allocations;

  /// When the user closed the plan early; null while it runs to its end date.
  final DateTime? closedAt;

  /// Spending within this plan's range and account, keyed by allocation id.
  final Map<String, double> spentByBudgetId;

  Set<String> get categoryIds => {for (final b in allocations) b.categoryId};

  double get alertThreshold =>
      allocations.isEmpty ? 0.8 : allocations.first.alertThreshold;

  double get totalLimit => allocations.fold(0, (sum, b) => sum + b.limitAmount);

  double get totalSpent =>
      spentByBudgetId.values.fold(0, (sum, spent) => sum + spent);

  double get remaining => totalLimit - totalSpent;

  /// Spent ÷ limit, not clamped, so values above 1 mean over budget.
  double get usage => totalLimit > 0 ? totalSpent / totalLimit : 0;

  double spentFor(BudgetModel allocation) =>
      spentByBudgetId[allocation.id] ?? 0;

  double usageFor(BudgetModel allocation) =>
      allocation.limitAmount > 0
          ? spentFor(allocation) / allocation.limitAmount
          : 0;

  BudgetStatus status(DateTime now) =>
      closedAt != null ? BudgetStatus.closed : range.statusAt(now);

  bool isFinished(DateTime now) {
    final s = status(now);
    return s == BudgetStatus.ended || s == BudgetStatus.closed;
  }

  /// The whole allocated amount has been spent.
  bool get isFullyUsed => totalLimit > 0 && totalSpent >= totalLimit;

  bool isUsedUp(BudgetModel allocation) =>
      allocation.limitAmount > 0 &&
      spentFor(allocation) >= allocation.limitAmount;

  /// Last calendar day spending was tracked.
  DateTime get lastTrackedDay =>
      closedAt != null
          ? DateTime(closedAt!.year, closedAt!.month, closedAt!.day)
          : range.end;

  /// Whether [t] counts against this plan.
  bool covers(TransactionModel t) =>
      t.type == TransactionType.expense &&
      categoryIds.contains(t.categoryId) &&
      (accountId == null || t.accountId == accountId) &&
      _tracks(t.date);

  bool _tracks(DateTime date) =>
      range.contains(date) && (closedAt == null || date.isBefore(closedAt!));

  bool _sameSetupAs(BudgetPlan other) =>
      other.accountId == accountId &&
      other.period == period &&
      setEquals(other.categoryIds, categoryIds);
}

class BudgetState {
  const BudgetState({this.budgets = const [], this.plans = const []});

  final List<BudgetModel> budgets;
  final List<BudgetPlan> plans;

  /// Running and not-yet-started plans, soonest first.
  List<BudgetPlan> currentPlans(DateTime now) =>
      plans.where((p) => !p.isFinished(now)).toList()
        ..sort((a, b) => a.range.start.compareTo(b.range.start));

  List<BudgetPlan> activePlans(DateTime now) =>
      plans.where((p) => p.status(now) == BudgetStatus.active).toList();

  /// Ended or closed plans, most recently finished first.
  List<BudgetPlan> endedPlans(DateTime now) =>
      plans.where((p) => p.isFinished(now)).toList()
        ..sort((a, b) => b.lastTrackedDay.compareTo(a.lastTrackedDay));

  BudgetPlan? planById(String planId) {
    for (final plan in plans) {
      if (plan.planId == planId) return plan;
    }
    return null;
  }

  /// True when a current plan already continues [ended]'s setup.
  bool isRenewed(BudgetPlan ended, DateTime now) => currentPlans(now).any(
    (p) =>
        !p.range.start.isBefore(ended.lastTrackedDay) && p._sameSetupAs(ended),
  );
}

class BudgetNotifier extends Notifier<BudgetState> {
  @override
  BudgetState build() {
    ref.watch(syncVersionProvider);
    // Recompute spending whenever transactions, account currencies or the
    // fallback currency change.
    ref.watch(transactionProvider.select((s) => s.transactions));
    ref.watch(accountProvider.select((s) => s.accounts));
    ref.watch(settingsProvider.select((s) => s.preferredCurrency));
    return _compute();
  }

  BudgetState _compute() {
    final budgets = ref.read(budgetRepositoryProvider).getAll();
    final expensesByCategory = <String, List<TransactionModel>>{};
    for (final t in ref.read(transactionRepositoryProvider).getAll()) {
      if (t.type != TransactionType.expense) continue;
      expensesByCategory.putIfAbsent(t.categoryId, () => []).add(t);
    }

    final grouped = <String, List<BudgetModel>>{};
    for (final b in budgets) {
      grouped.putIfAbsent(b.planId ?? b.id, () => []).add(b);
    }

    final plans = [
      for (final entry in grouped.entries)
        _buildPlan(entry.key, entry.value, expensesByCategory),
    ];
    return BudgetState(budgets: budgets, plans: plans);
  }

  BudgetPlan _buildPlan(
    String planId,
    List<BudgetModel> allocations,
    Map<String, List<TransactionModel>> expensesByCategory,
  ) {
    final first = allocations.first;
    final range = first.dateRange;
    final accountId = first.accountId;
    final closedAt = first.closedAt;
    final spent = <String, double>{};
    for (final b in allocations) {
      var total = 0.0;
      for (final t in expensesByCategory[b.categoryId] ?? const []) {
        if (accountId != null && t.accountId != accountId) continue;
        if (!range.contains(t.date)) continue;
        if (closedAt != null && !t.date.isBefore(closedAt)) continue;
        total += t.amount;
      }
      spent[b.id] = total;
    }

    return BudgetPlan(
      planId: planId,
      accountId: accountId,
      period: first.periodType,
      notes: first.notes,
      range: range,
      currency: _currencyFor(accountId),
      allocations: allocations,
      spentByBudgetId: spent,
      closedAt: closedAt,
    );
  }

  String _currencyFor(String? accountId) {
    if (accountId != null) {
      for (final a in ref.read(accountProvider).accounts) {
        if (a.id == accountId) return a.currencyCode;
      }
    }
    return ref.read(settingsProvider).preferredCurrency;
  }

  void _reload() => state = _compute();

  /// Re-reads the offline copy after the server pushed changes into it.
  void reloadFromCache() => _reload();

  BudgetSyncService get _sync => ref.read(budgetSyncServiceProvider);

  String? get _uid => ref.read(settingsProvider).uid;

  List<BudgetModel> _allocationsOf(String planId) =>
      state.budgets.where((b) => (b.planId ?? b.id) == planId).toList();

  /// Creates or updates a plan. Allocations whose category already exists in
  /// the plan keep their id, so alert history and sync records stay linked;
  /// categories no longer present are removed.
  Future<void> savePlan(String planId, List<BudgetModel> allocations) async {
    final existing = {for (final b in _allocationsOf(planId)) b.categoryId: b};

    for (final draft in allocations) {
      final previous = existing.remove(draft.categoryId);
      final budget =
          previous == null
              ? draft
              : draft.copyWith(
                id: previous.id,
                createdAt: previous.createdAt,
                closedAt: previous.closedAt,
              );
      await _sync.save(_uid, budget);
    }
    for (final removed in existing.values) {
      await _sync.delete(_uid, removed.id);
    }
    _reload();
  }

  /// Stops the plan now: it moves to Ended and later spending isn't counted.
  Future<void> closePlan(String planId) async {
    final closedAt = DateTime.now();
    for (final b in _allocationsOf(planId)) {
      await _sync.save(_uid, b.copyWith(closedAt: closedAt));
    }
    _reload();
  }

  Future<void> reopenPlan(String planId) async {
    for (final b in _allocationsOf(planId)) {
      await _sync.save(_uid, b.copyWith(clearClosedAt: true));
    }
    _reload();
  }

  /// Deletes a plan and returns its allocations so the caller can undo.
  Future<List<BudgetModel>> deletePlan(String planId) async {
    final toDelete = _allocationsOf(planId);
    for (final b in toDelete) {
      await _sync.delete(_uid, b.id);
    }
    _reload();
    return toDelete;
  }

  Future<void> restore(List<BudgetModel> allocations) async {
    for (final b in allocations) {
      await _sync.save(_uid, b.copyWith());
    }
    _reload();
  }

  /// Copies a finished plan into the period containing today (or the next
  /// period, if it was closed before its own period ended).
  /// Returns the new plan id, or null if [planId] doesn't exist.
  Future<String?> renewPlan(String planId) async {
    final plan = state.planById(planId);
    if (plan == null) return null;

    final now = DateTime.now();
    final range = plan.range.renewedFor(plan.period, now);
    final newPlanId = const Uuid().v4();
    final copies = [
      for (final b in plan.allocations)
        BudgetModel(
          id: const Uuid().v4(),
          categoryId: b.categoryId,
          limitAmount: b.limitAmount,
          month: range.start.month,
          year: range.start.year,
          alertThreshold: b.alertThreshold,
          createdAt: now,
          accountId: b.accountId,
          period: plan.period.value,
          planId: newPlanId,
          notes: b.notes,
          startDate: range.start,
          endDate: range.end,
        ),
    ];
    await savePlan(newPlanId, copies);
    return newPlanId;
  }

  Future<void> addBudget(BudgetModel b) async {
    await _sync.save(_uid, b);
    _reload();
  }

  Future<void> updateBudget(BudgetModel b) async {
    await _sync.save(_uid, b);
    _reload();
  }

  Future<void> deleteBudget(String id) async {
    await _sync.delete(_uid, id);
    _reload();
  }
}

final budgetProvider = NotifierProvider<BudgetNotifier, BudgetState>(
  BudgetNotifier.new,
);

/// Expenses counted against one plan, newest first.
final budgetPlanTransactionsProvider =
    Provider.family<List<TransactionModel>, String>((ref, planId) {
      final plan = ref.watch(budgetProvider).planById(planId);
      if (plan == null) return const [];
      return ref
          .read(transactionRepositoryProvider)
          .getAll()
          .where(plan.covers)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    });

/// Keeps the offline copy in step with Firebase while signed in: applies
/// server changes as they arrive and re-sends pending changes on reconnect.
final budgetLiveSyncProvider = Provider<void>((ref) {
  final uid = ref.watch(settingsProvider.select((s) => s.uid));
  if (uid == null) return;

  final remote = ref.watch(budgetRemoteSourceProvider);
  final sync = ref.watch(budgetSyncServiceProvider);
  sync.flush(uid);

  final subscriptions = <StreamSubscription<Object?>>[
    remote
        .watchBudgets(uid)
        .asyncMap((budgets) => sync.applyRemote(uid, budgets))
        .listen(
          (_) => ref.read(budgetProvider.notifier).reloadFromCache(),
          onError: (Object e) => debugPrint('Budget live sync: $e'),
        ),
    remote
        .watchConnection()
        .where((connected) => connected)
        .listen(
          (_) => sync.flush(uid),
          onError: (Object e) => debugPrint('Budget connection: $e'),
        ),
  ];
  ref.onDispose(() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
  });
});
