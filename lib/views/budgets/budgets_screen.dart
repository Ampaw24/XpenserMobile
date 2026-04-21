import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/viewmodels/budget_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final state = ref.watch(budgetProvider);
    final categoryRepo = ref.read(categoryRepositoryProvider);
    final now = DateTime.now();
    final current = state.budgets
        .where((b) => b.month == now.month && b.year == now.year)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(sw * 0.06, sh * 0.024, sw * 0.06, sh * 0.020),
              child: Text(
                'Budgets',
                style: GoogleFonts.montserrat(
                  fontSize: sw * 0.058,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            if (current.isEmpty)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pie_chart_outline_rounded,
                        size: sw * 0.155,
                        color: Colors.white.withValues(alpha: 0.20)),
                    SizedBox(height: sh * 0.016),
                    Text(
                      'No budgets for this month',
                      style: GoogleFonts.inter(
                        fontSize: sw * 0.040,
                        color: Colors.white.withValues(alpha: 0.40),
                      ),
                    ),
                    SizedBox(height: sh * 0.008),
                    Text(
                      'Tap + to set a budget',
                      style: GoogleFonts.inter(
                        fontSize: sw * 0.032,
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(sw * 0.06, 0, sw * 0.06, sh * 0.12),
                  itemCount: current.length,
                  separatorBuilder: (_, __) => SizedBox(height: sh * 0.014),
                  itemBuilder: (context, i) {
                    final b = current[i];
                    final category = categoryRepo.getById(b.categoryId);
                    final spent = state.spent[b.categoryId] ?? 0;
                    final pct = (spent / b.limitAmount).clamp(0.0, 1.0);
                    final Color barColor;
                    if (pct >= 1.0) {
                      barColor = const Color(0xFFFF5252);
                    } else if (pct >= b.alertThreshold) {
                      barColor = const Color(0xFFFFAB40);
                    } else {
                      barColor = AppColors.ACCENT;
                    }
                    return Dismissible(
                      key: ValueKey(b.id),
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
                          ref.read(budgetProvider.notifier).deleteBudget(b.id),
                      child: GestureDetector(
                        onTap: () => context.push('/budgets/${b.id}/edit'),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    category?.name ?? 'Category',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: sw * 0.038,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${(pct * 100).toStringAsFixed(0)}%',
                                    style: GoogleFonts.montserrat(
                                      color: barColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: sw * 0.036,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: sh * 0.010),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(sw * 0.020),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: sh * 0.007,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.10),
                                  valueColor: AlwaysStoppedAnimation(barColor),
                                ),
                              ),
                              SizedBox(height: sh * 0.010),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Spent: ${spent.toStringAsFixed(2)}',
                                    style: GoogleFonts.inter(
                                      color: Colors.white.withValues(alpha: 0.45),
                                      fontSize: sw * 0.030,
                                    ),
                                  ),
                                  Text(
                                    'Limit: ${b.limitAmount.toStringAsFixed(2)}',
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_budgets',
        backgroundColor: AppColors.PRIMARY,
        onPressed: () => context.push('/budgets/add'),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
