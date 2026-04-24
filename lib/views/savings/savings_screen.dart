import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/viewmodels/savings_goal_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final goals = ref.watch(savingsGoalProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          'Savings Goals',
          style: GoogleFonts.montserrat(
            fontSize: sw * 0.048,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(AppIcons.arrowLeft, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: goals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(AppIcons.savings,
                      size: sw * 0.155,
                      color: Colors.white.withValues(alpha: 0.20)),
                  SizedBox(height: sh * 0.016),
                  Text(
                    'No savings goals yet',
                    style: GoogleFonts.inter(
                      fontSize: sw * 0.040,
                      color: Colors.white.withValues(alpha: 0.40),
                    ),
                  ),
                  SizedBox(height: sh * 0.008),
                  Text(
                    'Tap + to add a goal',
                    style: GoogleFonts.inter(
                      fontSize: sw * 0.032,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(sw * 0.06, sh * 0.010, sw * 0.06, sh * 0.12),
              itemCount: goals.length,
              separatorBuilder: (_, __) => SizedBox(height: sh * 0.014),
              itemBuilder: (context, i) {
                final g = goals[i];
                final color = _hexToColor(g.colorHex);
                final daysLeft = g.targetDate.difference(DateTime.now()).inDays;

                return Dismissible(
                  key: ValueKey(g.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: sw * 0.050),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(sw * 0.050),
                    ),
                    child: Icon(AppIcons.delete, color: Colors.white, size: sw * 0.060),
                  ),
                  onDismissed: (_) =>
                      ref.read(savingsGoalProvider.notifier).deleteGoal(g.id),
                  child: GestureDetector(
                    onTap: () => context.push('/savings/${g.id}/edit'),
                    child: Container(
                      padding: EdgeInsets.all(sw * 0.048),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(sw * 0.050),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(sw * 0.026),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(sw * 0.028),
                                ),
                                child: Icon(
                                  IconData(g.iconCodePoint,
                                      fontFamily: 'HgiStrokeRounded',
                                      fontPackage: 'hugeicons'),
                                  color: color,
                                  size: sw * 0.055,
                                ),
                              ),
                              SizedBox(width: sw * 0.034),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      g.name,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: sw * 0.040,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: sh * 0.003),
                                    Text(
                                      daysLeft > 0
                                          ? '$daysLeft days left'
                                          : 'Target date passed',
                                      style: GoogleFonts.inter(
                                        color: daysLeft > 0
                                            ? Colors.white.withValues(alpha: 0.45)
                                            : const Color(0xFFFF5252),
                                        fontSize: sw * 0.030,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${(g.progressPercent * 100).toStringAsFixed(0)}%',
                                style: GoogleFonts.montserrat(
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                  fontSize: sw * 0.045,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: sh * 0.014),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(sw * 0.020),
                            child: LinearProgressIndicator(
                              value: g.progressPercent,
                              minHeight: sh * 0.007,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.10),
                              valueColor: AlwaysStoppedAnimation(color),
                            ),
                          ),
                          SizedBox(height: sh * 0.010),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Saved: ${g.savedAmount.toStringAsFixed(2)}',
                                style: GoogleFonts.inter(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  fontSize: sw * 0.030,
                                ),
                              ),
                              Text(
                                'Goal: ${g.targetAmount.toStringAsFixed(2)}',
                                style: GoogleFonts.inter(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  fontSize: sw * 0.030,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_savings',
        backgroundColor: AppColors.PRIMARY,
        onPressed: () => context.push('/savings/add'),
        child: const Icon(AppIcons.add, color: Colors.white),
      ),
    );
  }

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
    } catch (_) {
      return AppColors.PRIMARY;
    }
  }
}
