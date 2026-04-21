import 'package:expenser/data/repositories/transaction_repository.dart';
import 'package:expenser/models/transaction_model.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TransactionState {
  final List<TransactionModel> transactions;
  final String? activeAccountFilter;
  final String? activeCategoryFilter;
  final String searchQuery;

  const TransactionState({
    this.transactions = const [],
    this.activeAccountFilter,
    this.activeCategoryFilter,
    this.searchQuery = '',
  });

  TransactionState copyWith({
    List<TransactionModel>? transactions,
    String? activeAccountFilter,
    String? activeCategoryFilter,
    String? searchQuery,
  }) =>
      TransactionState(
        transactions: transactions ?? this.transactions,
        activeAccountFilter: activeAccountFilter ?? this.activeAccountFilter,
        activeCategoryFilter: activeCategoryFilter ?? this.activeCategoryFilter,
        searchQuery: searchQuery ?? this.searchQuery,
      );
}

class TransactionNotifier extends Notifier<TransactionState> {
  @override
  TransactionState build() {
    final all = ref.read(transactionRepositoryProvider).getAll();
    return TransactionState(transactions: all);
  }

  void _load() {
    final all = ref.read(transactionRepositoryProvider).getAll();
    state = state.copyWith(transactions: _applyFilters(all));
  }

  List<TransactionModel> _applyFilters(List<TransactionModel> all) {
    return all.where((t) {
      if (state.activeAccountFilter != null &&
          t.accountId != state.activeAccountFilter) { return false; }
      if (state.activeCategoryFilter != null &&
          t.categoryId != state.activeCategoryFilter) { return false; }
      if (state.searchQuery.isNotEmpty &&
          !(t.notes?.toLowerCase().contains(state.searchQuery.toLowerCase()) ??
              false)) { return false; }
      return true;
    }).toList();
  }

  void refresh() => _load();

  Future<void> addTransaction(TransactionModel t) async {
    await ref.read(transactionRepositoryProvider).add(t);
    _load();
  }

  Future<void> updateTransaction(TransactionModel t) async {
    await ref.read(transactionRepositoryProvider).update(t);
    _load();
  }

  Future<TransactionModel?> deleteTransaction(String id) async {
    final repo = ref.read(transactionRepositoryProvider);
    final deleted = repo.getById(id);
    await repo.delete(id);
    _load();
    return deleted;
  }

  void setAccountFilter(String? id) {
    state = state.copyWith(activeAccountFilter: id);
    _load();
  }

  void setCategoryFilter(String? id) {
    state = state.copyWith(activeCategoryFilter: id);
    _load();
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
    _load();
  }

  Map<String, List<TransactionModel>> getGrouped() {
    final grouped = <String, List<TransactionModel>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final t in state.transactions) {
      final date = DateTime(t.date.year, t.date.month, t.date.day);
      final String label;
      if (date == today) {
        label = 'Today';
      } else if (date == yesterday) {
        label = 'Yesterday';
      } else {
        label = DateFormat('MMMM d, yyyy').format(t.date);
      }
      grouped.putIfAbsent(label, () => []).add(t);
    }
    return grouped;
  }

  List<TransactionModel> getAll() =>
      ref.read(transactionRepositoryProvider).getAll();

  double getTotalByType(TransactionType type, {DateTime? from, DateTime? to}) {
    final all = ref.read(transactionRepositoryProvider).getAll();
    return all
        .where((t) =>
            t.type == type &&
            (from == null || !t.date.isBefore(from)) &&
            (to == null || !t.date.isAfter(to)))
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}

final transactionProvider =
    NotifierProvider<TransactionNotifier, TransactionState>(
        TransactionNotifier.new);
