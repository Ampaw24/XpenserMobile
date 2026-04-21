import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/viewmodels/budget_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BudgetProgressSection extends ConsumerWidget {
  const BudgetProgressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetState = ref.watch(budgetProvider);
    final categoryRepo = ref.read(categoryRepositoryProvider);
    final now = DateTime.now();
    final currentBudgets = budgetState.budgets
        .where((b) => b.month == now.month && b.year == now.year)
        .take(3)
        .toList();

    if (currentBudgets.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Budget Overview',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () => context.go('/shell/budgets'),
              child: const Text('See all',
                  style: TextStyle(color: AppColors.PRIMARY)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...currentBudgets.map((b) {
          final category = categoryRepo.getById(b.categoryId);
          final spent = budgetState.spent[b.categoryId] ?? 0;
          final pct = (spent / b.limitAmount).clamp(0.0, 1.0);
          final Color barColor;
          if (pct >= 1.0) {
            barColor = Colors.red;
          } else if (pct >= b.alertThreshold) {
            barColor = Colors.orange;
          } else {
            barColor = AppColors.PRIMARY;
          }
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(category?.name ?? 'Category',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(
                      '${spent.toStringAsFixed(0)} / ${b.limitAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                          color: barColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: Colors.grey.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(barColor),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
