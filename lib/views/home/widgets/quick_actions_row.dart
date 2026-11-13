import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/constants/branding.dart';
import 'package:flutter/material.dart';
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ActionButton(
            icon: AppIcons.arrowUp,
            label: 'Expense',
            iconColor: const Color(0xFFE11D48),
            bgColor: const Color(0xFFE11D48).withValues(alpha: 0.10),
            onTap: onAddExpense,
          ),
          _ActionButton(
            icon: AppIcons.arrowDown,
            label: 'Income',
            iconColor: const Color(0xFF059669),
            bgColor: const Color(0xFF059669).withValues(alpha: 0.10),
            onTap: onAddIncome,
          ),
          _ActionButton(
            icon: AppIcons.transfer,
            label: 'Transfer',
            iconColor: const Color(0xFF0284C7),
            bgColor: const Color(0xFF0284C7).withValues(alpha: 0.10),
            onTap: onTransfer,
          ),
          _ActionButton(
            icon: AppIcons.savings,
            label: 'Savings',
            iconColor: AppBrand.tealPrimary,
            bgColor: AppBrand.tealPrimary.withValues(alpha: 0.10),
            onTap: onSavings,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? const Color(0xFF94A3B8) : AppBrand.textSecondaryLight;
    final borderColor = isDark ? AppBrand.borderDark : AppBrand.borderLight;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: widget.bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor,
                  width: 1.0,
                ),
              ),
              child: Center(
                child: HugeIcon(
                  icon: widget.icon,
                  color: widget.iconColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: labelColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
