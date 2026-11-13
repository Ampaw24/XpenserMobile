import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/constants/branding.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({
    super.key,
    required this.onAddIncome,
    required this.onAddExpense,
    required this.onTransfer,
    required this.onSavings,
  });

  final VoidCallback onAddIncome;
  final VoidCallback onAddExpense;
  final VoidCallback onTransfer;
  final VoidCallback onSavings;

  @override
  Widget build(BuildContext context) {
    final gap = context.rs(12);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ActionTile(icon: AppIcons.add, label: 'Add Money', onTap: onAddIncome),
        SizedBox(width: gap),
        _ActionTile(icon: AppIcons.send, label: 'Spend', onTap: onAddExpense),
        SizedBox(width: gap),
        _ActionTile(
          icon: AppIcons.transfer,
          label: 'Transfer',
          onTap: onTransfer,
        ),
        SizedBox(width: gap),
        _ActionTile(icon: AppIcons.savings, label: 'Savings', onTap: onSavings),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileColor = context.palette.surfaceMuted;
    final iconColor = isDark ? AppBrand.mintLight : AppBrand.spruceDark;
    final labelColor = context.palette.textPrimary;
    final radius = BorderRadius.circular(context.rs(16));

    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: Column(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.rs(76)),
              child: AspectRatio(
                aspectRatio: 1,
                child: Material(
                  color: tileColor,
                  borderRadius: radius,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: radius,
                    child: Center(
                      child: HugeIcon(
                        icon: icon,
                        color: iconColor,
                        size: context.rs(24),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: context.rs(8)),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: context.rs(12),
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
