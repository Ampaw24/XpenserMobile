import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/widgets/app_empty_state.dart';
import 'package:expenser/core/utils/widgets/app_primary_button.dart';
import 'package:expenser/core/utils/widgets/app_surface_card.dart';
import 'package:expenser/core/utils/widgets/transaction_tile.dart';
import 'package:expenser/data/repositories/account_repository.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/models/budget_period.dart';
import 'package:expenser/models/transaction_model.dart';
import 'package:expenser/viewmodels/budget_viewmodel.dart';
import 'package:expenser/viewmodels/transaction_viewmodel.dart';
import 'package:expenser/views/budgets/widgets/budget_allocation_row.dart';
import 'package:expenser/views/budgets/widgets/budget_actions.dart';
import 'package:expenser/views/budgets/widgets/budget_labels.dart';
import 'package:expenser/views/budgets/widgets/budget_progress_bar.dart';
import 'package:expenser/core/utils/widgets/brand_watermark_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BudgetPlanDetailScreen extends ConsumerWidget {
  const BudgetPlanDetailScreen({super.key, required this.planId});

  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(budgetProvider.select((s) => s.planById(planId)));
    if (plan == null) {
      // Deleted from this screen and now animating out.
      if (!(ModalRoute.of(context)?.isCurrent ?? true)) return const Scaffold();
      return Scaffold(
        appBar: AppBar(),
        body: BrandWatermarkBackground(
          child: const AppEmptyState(
            icon: Icons.pie_chart_outline_rounded,
            title: 'Budget not found',
            message: 'It may have been deleted on another device.',
          ),
        ),
      );
    }

    final transactions = ref.watch(budgetPlanTransactionsProvider(planId));
    final gutter = context.contentGutter;

    return Scaffold(
      appBar: AppBar(
        title: Text('${plan.period.label} budget'),
        actions: [
          IconButton(
            tooltip: 'Edit budget',
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => context.push('/budgets/plan/$planId/edit'),
          ),
          IconButton(
            tooltip: 'Delete budget',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      body: BrandWatermarkBackground(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(gutter, context.rs(8), gutter, 0),
              sliver: SliverList.list(
                children: [
                  _SummaryCard(plan: plan),
                  SizedBox(height: context.rs(12)),
                  _LifecycleActions(plan: plan),
                  _SectionLabel('Categories'),
                  AppSurfaceCard(
                    child: Column(
                      children: [
                        for (var i = 0; i < plan.allocations.length; i++) ...[
                          if (i > 0) SizedBox(height: context.rs(14)),
                          BudgetAllocationRow(
                            plan: plan,
                            allocation: plan.allocations[i],
                            showDecimals: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                  _SectionLabel('Spending in this budget'),
                  if (transactions.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: context.rs(16)),
                      child: Text(
                        'No expenses in these categories yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: context.rs(13),
                          color: context.palette.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                gutter,
                0,
                gutter,
                context.rs(24) + MediaQuery.paddingOf(context).bottom,
              ),
              sliver: SliverList.separated(
                itemCount: transactions.length,
                separatorBuilder: (_, __) => SizedBox(height: context.rs(8)),
                itemBuilder:
                    (context, i) =>
                        _TransactionItem(transaction: transactions[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    if (!await confirmBudgetDelete(context) || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final deletion = deleteBudgetWithUndo(
      ref: ref,
      messenger: messenger,
      planId: planId,
    );
    context.pop();
    await deletion;
  }
}

class _SummaryCard extends ConsumerWidget {
  const _SummaryCard({required this.plan});

  final BudgetPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final now = DateTime.now();
    final barColor = budgetUsageColor(
      palette,
      usage: plan.usage,
      warningAt: plan.alertThreshold,
      normal: palette.accent,
    );
    final accountName =
        plan.accountId == null
            ? null
            : ref
                .read(accountRepositoryProvider)
                .getById(plan.accountId!)
                ?.name;
    final isOver = plan.remaining < 0;

    return AppSurfaceCard(
      padding: EdgeInsets.all(context.rs(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [
              budgetRangeLabel(plan),
              budgetStatusLabel(plan, now),
            ].join('  ·  '),
            style: TextStyle(
              fontSize: context.rs(12),
              color: palette.textSecondary,
            ),
          ),
          SizedBox(height: context.rs(10)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                text: budgetMoney(plan.currency, plan.totalSpent),
                style: TextStyle(
                  fontSize: context.rs(24),
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                ),
                children: [
                  TextSpan(
                    text: '  of ${budgetMoney(plan.currency, plan.totalLimit)}',
                    style: TextStyle(
                      fontSize: context.rs(14),
                      fontWeight: FontWeight.w500,
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: context.rs(12)),
          BudgetProgressBar(
            usage: plan.usage,
            color: barColor,
            height: context.rs(8),
          ),
          SizedBox(height: context.rs(10)),
          Text(
            isOver
                ? '${budgetMoney(plan.currency, -plan.remaining)} over budget'
                : plan.isFinished(now)
                ? '${budgetMoney(plan.currency, plan.remaining)} unspent'
                : '${budgetMoney(plan.currency, plan.remaining)} left to spend',
            style: TextStyle(
              fontSize: context.rs(13),
              fontWeight: FontWeight.w600,
              color: isOver ? palette.danger : palette.textPrimary,
            ),
          ),
          SizedBox(height: context.rs(4)),
          Text(
            accountName != null
                ? 'Counts expenses from $accountName · '
                    'alerts at ${(plan.alertThreshold * 100).round()}%'
                : 'Counts expenses from all accounts · '
                    'alerts at ${(plan.alertThreshold * 100).round()}%',
            style: TextStyle(
              fontSize: context.rs(12),
              color: palette.textMuted,
            ),
          ),
          if (plan.notes != null && plan.notes!.isNotEmpty) ...[
            SizedBox(height: context.rs(12)),
            Text(
              plan.notes!,
              style: TextStyle(
                fontSize: context.rs(13),
                color: palette.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Close for running plans (prominent once fully used); Reopen and Renew
/// for finished ones.
class _LifecycleActions extends ConsumerWidget {
  const _LifecycleActions({required this.plan});

  final BudgetPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final now = DateTime.now();

    if (plan.isFinished(now)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (plan.status(now) == BudgetStatus.closed)
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Closed early. Spending after closing isn't counted.",
                    style: TextStyle(
                      fontSize: context.rs(12),
                      color: palette.textSecondary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed:
                      () => ref
                          .read(budgetProvider.notifier)
                          .reopenPlan(plan.planId),
                  child: const Text('Reopen'),
                ),
              ],
            ),
          _RenewAction(plan: plan),
        ],
      );
    }

    void close() => closeBudgetWithUndo(context, ref, plan.planId);
    if (!plan.isFullyUsed) {
      return OutlinedButton.icon(
        onPressed: close,
        icon: Icon(Icons.lock_outline_rounded, size: context.rs(18)),
        label: const Text('Close budget'),
      );
    }

    final overspent = plan.remaining < 0;
    return AppSurfaceCard(
      color: palette.warning.withValues(alpha: 0.08),
      borderColor: palette.warning.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.flag_rounded,
                color: palette.warning,
                size: context.rs(20),
              ),
              SizedBox(width: context.rs(8)),
              Expanded(
                child: Text(
                  overspent ? 'Budget overspent' : 'Budget fully used',
                  style: TextStyle(
                    fontSize: context.rs(15),
                    fontWeight: FontWeight.w700,
                    color: palette.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.rs(6)),
          Text(
            overspent
                ? "You've spent ${budgetMoney(plan.currency, -plan.remaining)} "
                    'more than the ${budgetMoney(plan.currency, plan.totalLimit)} '
                    'allocated. Close it to stop tracking new spending.'
                : 'The whole ${budgetMoney(plan.currency, plan.totalLimit)} '
                    'has been spent. Close it to stop tracking, or keep it '
                    'open to see any overspending.',
            style: TextStyle(
              fontSize: context.rs(13),
              color: palette.textSecondary,
            ),
          ),
          SizedBox(height: context.rs(12)),
          AppPrimaryButton(label: 'Close budget', onPressed: close),
        ],
      ),
    );
  }
}

class _RenewAction extends ConsumerWidget {
  const _RenewAction({required this.plan});

  final BudgetPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRenewed = ref.watch(
      budgetProvider.select((s) => s.isRenewed(plan, DateTime.now())),
    );
    if (isRenewed) {
      return Text(
        'This budget has already been renewed.',
        style: TextStyle(
          fontSize: context.rs(12),
          color: context.palette.textMuted,
        ),
      );
    }
    return AppPrimaryButton(
      label: 'Renew budget',
      onPressed: () async {
        final newPlanId = await ref
            .read(budgetProvider.notifier)
            .renewPlan(plan.planId);
        if (newPlanId == null || !context.mounted) return;
        context.pushReplacement('/budgets/plan/$newPlanId');
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: context.rs(22), bottom: context.rs(10)),
      child: Text(
        text,
        style: TextStyle(
          fontSize: context.rs(15),
          fontWeight: FontWeight.w700,
          color: context.palette.textPrimary,
        ),
      ),
    );
  }
}

class _TransactionItem extends ConsumerWidget {
  const _TransactionItem({required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref
        .read(categoryRepositoryProvider)
        .getById(transaction.categoryId);
    return TransactionTile(
      transaction: transaction,
      categoryName: category?.name ?? 'Unknown',
      categoryColor: category?.colorHex ?? 'FF78909C',
      categoryIconCode:
          category?.iconCodePoint ?? Icons.category_rounded.codePoint,
      onEdit: () => context.push('/transactions/${transaction.id}/edit'),
      onDelete:
          () => ref
              .read(transactionProvider.notifier)
              .deleteTransaction(transaction.id),
    );
  }
}
