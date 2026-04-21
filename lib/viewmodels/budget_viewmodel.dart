import 'package:expenser/data/repositories/budget_repository.dart';
import 'package:expenser/data/repositories/transaction_repository.dart';
import 'package:expenser/models/budget_model.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetState {
  final List<BudgetModel> budgets;
  final Map<String, double> spent;

  const BudgetState({this.budgets = const [], this.spent = const {}});

  Map<String, double> get percentages {
    final result = <String, double>{};
    for (final b in budgets) {
      final s = spent[b.categoryId] ?? 0;
      result[b.categoryId] = b.limitAmount > 0 ? (s / b.limitAmount).clamp(0.0, 1.0) : 0;
    }
    return result;
  }

  BudgetState copyWith({
    List<BudgetModel>? budgets,
    Map<String, double>? spent,
  }) =>
      BudgetState(
        budgets: budgets ?? this.budgets,
        spent: spent ?? this.spent,
      );
}

class BudgetNotifier extends Notifier<BudgetState> {
  @override
  BudgetState build() {
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
  }

  Future<void> updateBudget(BudgetModel b) async {
    await ref.read(budgetRepositoryProvider).update(b);
    _load();
  }

  Future<void> deleteBudget(String id) async {
    await ref.read(budgetRepositoryProvider).delete(id);
    _load();
  }
}

final budgetProvider =
    NotifierProvider<BudgetNotifier, BudgetState>(BudgetNotifier.new);
