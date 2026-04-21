import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({
    super.key,
    required this.onAddExpense,
    required this.onAddIncome,
    required this.onTransfer,
    required this.onSavings,
  });

  final VoidCallback onAddExpense;
  final VoidCallback onAddIncome;
  final VoidCallback onTransfer;
  final VoidCallback onSavings;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ActionButton(
            icon: AppIcons.arrowUp,
            label: 'Expense',
            iconColor: const Color(0xFFFF5252),
            bgColor: const Color(0xFFFF5252).withValues(alpha: 0.12),
            onTap: onAddExpense,
            sw: sw,
            sh: sh,
          ),
          _ActionButton(
            icon: AppIcons.arrowDown,
            label: 'Income',
            iconColor: const Color(0xFF00E676),
            bgColor: const Color(0xFF00E676).withValues(alpha: 0.12),
            onTap: onAddIncome,
            sw: sw,
            sh: sh,
          ),
          _ActionButton(
            icon: AppIcons.transfer,
            label: 'Transfer',
            iconColor: const Color(0xFF448AFF),
            bgColor: const Color(0xFF448AFF).withValues(alpha: 0.12),
            onTap: onTransfer,
            sw: sw,
            sh: sh,
          ),
          _ActionButton(
            icon: AppIcons.savings,
            label: 'Savings',
            iconColor: AppColors.ACCENT,
            bgColor: AppColors.ACCENT.withValues(alpha: 0.12),
            onTap: onSavings,
            sw: sw,
            sh: sh,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
    required this.sw,
    required this.sh,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;
  final double sw, sh;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: sw * 0.145,
            height: sw * 0.145,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(sw * 0.042),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.25),
                width: 1.0,
              ),
            ),
            child: Center(
              child: HugeIcon(
                icon: icon,
                color: iconColor,
                size: sw * 0.058,
              ),
            ),
          ),
          SizedBox(height: sh * 0.008),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: sw * 0.030,
              color: Colors.white.withValues(alpha: 0.65),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
