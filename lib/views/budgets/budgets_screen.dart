import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/widgets/app_empty_state.dart';
import 'package:expenser/core/utils/widgets/app_page_header.dart';
import 'package:expenser/core/utils/widgets/app_surface_card.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/viewmodels/budget_viewmodel.dart';
import 'package:expenser/views/budgets/widgets/budget_labels.dart';
import 'package:expenser/views/budgets/widgets/budget_plan_card.dart';
import 'package:expenser/views/budgets/widgets/budget_progress_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expenser/core/utils/widgets/brand_watermark_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(budgetProvider);
    final now = DateTime.now();
    final active = state.activePlans(now);
    final current = state.currentPlans(now);
    final ended = state.endedPlans(now);
    final gutter = context.contentGutter;

    return Scaffold(
      body: BrandWatermarkBackground(
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: AppPageHeader(title: 'Budgets')),
              if (state.plans.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyState(
                    icon: Icons.pie_chart_outline_rounded,
                    title: 'No budgets yet',
                    message: 'Tap New Budget to plan your spending',
                  ),
                )
              else ...[
                if (active.isNotEmpty)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: gutter),
                    sliver: SliverToBoxAdapter(
                      child: _OverviewCard(plans: active),
                    ),
                  ),
                _sectionTitle(context, 'Current'),
                if (current.isEmpty)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: gutter),
                    sliver: SliverToBoxAdapter(
                      child: _NoCurrentBudgets(hasEnded: ended.isNotEmpty),
                    ),
                  )
                else
                  _planList(
                    context,
                    itemCount: current.length,
                    builder: (_, i) => BudgetPlanCard(plan: current[i]),
                  ),
                if (ended.isNotEmpty) ...[
                  _sectionTitle(context, 'Ended'),
                  _planList(
                    context,
                    itemCount: ended.length,
                    builder:
                        (_, i) => EndedBudgetCard(
                          plan: ended[i],
                          isRenewed: state.isRenewed(ended[i], now),
                          onRenew: () => _renew(context, ref, ended[i].planId),
                        ),
                  ),
                ],
                SliverToBoxAdapter(child: SizedBox(height: context.rs(96))),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_budgets',
        onPressed: () => context.push('/budgets/create'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Budget'),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        context.contentGutter,
        context.rs(22),
        context.contentGutter,
        context.rs(10),
      ),
      sliver: SliverToBoxAdapter(
        child: Text(
          title,
          style: TextStyle(
            fontSize: context.rs(16),
            fontWeight: FontWeight.w700,
            color: context.palette.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _planList(
    BuildContext context, {
    required int itemCount,
    required IndexedWidgetBuilder builder,
  }) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: context.contentGutter),
      sliver: SliverList.separated(
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(height: context.rs(12)),
        itemBuilder: builder,
      ),
    );
  }

  Future<void> _renew(
    BuildContext context,
    WidgetRef ref,
    String planId,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final newPlanId = await ref.read(budgetProvider.notifier).renewPlan(planId);
    if (newPlanId == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Budget renewed for the current period')),
      );
  }
}

class _NoCurrentBudgets extends StatelessWidget {
  const _NoCurrentBudgets({required this.hasEnded});

  final bool hasEnded;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Text(
        hasEnded
            ? 'No budget is running right now. Renew one below or create a new one.'
            : 'No budget is running right now.',
        style: TextStyle(
          fontSize: context.rs(13),
          color: context.palette.textSecondary,
        ),
      ),
    );
  }
}

// ─── Overview of running budgets, one currency at a time ─────────────────────

class _OverviewCard extends ConsumerStatefulWidget {
  const _OverviewCard({required this.plans});

  final List<BudgetPlan> plans;

  @override
  ConsumerState<_OverviewCard> createState() => _OverviewCardState();
}

class _OverviewCardState extends ConsumerState<_OverviewCard> {
  String? _currency;
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final currencies = {for (final p in widget.plans) p.currency}.toList();
    final currency =
        currencies.contains(_currency) ? _currency! : currencies.first;
    final plans = widget.plans.where((p) => p.currency == currency).toList();

