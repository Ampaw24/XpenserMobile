import 'package:expenser/core/utils/extensions/color_extensions.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:flutter/material.dart';

/// Row of circular swatches for picking an `AARRGGBB` hex color.
class AppColorPicker extends StatelessWidget {
  const AppColorPicker({
    super.key,
    required this.options,
    required this.selectedHex,
    required this.onSelected,
  });

  final List<String> options;
  final String selectedHex;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final size = context.rs(40);

    return Wrap(
      spacing: context.rs(12),
      runSpacing: context.rs(12),
      children: [
        for (final hex in options)
          _Swatch(
            size: size,
            color: colorFromHex(hex, fallback: palette.accent),
            isSelected: hex == selectedHex,
            onTap: () => onSelected(hex),
          ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.size,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final double size;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          padding: EdgeInsets.all(context.rs(3)),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: context.rs(2),
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child:
                isSelected
                    ? Icon(
                      Icons.check_rounded,
                      size: context.rs(16),
                      color: Colors.white,
                    )
                    : null,
          ),
        ),
      ),
    );
  }
}
