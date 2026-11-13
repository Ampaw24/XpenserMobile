import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:expenser/core/utils/formatters/date_labels.dart';
import 'package:expenser/models/consolidated_balance.dart';
import 'package:expenser/viewmodels/consolidated_balance_viewmodel.dart';
import 'package:expenser/viewmodels/insights_viewmodel.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:expenser/views/home/widgets/balance_card.dart';
import 'package:expenser/views/home/widgets/budget_progress_section.dart';
import 'package:expenser/views/home/widgets/dashboard_header.dart';
import 'package:expenser/views/home/widgets/quick_actions_row.dart';
import 'package:expenser/views/home/widgets/recent_transactions_section.dart';
import 'package:expenser/views/home/widgets/section_header.dart';
import 'package:expenser/views/home/widgets/spending_chart.dart';
import 'package:expenser/core/utils/widgets/brand_watermark_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(settingsProvider.select((s) => s.userName));
    final photoUrl = ref.watch(
      settingsProvider.select((s) => s.userAvatarPath),
    );
    final balance = ref.watch(consolidatedBalanceProvider);
    final insights = ref.watch(insightsProvider);

    final pinnedSection = [
      DashboardHeader(userName: userName, photoUrl: photoUrl),
      SizedBox(height: context.rs(20)),
      BalanceCard(
        totalBalance: balance.total,
        currency: balance.currency,
        footnote: _balanceFootnote(balance),
        footnoteIsWarning: balance.isPartial || balance.ratesStale,
        monthlyIncome: insights.monthlyIncome,
        monthlyExpense: insights.monthlyExpense,
        spendingTrendPercent:
            insights.previousMonthExpense > 0 ? insights.trendPercentage : null,
        onAnalyticsTap: () => context.go('/shell/budgets'),
      ),
      SizedBox(height: context.rs(20)),
      QuickActionsRow(
        onAddIncome: () => _addTransaction(context, TransactionType.income),
        onAddExpense: () => _addTransaction(context, TransactionType.expense),
        onTransfer: () => _addTransaction(context, TransactionType.transfer),
        onSavings: () => context.push('/savings'),
      ),
      SizedBox(height: context.rs(16)),
    ];

    return Scaffold(
      body: BrandWatermarkBackground(
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Short viewports (small phones, landscape) can't fit a pinned
              // top section plus a usable list, so the whole page scrolls there.
              final textScale = MediaQuery.textScalerOf(
                context,
              ).scale(1).clamp(1.0, 2.0);
              final minPinnedHeight =
                  context.rs(620) + context.rs(160) * (textScale - 1);
              final canPinTop = constraints.maxHeight >= minPinnedHeight;
              if (!canPinTop) {
                return _ScrollRegion(
                  children: [...pinnedSection, ..._scrollableSection(context)],
                );
              }
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.contentGutter,
                      context.rs(12),
                      context.contentGutter,
                      0,
                    ),
                    child: Column(children: pinnedSection),
                  ),
                  Expanded(
                    child: _ScrollRegion(
                      topPadding: 0,
                      children: _scrollableSection(context),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _scrollableSection(BuildContext context) {
    final sectionGap = SizedBox(height: context.rs(24));
    final headerGap = SizedBox(height: context.rs(12));

    return [
      SectionHeader(
        title: 'Recent Transactions',
        onSeeAll: () => context.go('/shell/transactions'),
      ),
      headerGap,
      const RecentTransactionsSection(),
      sectionGap,
      const SectionHeader(title: 'Spending Trend · 7 days'),
      headerGap,
      const SpendingChart(),
      sectionGap,
      const BudgetProgressSection(),
    ];
  }

  String? _balanceFootnote(ConsolidatedBalance balance) {
    if (balance.isPartial) {
      return 'Excludes ${balance.unconverted.keys.join(', ')} balances · '
          'exchange rates unavailable';
    }
    if (!balance.isEstimate) return null;
    final updated = balance.ratesUpdatedAt;
    final asOf = updated == null ? '' : ' · ${relativeDateTimeLabel(updated)}';
    final currencies = balance.convertedCurrencies.join(', ');
    return balance.ratesStale
        ? '≈ $currencies converted at offline rates$asOf'
        : '≈ $currencies converted at mid-market rates$asOf';
  }

  void _addTransaction(BuildContext context, TransactionType type) =>
      context.push('/transactions/add?type=${type.name}');
}

class _ScrollRegion extends StatelessWidget {
  const _ScrollRegion({required this.children, this.topPadding});

  final List<Widget> children;

  /// Defaults to the standard page top spacing when null.
  final double? topPadding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        context.contentGutter,
        topPadding ?? context.rs(12),
        context.contentGutter,
        context.rs(24),
      ),
      children: children,
    );
  }
}