    final totalLimit = plans.fold<double>(0, (sum, p) => sum + p.totalLimit);
    final totalSpent = plans.fold<double>(0, (sum, p) => sum + p.totalSpent);
    final usage = totalLimit > 0 ? totalSpent / totalLimit : 0.0;
    final remaining = totalLimit - totalSpent;
    final barColor = budgetUsageColor(
      palette,
      usage: usage,
      warningAt: 0.8,
      normal: palette.accent,
    );

    return AppSurfaceCard(
      padding: EdgeInsets.all(context.rs(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currencies.length > 1) ...[
            Wrap(
              spacing: context.rs(8),
              runSpacing: context.rs(6),
              children: [
                for (final c in currencies)
                  ChoiceChip(
                    label: Text(c),
                    selected: c == currency,
                    onSelected:
                        (_) => setState(() {
                          _currency = c;
                          _touchedIndex = -1;
                        }),
                  ),
              ],
            ),
            SizedBox(height: context.rs(14)),
          ],
          Row(
            children: [
              SizedBox.square(
                dimension: context.rs(140),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sections: _sections(context, plans),
                        centerSpaceRadius: context.rs(38),
                        sectionsSpace: context.rs(3),
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            final index =
                                event.isInterestedForInteractions
                                    ? response
                                            ?.touchedSection
                                            ?.touchedSectionIndex ??
                                        -1
                                    : -1;
                            if (index != _touchedIndex) {
                              setState(() => _touchedIndex = index);
                            }
                          },
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(usage * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: context.rs(19),
                            fontWeight: FontWeight.w700,
                            color: barColor,
                          ),
                        ),
                        Text(
                          'used',
                          style: TextStyle(
                            fontSize: context.rs(11),
                            color: palette.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: context.rs(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatRow(
                      label: 'Budgeted now',
                      value: budgetMoney(currency, totalLimit),
                      color: palette.textPrimary,
                    ),
                    SizedBox(height: context.rs(12)),
                    _StatRow(
                      label: 'Spent',
                      value: budgetMoney(currency, totalSpent),
                      color: barColor,
                    ),
                    SizedBox(height: context.rs(12)),
                    _StatRow(
                      label: remaining < 0 ? 'Over by' : 'Remaining',
                      value: budgetMoney(currency, remaining.abs()),
                      color:
                          remaining < 0
                              ? palette.danger
                              : palette.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.rs(16)),
          BudgetProgressBar(
            usage: usage,
            color: barColor,
            height: context.rs(7),
          ),
          SizedBox(height: context.rs(10)),
          _DonutLegend(plans: plans),
        ],
      ),
    );
  }

  List<PieChartSectionData> _sections(
    BuildContext context,
    List<BudgetPlan> plans,
  ) {
    final palette = context.palette;
    final categoryRepo = ref.read(categoryRepositoryProvider);
    final allocations = plans.expand((p) => p.allocations).toList();
    if (allocations.isEmpty) {
      return [
        PieChartSectionData(
          value: 1,
          color: palette.surfaceMuted,
          radius: context.rs(30),
          title: '',
        ),
      ];
    }

    final sections = <PieChartSectionData>[];
    for (var i = 0; i < allocations.length; i++) {
      final category = categoryRepo.getById(allocations[i].categoryId);
      sections.add(
        PieChartSectionData(
          value: allocations[i].limitAmount,
          color:
              category != null
                  ? Color(int.parse(category.colorHex, radix: 16))
                  : palette.accent,
          radius: context.rs(i == _touchedIndex ? 36 : 30),
          title: '',
        ),
      );
    }
    return sections;
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: context.rs(11),
            color: context.palette.textSecondary,
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              fontSize: context.rs(14),
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _DonutLegend extends ConsumerWidget {
  const _DonutLegend({required this.plans});

  final List<BudgetPlan> plans;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final categoryRepo = ref.read(categoryRepositoryProvider);
    final categoryIds = {
      for (final p in plans)
        for (final b in p.allocations) b.categoryId,
    }.take(6);

    return Wrap(
      spacing: context.rs(12),
      runSpacing: context.rs(6),
      children: [
        for (final id in categoryIds)
          if (categoryRepo.getById(id) case final category?)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: context.rs(8),
                  height: context.rs(8),
                  decoration: BoxDecoration(
                    color: Color(int.parse(category.colorHex, radix: 16)),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: context.rs(4)),
                Flexible(
                  child: Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: context.rs(11),
                      color: palette.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
      ],
    );
  }
}
