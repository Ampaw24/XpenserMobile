import 'package:expenser/core/providers/sync_version_provider.dart';
import 'package:expenser/data/repositories/transaction_repository.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InsightsState {
  final Map<String, double> spendingByCategory;
  final List<double> weeklyTotals;
  final double monthlyIncome;
  final double monthlyExpense;
  final double previousMonthExpense;
  final String? topCategory;
  final String? suggestedCategory;

  const InsightsState({
    this.spendingByCategory = const {},
    this.weeklyTotals = const [0, 0, 0, 0, 0, 0, 0],
    this.monthlyIncome = 0,
    this.monthlyExpense = 0,
    this.previousMonthExpense = 0,
    this.topCategory,
    this.suggestedCategory,
  });

  double get trendPercentage => previousMonthExpense > 0
      ? ((monthlyExpense - previousMonthExpense) / previousMonthExpense * 100)
      : 0;
}

class InsightsNotifier extends Notifier<InsightsState> {
  @override
  InsightsState build() {
    ref.watch(syncVersionProvider);
    refresh();
    return const InsightsState();
  }

  void refresh() {
    final repo = ref.read(transactionRepositoryProvider);
    final now = DateTime.now();

    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final prevMonthStart = DateTime(now.year, now.month - 1, 1);
    final prevMonthEnd = DateTime(now.year, now.month, 0, 23, 59, 59);

    final thisMonthTxs = repo.getByDateRange(monthStart, monthEnd);
    final prevMonthTxs = repo.getByDateRange(prevMonthStart, prevMonthEnd);

    final monthlyIncome = thisMonthTxs
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);
    final monthlyExpense = thisMonthTxs
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);
    final prevMonthExpense = prevMonthTxs
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);

    final spendingByCategory = <String, double>{};
    for (final t in thisMonthTxs.where((t) => t.type == TransactionType.expense)) {
      spendingByCategory[t.categoryId] =
          (spendingByCategory[t.categoryId] ?? 0) + t.amount;
    }

    String? topCategory;
    if (spendingByCategory.isNotEmpty) {
      topCategory = spendingByCategory.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }

    final weeklyTotals = List<double>.filled(7, 0.0);
    for (int i = 0; i < 7; i++) {
      final day = DateTime(now.year, now.month, now.day - (6 - i));
      final dayEnd = DateTime(day.year, day.month, day.day, 23, 59, 59);
      final dayTxs = repo.getByDateRange(day, dayEnd);
      weeklyTotals[i] = dayTxs
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (s, t) => s + t.amount);
    }

    state = InsightsState(
      spendingByCategory: spendingByCategory,
      weeklyTotals: weeklyTotals,
      monthlyIncome: monthlyIncome,
      monthlyExpense: monthlyExpense,
      previousMonthExpense: prevMonthExpense,
      topCategory: topCategory,
    );
  }

  String? suggestCategory(String notes) {
    final lower = notes.toLowerCase();
    if (lower.contains('food') || lower.contains('restaurant') || lower.contains('lunch') || lower.contains('dinner')) {
      return 'Food & Dining';
    }
    if (lower.contains('uber') || lower.contains('taxi') || lower.contains('bus') || lower.contains('fuel')) {
      return 'Transport';
    }
    if (lower.contains('shop') || lower.contains('buy') || lower.contains('purchase')) {
      return 'Shopping';
    }
    if (lower.contains('electricity') || lower.contains('water') || lower.contains('bill') || lower.contains('internet')) {
      return 'Bills & Utilities';
    }
    if (lower.contains('doctor') || lower.contains('hospital') || lower.contains('pharmacy')) {
      return 'Health';
    }
    if (lower.contains('movie') || lower.contains('netflix') || lower.contains('game')) {
      return 'Entertainment';
    }
    if (lower.contains('salary') || lower.contains('wage') || lower.contains('paycheck')) {
      return 'Salary';
    }
    return null;
  }
}

final insightsProvider =
    NotifierProvider<InsightsNotifier, InsightsState>(InsightsNotifier.new);
