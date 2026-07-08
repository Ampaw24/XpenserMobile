import 'dart:ui';

import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:expenser/viewmodels/budget_viewmodel.dart';
import 'package:expenser/viewmodels/insights_viewmodel.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:expenser/viewmodels/transaction_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _headerCtrl;
  late final AnimationController _cardCtrl;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;

  int _touchedPieIndex = -1;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _headerFade = CurvedAnimation(
      parent: _headerCtrl,
      curve: Curves.easeOut,
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));

    _cardFade = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut));

    _headerCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _cardCtrl.forward();
    });
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    final settings = ref.watch(settingsProvider);
    final insights = ref.watch(insightsProvider);
    final txState = ref.watch(transactionProvider);
    final categoryRepo = ref.read(categoryRepositoryProvider);

    final currency = settings.preferredCurrency;
    final userName = settings.userName.isNotEmpty
        ? settings.userName.split(' ').first
        : 'there';

    final balance = insights.monthlyIncome - insights.monthlyExpense;
    final recentTxs = txState.transactions.take(5).toList();

    final budgetState = ref.watch(budgetProvider);
    final activePlans = budgetState.plans.take(3).toList();

    // Build chart data from spendingByCategory
    final spendingEntries = insights.spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = spendingEntries.take(5).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_home',
        backgroundColor: AppColors.ACCENT,
        onPressed: () => context.push('/transactions/add'),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _headerFade,
              child: SlideTransition(
                position: _headerSlide,
                child: _buildHeader(sw, sh, userName),
              ),
            ),
          ),

          // ── Balance card ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _cardFade,
              child: SlideTransition(
                position: _cardSlide,
                child: _buildBalanceCard(
                  sw, sh, currency, balance,
                  insights.monthlyIncome, insights.monthlyExpense,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: sh * 0.024)),

          // ── Category chart ───────────────────────────────────────────────
          if (top5.isNotEmpty)
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _cardFade,
                child: _buildSpendingChart(sw, sh, top5, categoryRepo, currency),
              ),
            ),

          if (top5.isNotEmpty)
            SliverToBoxAdapter(child: SizedBox(height: sh * 0.024)),

          // ── Budget Overview ───────────────────────────────────────────────
          if (activePlans.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _cardFade,
                child: _buildBudgetOverview(
                  sw, sh, activePlans, budgetState, currency, categoryRepo,
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: sh * 0.024)),
          ],

          // ── Recent transactions header ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: GoogleFonts.montserrat(
                      fontSize: sw * 0.042,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/shell/transactions'),
                    child: Text(
                      'See all',
                      style: GoogleFonts.inter(
                        fontSize: sw * 0.032,
                        color: AppColors.ACCENT,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: sh * 0.012)),

          // ── Recent transactions list ──────────────────────────────────────
          if (recentTxs.isEmpty)
            SliverToBoxAdapter(
              child: _buildEmptyTransactions(sw, sh),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final t = recentTxs[i];
                  final category = categoryRepo.getById(t.categoryId);
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      sw * 0.06, 0, sw * 0.06, sh * 0.008,
                    ),
                    child: _DashboardTxTile(
                      transaction: t,
                      categoryName: category?.name ?? 'Unknown',
                      categoryColor: category?.colorHex ?? 'FF78909C',
                      categoryIconCode:
                          category?.iconCodePoint ??
                          Icons.category_rounded.codePoint,
                      currency: currency,
                      sw: sw,
                      sh: sh,
                    ),
                  );
                },
                childCount: recentTxs.length,
              ),
            ),

          // Bottom padding for FAB
          SliverToBoxAdapter(child: SizedBox(height: sh * 0.14)),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(double sw, double sh, String userName) {
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Padding(
      padding: EdgeInsets.fromLTRB(sw * 0.06, sh * 0.06, sw * 0.06, sh * 0.020),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: GoogleFonts.inter(
                    fontSize: sw * 0.034,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                SizedBox(height: sh * 0.004),
                Text(
                  '$userName 👋',
                  style: GoogleFonts.montserrat(
                    fontSize: sw * 0.054,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Avatar / notification button
          GestureDetector(
            onTap: () => context.go('/shell/settings'),
            child: Container(
              width: sw * 0.11,
              height: sw * 0.11,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.PRIMARY, AppColors.ACCENT],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(sw * 0.035),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ACCENT.withValues(alpha: 0.40),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  ref.read(settingsProvider).userName.isNotEmpty
                      ? ref.read(settingsProvider).userName[0].toUpperCase()
                      : 'U',
                  style: GoogleFonts.montserrat(
                    fontSize: sw * 0.042,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Balance card ─────────────────────────────────────────────────────────
  Widget _buildBalanceCard(
    double sw,
    double sh,
    String currency,
    double balance,
    double income,
    double expense,
  ) {
    final fmt = NumberFormat.currency(symbol: '$currency ', decimalDigits: 2);
    final isPositive = balance >= 0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(sw * 0.065),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.all(sw * 0.06),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF004D40), Color(0xFF00796B), Color(0xFF009688)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(sw * 0.065),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.PRIMARY.withValues(alpha: 0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative orbs
                Positioned(
                  right: -sw * 0.08,
                  top: -sw * 0.08,
                  child: Container(
                    width: sw * 0.38,
                    height: sw * 0.38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Positioned(
                  right: sw * 0.06,
                  bottom: -sw * 0.05,
                  child: Container(
                    width: sw * 0.22,
                    height: sw * 0.22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Net Balance — This Month',
                      style: GoogleFonts.inter(
                        fontSize: sw * 0.030,
                        color: Colors.white.withValues(alpha: 0.70),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: sh * 0.008),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          fmt.format(balance.abs()),
                          style: GoogleFonts.montserrat(
                            fontSize: sw * 0.072,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(width: sw * 0.02),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.022,
                            vertical: sh * 0.004,
                          ),
                          decoration: BoxDecoration(
                            color: isPositive
                                ? Colors.greenAccent.withValues(alpha: 0.20)
                                : Colors.redAccent.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPositive
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                color: isPositive
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                                size: sw * 0.036,
                              ),
                              SizedBox(width: sw * 0.01),
                              Text(
                                isPositive ? 'Surplus' : 'Deficit',
                                style: GoogleFonts.inter(
                                  fontSize: sw * 0.028,
                                  fontWeight: FontWeight.w600,
                                  color: isPositive
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sh * 0.024),
                    Row(
                      children: [
                        Expanded(
                          child: _BalanceStat(
                            label: 'Income',
                            amount: fmt.format(income),
                            icon: Icons.arrow_downward_rounded,
                            color: Colors.greenAccent,
                            sw: sw,
                            sh: sh,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: sh * 0.045,
                          color: Colors.white.withValues(alpha: 0.20),
                        ),
                        Expanded(
                          child: _BalanceStat(
                            label: 'Expenses',
                            amount: fmt.format(expense),
                            icon: Icons.arrow_upward_rounded,
                            color: Colors.redAccent,
                            sw: sw,
                            sh: sh,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Spending chart ────────────────────────────────────────────────────────
  Widget _buildSpendingChart(
    double sw,
    double sh,
    List<MapEntry<String, double>> top5,
    dynamic categoryRepo,
    String currency,
  ) {
    final total = top5.fold(0.0, (s, e) => s + e.value);
    final fmt = NumberFormat.currency(symbol: '$currency ', decimalDigits: 0);

    final chartColors = [
      const Color(0xFF26C6DA),
      const Color(0xFFAB47BC),
      const Color(0xFFFF7043),
      const Color(0xFF66BB6A),
      const Color(0xFFFFCA28),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(sw * 0.055),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: EdgeInsets.all(sw * 0.055),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(sw * 0.055),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Spending by Category',
                  style: GoogleFonts.montserrat(
                    fontSize: sw * 0.040,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'This month',
                  style: GoogleFonts.inter(
                    fontSize: sw * 0.028,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
                SizedBox(height: sh * 0.022),
                Row(
                  children: [
                    // Pie chart
                    SizedBox(
                      width: sw * 0.38,
                      height: sw * 0.38,
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    response == null ||
                                    response.touchedSection == null) {
                                  _touchedPieIndex = -1;
                                  return;
                                }
                                _touchedPieIndex = response
                                    .touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          startDegreeOffset: -90,
                          sectionsSpace: 3,
                          centerSpaceRadius: sw * 0.09,
                          sections: List.generate(top5.length, (i) {
                            final isTouched = i == _touchedPieIndex;
                            final pct = top5[i].value / total;
                            return PieChartSectionData(
                              value: top5[i].value,
                              color: chartColors[i % chartColors.length],
                              radius: isTouched ? sw * 0.095 : sw * 0.078,
                              title: '${(pct * 100).toStringAsFixed(0)}%',
                              titleStyle: GoogleFonts.inter(
                                fontSize: isTouched ? sw * 0.028 : sw * 0.022,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.04),
                    // Legend
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(top5.length, (i) {
                          final entry = top5[i];
                          final cat = categoryRepo.getById(entry.key);
                          final name = cat?.name ?? 'Other';
                          final color = chartColors[i % chartColors.length];
                          final isTouched = i == _touchedPieIndex;
                          return Padding(
                            padding: EdgeInsets.only(bottom: sh * 0.010),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(
                                horizontal: isTouched ? sw * 0.022 : 0,
                                vertical: isTouched ? sh * 0.006 : 0,
                              ),
                              decoration: BoxDecoration(
                                color: isTouched
                                    ? color.withValues(alpha: 0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: sw * 0.022,
                                    height: sw * 0.022,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: sw * 0.020),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: GoogleFonts.inter(
                                            fontSize: sw * 0.028,
                                            fontWeight: isTouched
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          fmt.format(entry.value),
                                          style: GoogleFonts.inter(
                                            fontSize: sw * 0.024,
                                            color: Colors.white
                                                .withValues(alpha: 0.50),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildBudgetOverview(
    double sw,
    double sh,
    List<BudgetPlan> plans,
    BudgetState budgetState,
    String currency,
    dynamic categoryRepo,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(sw * 0.055),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: EdgeInsets.all(sw * 0.055),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(sw * 0.055),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Budget Overview',
                      style: GoogleFonts.montserrat(
                        fontSize: sw * 0.040,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/shell/budgets'),
                      child: Text(
                        'Manage',
                        style: GoogleFonts.inter(
                          fontSize: sw * 0.030,
                          color: AppColors.ACCENT,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sh * 0.018),
                ...plans.map((plan) {
                  final pct = plan.spentPercent(budgetState.spent);
                  final spent = plan.totalSpent(budgetState.spent);
                  final limit = plan.totalLimit;
                  final fmt = NumberFormat.currency(
                    symbol: '$currency ', decimalDigits: 0,
                  );

                  // Determine color: green < 60%, yellow 60-85%, red > 85%
                  final barColor = pct < 0.60
                      ? const Color(0xFF00E676)
                      : pct < 0.85
                          ? const Color(0xFFFFCA28)
                          : const Color(0xFFFF5252);

                  // Label: use first category name or plan notes
                  final firstCat = plan.allocations.isNotEmpty
                      ? categoryRepo.getById(plan.allocations.first.categoryId)
                      : null;
                  final label = plan.allocations.length == 1
                      ? (firstCat?.name ?? 'Budget')
                      : (plan.notes ?? 'Budget Plan');

                  return Padding(
                    padding: EdgeInsets.only(bottom: sh * 0.016),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              label,
                              style: GoogleFonts.inter(
                                fontSize: sw * 0.034,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: fmt.format(spent),
                                    style: GoogleFonts.inter(
                                      fontSize: sw * 0.030,
                                      fontWeight: FontWeight.w700,
                                      color: barColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' / ${fmt.format(limit)}',
                                    style: GoogleFonts.inter(
                                      fontSize: sw * 0.028,
                                      color: Colors.white.withValues(alpha: 0.45),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: sh * 0.007),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: LinearProgressIndicator(
                            value: pct.clamp(0.0, 1.0),
                            minHeight: sh * 0.008,
                            backgroundColor: Colors.white.withValues(alpha: 0.10),
                            valueColor: AlwaysStoppedAnimation<Color>(barColor),
                          ),
                        ),
                        SizedBox(height: sh * 0.005),
                        Text(
                          '${(pct * 100).toStringAsFixed(0)}% used',
                          style: GoogleFonts.inter(
                            fontSize: sw * 0.026,
                            color: barColor.withValues(alpha: 0.80),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTransactions(double sw, double sh) {

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.06,
        vertical: sh * 0.03,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(sw * 0.055),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.06,
              vertical: sh * 0.04,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(sw * 0.055),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: sw * 0.14,
                  color: Colors.white.withValues(alpha: 0.22),
                ),
                SizedBox(height: sh * 0.012),
                Text(
                  'No transactions yet',
                  style: GoogleFonts.inter(
                    fontSize: sw * 0.038,
                    color: Colors.white.withValues(alpha: 0.40),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: sh * 0.006),
                Text(
                  'Tap the + button to log your first expense',
                  style: GoogleFonts.inter(
                    fontSize: sw * 0.030,
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _BalanceStat extends StatelessWidget {
  const _BalanceStat({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.sw,
    required this.sh,
  });

  final String label;
  final String amount;
  final IconData icon;
  final Color color;
  final double sw, sh;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: sw * 0.060,
              height: sw * 0.060,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: sw * 0.034),
            ),
            SizedBox(width: sw * 0.018),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: sw * 0.026,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                  Text(
                    amount,
                    style: GoogleFonts.montserrat(
                      fontSize: sw * 0.032,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DashboardTxTile extends StatelessWidget {
  const _DashboardTxTile({
    required this.transaction,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIconCode,
    required this.currency,
    required this.sw,
    required this.sh,
  });

  final dynamic transaction;
  final String categoryName;
  final String categoryColor;
  final int categoryIconCode;
  final String currency;
  final double sw, sh;

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    final isTransfer = transaction.type == TransactionType.transfer;
    final color = _hexToColor(categoryColor);
    final amountColor = isExpense
        ? const Color(0xFFFF5252)
        : isTransfer
            ? const Color(0xFFFFAB40)
            : const Color(0xFF00E676);
    final sign = isExpense || isTransfer ? '-' : '+';
    final fmt = NumberFormat.currency(symbol: '$currency ', decimalDigits: 2);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.042,
        vertical: sh * 0.012,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(sw * 0.040),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: sw * 0.10,
            height: sw * 0.10,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(sw * 0.028),
            ),
            child: Icon(
              IconData(categoryIconCode, fontFamily: 'MaterialIcons'),
              color: color,
              size: sw * 0.046,
            ),
          ),
          SizedBox(width: sw * 0.030),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: sw * 0.036,
                    color: Colors.white,
                  ),
                ),
                if (transaction.notes != null && transaction.notes!.isNotEmpty)
                  Text(
                    transaction.notes!,
                    style: GoogleFonts.inter(
                      fontSize: sw * 0.028,
                      color: Colors.white.withValues(alpha: 0.40),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Text(
                    DateFormat('MMM d').format(transaction.date),
                    style: GoogleFonts.inter(
                      fontSize: sw * 0.028,
                      color: Colors.white.withValues(alpha: 0.40),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '$sign${fmt.format(transaction.amount)}',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700,
              fontSize: sw * 0.036,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
