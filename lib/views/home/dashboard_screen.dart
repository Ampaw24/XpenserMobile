import 'dart:ui';

import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/theme/colors.dart';
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
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    final settings = ref.watch(settingsProvider);
    final accounts = ref.watch(accountProvider);
    final totalBalance = accounts.balances.values.fold(0.0, (a, b) => a + b);
    final insights = ref.watch(insightsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      floatingActionButton: _AddFab(sw: sw, sh: sh),
      body: Stack(
        children: [
          // Subtle background orb — top left
          Positioned(
            top: -sh * 0.06,
            left: -sw * 0.18,
            child: Container(
              width: sw * 0.65,
              height: sw * 0.65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.PRIMARY.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Subtle orb — bottom right
          Positioned(
            bottom: sh * 0.18,
            right: -sw * 0.20,
            child: Container(
              width: sw * 0.55,
              height: sw * 0.55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1DE9B6).withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
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

                SliverToBoxAdapter(child: SizedBox(height: sh * 0.022)),

                // ── Balance card ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: BalanceCard(
                    totalBalance: totalBalance,
                    currency: settings.preferredCurrency,
                    monthlyIncome: insights.monthlyIncome,
                    monthlyExpense: insights.monthlyExpense,
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: sh * 0.026)),

                // ── Quick actions ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: QuickActionsRow(
                    onAddExpense: () => context.push('/transactions/add'),
                    onAddIncome: () => context.push('/transactions/add'),
                    onTransfer: () => context.push('/transactions/add'),
                    onSavings: () => context.push('/savings'),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: sh * 0.030)),

                // ── Spending chart ────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
                    child: _SectionHeader(title: 'Spending (7 days)', sw: sw),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: sh * 0.014)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
                    child: const SpendingChart(),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: sh * 0.030)),

                // ── Recent transactions ───────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
                    child: _SectionHeader(
                      title: 'Recent Transactions',
                      trailingLabel: 'See all',
                      onTrailingTap: () => context.go('/shell/transactions'),
                      sw: sw,
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: sh * 0.014)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
                    child: const RecentTransactionsSection(),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: sh * 0.030)),

                // ── Budget overview ───────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
                    child: const BudgetProgressSection(),
                  ),
                ),

                // Bottom padding — nav bar clearance
                SliverToBoxAdapter(child: SizedBox(height: sh * 0.14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.sw,
    this.trailingLabel,
    this.onTrailingTap,
  });

  final String title;
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;
  final double sw;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: sw * 0.042,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        if (trailingLabel != null)
          GestureDetector(
            onTap: onTrailingTap,
            child: Text(
              trailingLabel!,
              style: GoogleFonts.inter(
                fontSize: sw * 0.033,
                color: AppColors.ACCENT,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Floating action button ─────────────────────────────────────────────────────

class _AddFab extends StatelessWidget {
  const _AddFab({required this.sw, required this.sh});

  final double sw, sh;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/transactions/add'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(sw * 0.042),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: sw * 0.145,
            height: sw * 0.145,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.PRIMARY, AppColors.ACCENT],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(sw * 0.042),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ACCENT.withValues(alpha: 0.40),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            ),
            child: Center(
              child: HugeIcon(
                icon: AppIcons.add,
                color: Colors.white,
                size: sw * 0.062,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
