import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/viewmodels/budget_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class BudgetProgressSection extends ConsumerWidget {
  const BudgetProgressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.01),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget Overview',
                style: GoogleFonts.montserrat(
                  fontSize: sw * 0.042,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/shell/budgets'),
                child: Text(
                  'See all',
                  style: GoogleFonts.inter(
                    fontSize: sw * 0.033,
                    color: AppColors.ACCENT,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: sh * 0.014),
        ...currentBudgets.map((b) {
          final category = categoryRepo.getById(b.categoryId);
          final spent = budgetState.spent[b.categoryId] ?? 0;
          final pct = (spent / b.limitAmount).clamp(0.0, 1.0);
          final Color barColor;
          if (pct >= 1.0) {
            barColor = const Color(0xFFFF5252);
          } else if (pct >= b.alertThreshold) {
            barColor = const Color(0xFFFFAB40);
          } else {
            barColor = AppColors.ACCENT;
          }
          return _BudgetCard(
            categoryName: category?.name ?? 'Category',
            spent: spent,
            limit: b.limitAmount,
            progress: pct,
            barColor: barColor,
            sw: sw,
            sh: sh,
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
    required this.sw,
    required this.sh,
  });

  final String categoryName;
  final double spent, limit, progress;
  final Color barColor;
  final double sw, sh;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: sh * 0.014),
      padding: EdgeInsets.all(sw * 0.048),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(sw * 0.050),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
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
                style: GoogleFonts.inter(
                  fontSize: sw * 0.038,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '${spent.toStringAsFixed(0)} / ${limit.toStringAsFixed(0)}',
                style: GoogleFonts.montserrat(
                  fontSize: sw * 0.033,
                  fontWeight: FontWeight.w600,
                  color: barColor,
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.012),
          ClipRRect(
            borderRadius: BorderRadius.circular(sw * 0.020),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: sh * 0.007,
              backgroundColor: Colors.white.withValues(alpha: 0.10),
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
