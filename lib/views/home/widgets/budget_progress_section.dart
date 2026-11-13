import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/viewmodels/budget_viewmodel.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/widgets/app_surface_card.dart';
import 'package:expenser/views/budgets/widgets/budget_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expenser/views/home/widgets/section_header.dart';

class BudgetProgressSection extends ConsumerWidget {
  const BudgetProgressSection({super.key});

  static const _maxItems = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(budgetProvider).activePlans(DateTime.now());
    final categoryRepo = ref.read(categoryRepositoryProvider);

    // Categories closest to (or over) their limit first.
    final items = [
      for (final plan in plans)
        for (final allocation in plan.allocations)
          (plan: plan, allocation: allocation),
    ]..sort(
      (a, b) => b.plan
          .usageFor(b.allocation)
          .compareTo(a.plan.usageFor(a.allocation)),
    );

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Budget Overview',
          onSeeAll: () => context.go('/shell/budgets'),
        ),
        SizedBox(height: context.rs(10)),
        for (final (:plan, :allocation) in items.take(_maxItems))
          _BudgetCard(
            categoryName:
                categoryRepo.getById(allocation.categoryId)?.name ?? 'Category',
            amountLabel:
                '${plan.currency} ${plan.spentFor(allocation).toStringAsFixed(0)}'
                ' / ${allocation.limitAmount.toStringAsFixed(0)}',
            usage: plan.usageFor(allocation),
            barColor: budgetUsageColor(
              context.palette,
              usage: plan.usageFor(allocation),
              warningAt: allocation.alertThreshold,
              normal: context.palette.accent,
            ),
            onTap: () => context.push('/budgets/plan/${plan.planId}'),
          ),
      ],
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.categoryName,
    required this.amountLabel,
    required this.usage,
    required this.barColor,
    required this.onTap,
  });

  final String categoryName;
  final String amountLabel;
  final double usage;
  final Color barColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: EdgeInsets.only(bottom: context.rs(10)),
      child: AppSurfaceCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    categoryName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: context.rs(14),
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: context.rs(8)),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      amountLabel,
                      style: TextStyle(
                        fontSize: context.rs(13),
                        fontWeight: FontWeight.w600,
                        color: barColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.rs(10)),
            BudgetProgressBar(
              usage: usage,
              color: barColor,
              height: context.rs(6),
            ),
          ],
        ),
      ),
    );
  }
}
