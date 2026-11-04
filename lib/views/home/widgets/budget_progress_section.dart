import 'package:expenser/core/constants/branding.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/viewmodels/budget_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BudgetProgressSection extends ConsumerWidget {
  const BudgetProgressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final budgetState = ref.watch(budgetProvider);
    final categoryRepo = ref.read(categoryRepositoryProvider);
    final now = DateTime.now();
    final currentBudgets = budgetState.budgets
        .where((b) => b.month == now.month && b.year == now.year)
        .take(3)
        .toList();

    if (currentBudgets.isEmpty) return const SizedBox.shrink();

    final titleColor = isDark ? AppBrand.textPrimaryDark : AppBrand.textPrimaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Budget Overview',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
            GestureDetector(
              onTap: () => context.go('/shell/budgets'),
              child: const Text(
                'See all',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppBrand.tealPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...currentBudgets.map((b) {
          final category = categoryRepo.getById(b.categoryId);
          final spent = budgetState.spent[b.categoryId] ?? 0;
          final pct = (spent / b.limitAmount).clamp(0.0, 1.0);
          final Color barColor;
          if (pct >= 1.0) {
            barColor = const Color(0xFFE11D48);
          } else if (pct >= b.alertThreshold) {
            barColor = const Color(0xFFD97706);
          } else {
            barColor = AppBrand.tealPrimary;
          }
          return _BudgetCard(
            categoryName: category?.name ?? 'Category',
            spent: spent,
            limit: b.limitAmount,
            progress: pct,
            barColor: barColor,
          );
        }),
      ],
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.categoryName,
    required this.spent,
    required this.limit,
    required this.progress,
    required this.barColor,
  });

  final String categoryName;
  final double spent, limit, progress;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppBrand.surfaceDark : Colors.white;
    final borderColor = isDark ? AppBrand.borderDark : AppBrand.borderLight;
    final titleColor = isDark ? AppBrand.textPrimaryDark : AppBrand.textPrimaryLight;
    final trackColor = isDark ? AppBrand.surfaceDarkElevated : const Color(0xFFF1F5F9);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryName,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              Text(
                '${spent.toStringAsFixed(0)} / ${limit.toStringAsFixed(0)}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: trackColor,
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
