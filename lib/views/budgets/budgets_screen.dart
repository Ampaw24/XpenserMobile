import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/data/repositories/account_repository.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/viewmodels/budget_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final state = ref.watch(budgetProvider);
    final plans = state.plans;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    sw * 0.06, sh * 0.024, sw * 0.06, sh * 0.010),
                child: Text(
                  'Budgets',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: sw * 0.058,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (plans.isEmpty)
              SliverFillRemaining(child: _EmptyState(sw: sw, sh: sh))
            else ...[
              SliverToBoxAdapter(
                child: _OverviewCard(
                    plans: plans, state: state, sw: sw, sh: sh, ref: ref),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                    sw * 0.06, sh * 0.020, sw * 0.06, sh * 0.12),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: EdgeInsets.only(bottom: sh * 0.016),
                      child: _PlanCard(
                        plan: plans[i],
                        state: state,
                        sw: sw,
                        sh: sh,
                        ref: ref,
                      ),
                    ),
                    childCount: plans.length,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_budgets',
        backgroundColor: AppColors.PRIMARY,
        onPressed: () => context.push('/budgets/create'),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'New Budget',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─── Overview card with donut chart ──────────────────────────────────────────

class _OverviewCard extends StatefulWidget {
  final List<BudgetPlan> plans;
  final BudgetState state;
  final double sw, sh;
  final WidgetRef ref;

  const _OverviewCard({
    required this.plans,
    required this.state,
    required this.sw,
    required this.sh,
    required this.ref,
  });

  @override
  State<_OverviewCard> createState() => _OverviewCardState();
}

class _OverviewCardState extends State<_OverviewCard> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final sw = widget.sw;
    final sh = widget.sh;
    final categoryRepo = widget.ref.read(categoryRepositoryProvider);

    final totalLimit = widget.plans.fold<double>(
        0, (sum, p) => sum + p.totalLimit);
    final totalSpent = widget.plans.fold<double>(
        0, (sum, p) => sum + p.totalSpent(widget.state.spent));
    final overallPct =
        totalLimit > 0 ? (totalSpent / totalLimit).clamp(0.0, 1.0) : 0.0;
    final remaining = totalLimit - totalSpent;
    final overBudget = remaining < 0;

    // Build donut sections from all category allocations
    final allAllocations = widget.plans
        .expand((p) => p.allocations)
        .toList();

    final List<PieChartSectionData> sections = [];
    for (int i = 0; i < allAllocations.length; i++) {
      final b = allAllocations[i];
      final cat = categoryRepo.getById(b.categoryId);
      final color = cat != null
          ? Color(int.parse(cat.colorHex, radix: 16))
          : AppColors.ACCENT;
      final isTouched = i == _touchedIndex;
      sections.add(PieChartSectionData(
        value: b.limitAmount,
        color: color,
        radius: isTouched ? sw * 0.095 : sw * 0.080,
        title: isTouched && cat != null ? cat.name : '',
        titleStyle: GoogleFonts.inter(
          fontSize: sw * 0.026,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 1.6,
      ));
    }

    final Color barColor = overBudget
        ? const Color(0xFFFF5252)
        : overallPct >= 0.8
            ? const Color(0xFFFFAB40)
            : AppColors.ACCENT;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
      child: Container(
        padding: EdgeInsets.all(sw * 0.050),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.PRIMARY.withValues(alpha: 0.50),
              const Color(0xFF0A1628),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(sw * 0.050),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Donut chart
                SizedBox(
                  width: sw * 0.380,
                  height: sw * 0.380,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sections: sections.isEmpty
                              ? [
                                  PieChartSectionData(
                                    value: 1,
                                    color: Colors.white.withValues(alpha: 0.08),
                                    radius: sw * 0.080,
                                    title: '',
                                  ),
                                ]
                              : sections,
                          centerSpaceRadius: sw * 0.100,
                          sectionsSpace: sw * 0.008,
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              setState(() {
                                if (response?.touchedSection != null &&
                                    event is FlPointerHoverEvent) {
                                  _touchedIndex = response!
                                      .touchedSection!.touchedSectionIndex;
                                } else {
                                  _touchedIndex = -1;
                                }
                              });
                            },
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(overallPct * 100).toStringAsFixed(0)}%',
                            style: GoogleFonts.montserrat(
                              fontSize: sw * 0.048,
                              fontWeight: FontWeight.w700,
                              color: barColor,
                            ),
                          ),
                          Text(
                            'used',
                            style: GoogleFonts.inter(
                              fontSize: sw * 0.026,
                              color: Colors.white.withValues(alpha: 0.45),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: sw * 0.040),
                // Stats
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatRow(
                        label: 'Total Budget',
                        value: totalLimit,
                        color: Colors.white,
                        sw: sw,
                        sh: sh,
                      ),
                      SizedBox(height: sh * 0.016),
                      _StatRow(
                        label: 'Spent',
                        value: totalSpent,
                        color: barColor,
                        sw: sw,
                        sh: sh,
                      ),
                      SizedBox(height: sh * 0.016),
                      _StatRow(
                        label: overBudget ? 'Over by' : 'Remaining',
                        value: remaining.abs(),
                        color: overBudget
                            ? const Color(0xFFFF5252)
                            : Colors.white.withValues(alpha: 0.55),
                        sw: sw,
                        sh: sh,
                      ),
                      SizedBox(height: sh * 0.020),
                      Text(
                        DateFormat('MMMM yyyy').format(DateTime.now()),
                        style: GoogleFonts.inter(
                          fontSize: sw * 0.026,
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: sh * 0.020),
            // Overall progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(sw * 0.020),
              child: LinearProgressIndicator(
                value: overallPct,
                minHeight: sh * 0.009,
                backgroundColor: Colors.white.withValues(alpha: 0.10),
                valueColor: AlwaysStoppedAnimation(barColor),
              ),
            ),
            SizedBox(height: sh * 0.010),
            // Legend
            _DonutLegend(
              plans: widget.plans,
              ref: widget.ref,
              sw: sw,
              sh: sh,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final double sw, sh;

  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
    required this.sw,
    required this.sh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: sw * 0.026,
            color: Colors.white.withValues(alpha: 0.40),
          ),
        ),
        Text(
          value.toStringAsFixed(2),
          style: GoogleFonts.montserrat(
            fontSize: sw * 0.036,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _DonutLegend extends StatelessWidget {
  final List<BudgetPlan> plans;
  final WidgetRef ref;
  final double sw, sh;

  const _DonutLegend(
      {required this.plans,
      required this.ref,
      required this.sw,
      required this.sh});

  @override
  Widget build(BuildContext context) {
    final categoryRepo = ref.read(categoryRepositoryProvider);
    final allAllocations =
        plans.expand((p) => p.allocations).take(6).toList();

    return Wrap(
      spacing: sw * 0.030,
      runSpacing: sh * 0.006,
      children: allAllocations.map((b) {
        final cat = categoryRepo.getById(b.categoryId);
        if (cat == null) return const SizedBox.shrink();
        final color = Color(int.parse(cat.colorHex, radix: 16));
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: sw * 0.020,
              height: sw * 0.020,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: sw * 0.010),
            Text(
              cat.name,
              style: GoogleFonts.inter(
                fontSize: sw * 0.026,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// ─── Per-plan card ────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final BudgetPlan plan;
  final BudgetState state;
  final double sw, sh;
  final WidgetRef ref;

  const _PlanCard({
    required this.plan,
    required this.state,
    required this.sw,
    required this.sh,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final categoryRepo = ref.read(categoryRepositoryProvider);
    final accountRepo = ref.read(accountRepositoryProvider);
    final account = plan.accountId != null
        ? accountRepo.getById(plan.accountId!)
        : null;

    final totalSpent = plan.totalSpent(state.spent);
    final totalLimit = plan.totalLimit;
    final pct = plan.spentPercent(state.spent);
    final Color barColor = pct >= 1.0
        ? const Color(0xFFFF5252)
        : pct >= 0.8
            ? const Color(0xFFFFAB40)
            : AppColors.ACCENT;
    final currency = account?.currencyCode ?? 'GHS';

    return Dismissible(
      key: ValueKey(plan.planId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: sw * 0.050),
        decoration: BoxDecoration(
          color: const Color(0xFFFF5252).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(sw * 0.050),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) =>
          ref.read(budgetProvider.notifier).deletePlan(plan.planId),
      child: Container(
        padding: EdgeInsets.all(sw * 0.044),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(sw * 0.050),
          border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (account != null)
                        Row(
                          children: [
                            Icon(
                              IconData(account.iconCodePoint,
                                  fontFamily: 'MaterialIcons'),
                              color: Color(int.parse(
                                      account.colorHex,
                                      radix: 16))
                                  .withValues(alpha: 0.85),
                              size: sw * 0.034,
                            ),
                            SizedBox(width: sw * 0.016),
                            Text(
                              account.name,
                              style: GoogleFonts.inter(
                                fontSize: sw * 0.028,
                                color: Colors.white.withValues(alpha: 0.45),
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: sh * 0.004),
                      Row(
                        children: [
                          Text(
                            '$currency ${totalLimit.toStringAsFixed(2)}',
                            style: GoogleFonts.montserrat(
                              fontSize: sw * 0.042,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.028, vertical: sh * 0.007),
                  decoration: BoxDecoration(
                    color: barColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(sw * 0.040),
                  ),
                  child: Text(
                    '${(pct * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.montserrat(
                      color: barColor,
                      fontWeight: FontWeight.w700,
                      fontSize: sw * 0.034,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: sh * 0.014),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(sw * 0.020),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: sh * 0.007,
                backgroundColor: Colors.white.withValues(alpha: 0.10),
                valueColor: AlwaysStoppedAnimation(barColor),
              ),
            ),
            SizedBox(height: sh * 0.008),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spent: $currency ${totalSpent.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.40),
                    fontSize: sw * 0.028,
                  ),
                ),
                Text(
                  _periodLabel(plan.period),
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.30),
                    fontSize: sw * 0.026,
                  ),
                ),
              ],
            ),
            SizedBox(height: sh * 0.016),
            // Category breakdown
            ...plan.allocations.map((b) {
              final cat = categoryRepo.getById(b.categoryId);
              if (cat == null) return const SizedBox.shrink();
              final catColor = Color(int.parse(cat.colorHex, radix: 16));
              final catSpent = state.spent[b.categoryId] ?? 0;
              final catPct = b.limitAmount > 0
                  ? (catSpent / b.limitAmount).clamp(0.0, 1.0)
                  : 0.0;
              return Padding(
                padding: EdgeInsets.only(bottom: sh * 0.010),
                child: Row(
                  children: [
                    Container(
                      width: sw * 0.068,
                      height: sw * 0.068,
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        IconData(cat.iconCodePoint,
                            fontFamily: 'MaterialIcons'),
                        color: catColor,
                        size: sw * 0.034,
                      ),
                    ),
                    SizedBox(width: sw * 0.026),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                cat.name,
                                style: GoogleFonts.inter(
                                  fontSize: sw * 0.030,
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                              ),
                              Text(
                                '$currency ${catSpent.toStringAsFixed(0)} / ${b.limitAmount.toStringAsFixed(0)}',
                                style: GoogleFonts.inter(
                                  fontSize: sw * 0.026,
                                  color: Colors.white.withValues(alpha: 0.45),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: sh * 0.004),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(sw * 0.010),
                            child: LinearProgressIndicator(
                              value: catPct,
                              minHeight: sh * 0.005,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.08),
                              valueColor: AlwaysStoppedAnimation(
                                catPct >= 1.0
                                    ? const Color(0xFFFF5252)
                                    : catPct >= 0.8
                                        ? const Color(0xFFFFAB40)
                                        : catColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _periodLabel(String period) {
    switch (period) {
      case 'monthly':
        return 'Monthly';
      case 'quarterly':
        return 'Quarterly';
      case 'semi_annual':
        return 'Semi-Annual';
      case 'annual':
        return 'Annual';
      default:
        return 'Custom';
    }
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final double sw, sh;
  const _EmptyState({required this.sw, required this.sh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.pie_chart_outline_rounded,
            size: sw * 0.155,
            color: Colors.white.withValues(alpha: 0.20),
          ),
          SizedBox(height: sh * 0.016),
          Text(
            'No budgets for this month',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: sw * 0.040,
              color: Colors.white.withValues(alpha: 0.40),
            ),
          ),
          SizedBox(height: sh * 0.008),
          Text(
            'Tap + New Budget to get started',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: sw * 0.032,
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ),
        ],
      ),
    );
  }
}
