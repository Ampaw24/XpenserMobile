import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/viewmodels/insights_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SpendingChart extends ConsumerWidget {
  const SpendingChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final insights = ref.watch(insightsProvider);
    final totals = insights.weeklyTotals;
    final maxY = totals.reduce((a, b) => a > b ? a : b);

    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return DateFormat('EEE').format(d);
    });

    return Container(
      height: sh * 0.190,
      padding: EdgeInsets.fromLTRB(
        sw * 0.04,
        sh * 0.022,
        sw * 0.04,
        sh * 0.012,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(sw * 0.055),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 1.0,
        ),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY > 0 ? maxY * 1.30 : 100,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF0D1B2A),
              getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                rod.toY.toStringAsFixed(0),
                GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: sw * 0.028,
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
                reservedSize: sh * 0.030,
                getTitlesWidget: (value, _) => Text(
                  days[value.toInt()],
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.40),
                    fontSize: sw * 0.028,
                  ),
                ),
              ),
            ),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY > 0 ? maxY / 3 : 33,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.white.withValues(alpha: 0.07),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (i) {
            final isMax = totals[i] == maxY && maxY > 0;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: totals[i],
                  gradient: isMax
                      ? const LinearGradient(
                          colors: [AppColors.ACCENT, Color(0xFF1DE9B6)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        )
                      : LinearGradient(
                          colors: [
                            AppColors.PRIMARY.withValues(alpha: 0.60),
                            AppColors.PRIMARY.withValues(alpha: 0.90),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                  width: sw * 0.048,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(sw * 0.020),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
