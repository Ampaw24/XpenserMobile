import 'package:expenser/core/constants/branding.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/viewmodels/insights_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SpendingChart extends ConsumerWidget {
  const SpendingChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final insights = ref.watch(insightsProvider);
    final totals = insights.weeklyTotals;
    final maxY = totals.reduce((a, b) => a > b ? a : b);

    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return DateFormat('EEE').format(d);
    });

    final cardBg = context.palette.surface;
    final borderColor = context.palette.border;
    final axisTextColor = context.palette.textSecondary;
    final gridLineColor =
        isDark
            ? AppBrand.borderDark.withValues(alpha: 0.5)
            : AppBrand.borderLight.withValues(alpha: 0.7);

    return Container(
      height: context.rs(170),
      padding: EdgeInsets.fromLTRB(
        context.rs(16),
        context.rs(18),
        context.rs(16),
        context.rs(10),
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(context.rs(20)),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY > 0 ? maxY * 1.25 : 100,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => context.palette.hero,
              getTooltipItem:
                  (group, _, rod, __) => BarTooltipItem(
                    rod.toY.toStringAsFixed(0),
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: context.rs(24),
                getTitlesWidget:
                    (value, _) => Padding(
                      padding: EdgeInsets.only(top: context.rs(6)),
                      child: Text(
                        days[value.toInt()],
                        style: TextStyle(
                          color: axisTextColor,
                          fontSize: context.rs(11),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY > 0 ? maxY / 3 : 33,
            getDrawingHorizontalLine:
                (_) => FlLine(color: gridLineColor, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (i) {
            final isMax = totals[i] == maxY && maxY > 0;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: totals[i],
                  color:
                      isMax
                          ? (isDark ? AppBrand.mintAccent : AppBrand.spruceDark)
                          : AppBrand.tealPrimary.withValues(
                            alpha: isDark ? 0.55 : 0.28,
                          ),
                  width: context.rs(22),
                  borderRadius: BorderRadius.circular(context.rs(6)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
