import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/viewmodels/budget_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(budgetProvider);
    final categoryRepo = ref.read(categoryRepositoryProvider);
    final now = DateTime.now();
    final current = state.budgets
        .where((b) => b.month == now.month && b.year == now.year)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Text('Budgets',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            if (current.isEmpty)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pie_chart_outline_rounded,
                        size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text('No budgets for this month',
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Tap + to set a budget',
                        style:
                            TextStyle(color: Colors.grey[400], fontSize: 13)),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: current.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final b = current[i];
                    final category = categoryRepo.getById(b.categoryId);
                    final spent = state.spent[b.categoryId] ?? 0;
                    final pct =
                        (spent / b.limitAmount).clamp(0.0, 1.0);
                    final Color barColor;
                    if (pct >= 1.0) {
                      barColor = Colors.red;
                    } else if (pct >= b.alertThreshold) {
                      barColor = Colors.orange;
                    } else {
                      barColor = AppColors.PRIMARY;
                    }
                    return Dismissible(
                      key: ValueKey(b.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_rounded,
                            color: Colors.white),
                      ),
                      onDismissed: (_) =>
                          ref.read(budgetProvider.notifier).deleteBudget(b.id),
                      child: GestureDetector(
                        onTap: () =>
                            context.push('/budgets/${b.id}/edit'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    category?.name ?? 'Category',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  Text(
                                    '${(pct * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(
                                        color: barColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  backgroundColor:
                                      Colors.grey.withValues(alpha: 0.15),
                                  valueColor:
                                      AlwaysStoppedAnimation(barColor),
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Spent: ${spent.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12),
                                  ),
                                  Text(
                                    'Limit: ${b.limitAmount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.PRIMARY,
        onPressed: () => context.push('/budgets/add'),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
