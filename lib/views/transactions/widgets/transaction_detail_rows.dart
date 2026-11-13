import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/theme/input_decorations.dart';
import 'package:flutter/material.dart';

/// Tappable settings-style row: icon, title, current value, chevron.
class TransactionDetailRow extends StatelessWidget {
  const TransactionDetailRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.iconColor,
    this.valueColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      child: _RowLayout(
        icon: icon,
        iconColor: iconColor ?? palette.accent,
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: context.rs(14),
                color: palette.textSecondary,
              ),
            ),
            SizedBox(width: context.rs(12)),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: context.rs(14),
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? palette.textPrimary,
                ),
              ),
            ),
            SizedBox(width: context.rs(4)),
            Icon(
              AppIcons.arrowRight,
              size: context.rs(16),
              color: palette.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

/// Inline, borderless multi-line note entry.
class TransactionNoteRow extends StatelessWidget {
  const TransactionNoteRow({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final style = TextStyle(
      fontSize: context.rs(14),
      color: palette.textPrimary,
    );

    return _RowLayout(
      icon: Icons.notes_rounded,
      iconColor: palette.warning,
      child: TextField(
        controller: controller,
        minLines: 1,
        maxLines: 4,
        textCapitalization: TextCapitalization.sentences,
        style: style,
        decoration: bareInputDecoration(
          hintText: 'Add a note',
          hintStyle: style.copyWith(color: palette.textMuted),
        ),
      ),
    );
  }
}

class _RowLayout extends StatelessWidget {
  const _RowLayout({
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  final IconData icon;
  final Color iconColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tileSize = context.rs(36);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.rs(14),
        vertical: context.rs(12),
      ),
      child: Row(
        children: [
          Container(
            width: tileSize,
            height: tileSize,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(context.rs(11)),
            ),
            child: Icon(icon, size: context.rs(18), color: iconColor),
          ),
          SizedBox(width: context.rs(12)),
          Expanded(child: child),
        ],
      ),
    );
  }
}
