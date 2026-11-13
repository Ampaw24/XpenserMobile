import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:flutter/material.dart';

/// Grid of icon tiles; the selected tile is tinted with [color].
class AppIconPicker extends StatelessWidget {
  const AppIconPicker({
    super.key,
    required this.options,
    required this.selectedCodePoint,
    required this.color,
    required this.onSelected,
  });

  final List<IconData> options;
  final int selectedCodePoint;
  final Color color;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final size = context.rs(48);

    return Wrap(
      spacing: context.rs(12),
      runSpacing: context.rs(12),
      children: [
        for (final icon in options)
          Semantics(
            button: true,
            selected: icon.codePoint == selectedCodePoint,
            child: GestureDetector(
              onTap: () => onSelected(icon.codePoint),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color:
                      icon.codePoint == selectedCodePoint
                          ? color.withValues(alpha: 0.16)
                          : palette.surfaceMuted,
                  borderRadius: BorderRadius.circular(context.rs(14)),
                ),
                child: Icon(
                  icon,
                  size: context.rs(22),
                  color:
                      icon.codePoint == selectedCodePoint
                          ? color
                          : palette.textMuted,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
