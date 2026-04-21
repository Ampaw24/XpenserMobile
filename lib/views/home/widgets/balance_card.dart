import 'dart:ui';

import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.currency,
    required this.monthlyIncome,
    required this.monthlyExpense,
  });

  final double totalBalance;
  final String currency;
  final double monthlyIncome;
  final double monthlyExpense;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(sw * 0.065),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.PRIMARY.withValues(alpha: 0.80),
                  AppColors.ACCENT.withValues(alpha: 0.65),
                ],
              ),
              borderRadius: BorderRadius.circular(sw * 0.065),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
                width: 1.2,
              ),
            ),
            padding: EdgeInsets.all(sw * 0.065),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Balance',
                  style: GoogleFonts.inter(
                    fontSize: sw * 0.033,
                    color: Colors.white.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: sh * 0.008),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: totalBalance),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOut,
                  builder: (_, value, __) => Text(
                    '$currency ${value.toStringAsFixed(2)}',
                    style: GoogleFonts.montserrat(
                      fontSize: sw * 0.080,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                SizedBox(height: sh * 0.022),
                Row(
                  children: [
                    Expanded(
                      child: _StatChip(
                        icon: AppIcons.arrowDown,
                        iconColor: const Color(0xFF00E676),
                        label: 'Income',
                        value: '$currency ${monthlyIncome.toStringAsFixed(0)}',
                        sw: sw,
                        sh: sh,
                      ),
                    ),
                    SizedBox(width: sw * 0.04),
                    Expanded(
                      child: _StatChip(
                        icon: AppIcons.arrowUp,
                        iconColor: const Color(0xFFFF5252),
                        label: 'Expenses',
                        value: '$currency ${monthlyExpense.toStringAsFixed(0)}',
                        sw: sw,
                        sh: sh,
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
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.sw,
    required this.sh,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final double sw, sh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.038,
        vertical: sh * 0.012,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(sw * 0.038),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(sw * 0.018),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(sw * 0.020),
            ),
            child: HugeIcon(
              icon: icon,
              color: iconColor,
              size: sw * 0.038,
            ),
          ),
          SizedBox(width: sw * 0.025),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: sw * 0.028,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontSize: sw * 0.034,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
