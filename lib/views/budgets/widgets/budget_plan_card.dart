import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/widgets/app_surface_card.dart';
import 'package:expenser/data/repositories/account_repository.dart';
import 'package:expenser/models/budget_period.dart';
import 'package:expenser/viewmodels/budget_viewmodel.dart';
import 'package:expenser/views/budgets/widgets/budget_allocation_row.dart';
import 'package:expenser/views/budgets/widgets/budget_actions.dart';
import 'package:expenser/views/budgets/widgets/budget_labels.dart';
import 'package:expenser/views/budgets/widgets/budget_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Running or upcoming plan: totals, status and per-category progress.
/// Tap opens the detail screen; swipe left deletes after confirmation.
class BudgetPlanCard extends ConsumerWidget {
  const BudgetPlanCard({super.key, required this.plan});

  final BudgetPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final now = DateTime.now();
    final isUpcoming = plan.status(now) == BudgetStatus.upcoming;
    final barColor = budgetUsageColor(
      palette,
      usage: plan.usage,
      warningAt: plan.alertThreshold,
      normal: palette.accent,
    );

    return _DeletableBudget(
      planId: plan.planId,
      child: AppSurfaceCard(
        onTap: () => context.push('/budgets/plan/${plan.planId}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PlanHeading(plan: plan),
            SizedBox(height: context.rs(6)),
            Row(
              children: [
                Expanded(
                  child: Text(
                    budgetMoney(plan.currency, plan.totalLimit),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: context.rs(18),
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: context.rs(8)),
                _UsageBadge(
                  label:
                      isUpcoming
                          ? 'Upcoming'
                          : plan.isFullyUsed
                          ? (plan.remaining < 0 ? 'Over budget' : 'Fully used')
                          : _percent(plan.usage),
                  color: isUpcoming ? palette.info : barColor,
                ),
              ],
            ),
            SizedBox(height: context.rs(12)),
            BudgetProgressBar(
              usage: plan.usage,
              color: barColor,
              height: context.rs(6),
            ),
            SizedBox(height: context.rs(8)),
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.remaining >= 0
                        ? '${budgetMoney(plan.currency, plan.remaining)} left'
                        : '${budgetMoney(plan.currency, -plan.remaining)} over',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: context.rs(12),
                      fontWeight: FontWeight.w500,
                      color:
                          plan.remaining >= 0
                              ? palette.textSecondary
                              : palette.danger,
                    ),
                  ),
                ),
                Text(
                  budgetStatusLabel(plan, now),
                  style: TextStyle(
                    fontSize: context.rs(12),
                    color: palette.textMuted,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.rs(14)),
            for (final allocation in plan.allocations)
              Padding(
                padding: EdgeInsets.only(bottom: context.rs(10)),
                child: BudgetAllocationRow(plan: plan, allocation: allocation),
              ),
          ],
        ),
      ),
    );
  }
}

/// Compact card for a finished plan with its final result and Renew.
class EndedBudgetCard extends ConsumerWidget {
  const EndedBudgetCard({
    super.key,
    required this.plan,
    required this.isRenewed,
    required this.onRenew,
  });

  final BudgetPlan plan;
  final bool isRenewed;
  final VoidCallback onRenew;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final wasOver = plan.remaining < 0;
    final status = budgetStatusLabel(plan, DateTime.now());
    final result =
        wasOver
            ? 'Went over by ${budgetMoney(plan.currency, -plan.remaining)}'
            : plan.isFullyUsed
            ? 'Fully used'
            : 'Stayed within budget';

    return _DeletableBudget(
      planId: plan.planId,
      child: AppSurfaceCard(
        onTap: () => context.push('/budgets/plan/${plan.planId}'),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PlanHeading(plan: plan, trailing: status),
                  SizedBox(height: context.rs(4)),
                  Text(
                    '${budgetMoney(plan.currency, plan.totalSpent)} of '
                    '${budgetMoney(plan.currency, plan.totalLimit)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: context.rs(14),
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                  ),
                  SizedBox(height: context.rs(2)),
                  Text(
                    result,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: context.rs(12),
                      color: wasOver ? palette.danger : palette.success,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: context.rs(10)),
            isRenewed
                ? Text(
                  'Renewed',
                  style: TextStyle(
                    fontSize: context.rs(12),
                    fontWeight: FontWeight.w600,
                    color: palette.textMuted,
                  ),
                )
                : OutlinedButton.icon(
                  onPressed: onRenew,
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(0, context.rs(40)),
                    padding: EdgeInsets.symmetric(horizontal: context.rs(14)),
                  ),
                  icon: Icon(Icons.autorenew_rounded, size: context.rs(16)),
                  label: const Text('Renew'),
                ),
          ],
        ),
      ),
    );
  }
}

String _percent(double usage) => '${(usage * 100).toStringAsFixed(0)}%';

/// "Monthly · Nov 1 – 30, 2026 · Main account"
class _PlanHeading extends ConsumerWidget {
  const _PlanHeading({required this.plan, this.trailing});

  final BudgetPlan plan;

  /// Replaces the date range and account, e.g. "Closed Nov 13".
  final String? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountName =
        plan.accountId == null
            ? null
            : ref
                .read(accountRepositoryProvider)
                .getById(plan.accountId!)
                ?.name;
    final parts = [
      plan.period.label,
      if (trailing != null) trailing!,
      if (trailing == null) budgetRangeLabel(plan),
      if (trailing == null && accountName != null) accountName,
    ];
    return Text(
      parts.join('  ·  '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: context.rs(12),
        color: context.palette.textSecondary,
      ),
    );
  }
}

class _UsageBadge extends StatelessWidget {
  const _UsageBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.rs(11),
        vertical: context.rs(5),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(context.rs(16)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: context.rs(12),
        ),
      ),
    );
  }
}

class _DeletableBudget extends ConsumerWidget {
  const _DeletableBudget({required this.planId, required this.child});

  final String planId;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    return Dismissible(
      key: ValueKey('budget-$planId'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmBudgetDelete(context),
      onDismissed:
          (_) => deleteBudgetWithUndo(
            ref: ref,
            messenger: ScaffoldMessenger.of(context),
            planId: planId,
          ),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: context.rs(20)),
        decoration: BoxDecoration(
          color: palette.danger,
          borderRadius: BorderRadius.circular(context.rs(18)),
        ),
        child: Icon(
          Icons.delete_rounded,
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      child: child,
    );
  }
}
