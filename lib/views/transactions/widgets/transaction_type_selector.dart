import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/models/transaction_type.dart';
import 'package:flutter/material.dart';

/// Pill-shaped segmented control for expense / income / transfer.
class TransactionTypeSelector extends StatelessWidget {
  const TransactionTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;

  static Color colorFor(TransactionType type, AppPalette palette) {
    return switch (type) {
      TransactionType.expense => palette.danger,
      TransactionType.income => palette.success,
      TransactionType.transfer => palette.info,
    };
  }

  static IconData _iconFor(TransactionType type) {
    return switch (type) {
      TransactionType.expense => AppIcons.arrowUp,
      TransactionType.income => AppIcons.arrowDown,
      TransactionType.transfer => AppIcons.transfer,
    };
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: EdgeInsets.all(context.rs(4)),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(context.rs(100)),
      ),
      child: Row(
        children: [
          for (final type in TransactionType.values)
            Expanded(
              child: _TypeSegment(
                label: type.name[0].toUpperCase() + type.name.substring(1),
                icon: _iconFor(type),
                color: colorFor(type, palette),
                isSelected: type == selected,
                onTap: () => onChanged(type),
              ),
            ),
        ],
      ),
    );
  }
}

class _TypeSegment extends StatelessWidget {
  const _TypeSegment({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final foreground = isSelected ? color : palette.textSecondary;

    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(vertical: context.rs(11)),
          decoration: BoxDecoration(
            color: isSelected ? palette.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(context.rs(100)),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: context.rs(10),
                        offset: Offset(0, context.rs(2)),
                      ),
                    ]
                    : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: context.rs(16), color: foreground),
                SizedBox(width: context.rs(6)),
                Text(
                  label,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: context.rs(14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
