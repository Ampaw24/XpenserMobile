import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/constants/branding.dart';
import 'package:expenser/viewmodels/account_viewmodel.dart';
import 'package:expenser/viewmodels/insights_viewmodel.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:expenser/views/home/widgets/balance_card.dart';
import 'package:expenser/views/home/widgets/budget_progress_section.dart';
import 'package:expenser/views/home/widgets/dashboard_header.dart';
import 'package:expenser/views/home/widgets/quick_actions_row.dart';
import 'package:expenser/views/home/widgets/recent_transactions_section.dart';
import 'package:expenser/views/home/widgets/spending_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sw = MediaQuery.of(context).size.width;

    final settings = ref.watch(settingsProvider);
    final accounts = ref.watch(accountProvider);
    final totalBalance = accounts.balances.values.fold(0.0, (a, b) => a + b);
    final insights = ref.watch(insightsProvider);

    return Scaffold(
      floatingActionButton: const _AddFab(),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: DashboardHeader(
                userName: settings.userName,
                profilePicUrl: settings.userAvatarPath ?? 's',
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 18)),

            // ── Balance card ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: BalanceCard(
                totalBalance: totalBalance,
                currency: settings.preferredCurrency,
                monthlyIncome: insights.monthlyIncome,
                monthlyExpense: insights.monthlyExpense,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Quick actions ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: QuickActionsRow(
                onAddExpense: () => context.push('/transactions/add'),
                onAddIncome: () => context.push('/transactions/add'),
                onTransfer: () => context.push('/transactions/add'),
                onSavings: () => context.push('/savings'),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Spending chart ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                child: const _SectionHeader(title: 'Spending (7 days)'),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                child: const SpendingChart(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Recent transactions ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                child: _SectionHeader(
                  title: 'Recent Transactions',
                  trailingLabel: 'See all',
                  onTrailingTap: () => context.go('/shell/transactions'),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                child: const RecentTransactionsSection(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Budget overview ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                child: const BudgetProgressSection(),
              ),
            ),

            // Bottom padding for nav bar clearance
            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.trailingLabel,
    this.onTrailingTap,
  });

  final String title;
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppBrand.textPrimaryDark : AppBrand.textPrimaryLight;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        if (trailingLabel != null)
          GestureDetector(
            onTap: onTrailingTap,
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
    );
  }
}

// ── Floating action button ─────────────────────────────────────────────────────

class _AddFab extends StatefulWidget {
  const _AddFab();

  @override
  State<_AddFab> createState() => _AddFabState();
}

class _AddFabState extends State<_AddFab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () => context.push('/transactions/add'),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: AppBrand.tealPrimary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppBrand.tealPrimary.withValues(alpha: isDark ? 0.35 : 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: HugeIcon(
              icon: AppIcons.add,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
