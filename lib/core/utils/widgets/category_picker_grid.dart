import 'package:expenser/core/utils/extensions/color_extensions.dart';
import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/models/category_model.dart';
import 'package:flutter/material.dart';

/// Icon-first category grid; column count adapts to available width.
class CategoryPickerGrid extends StatelessWidget {
  const CategoryPickerGrid({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<CategoryModel> categories;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    if (categories.isEmpty) {
      return Text(
        'No categories for this type yet.',
        style: TextStyle(fontSize: context.rs(13), color: palette.textMuted),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = context.rs(8);
        final columns = (constraints.maxWidth / context.rs(78)).floor().clamp(
          3,
          8,
        );
        final tileWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: context.rs(14),
          children: [
            for (final category in categories)
              SizedBox(
                width: tileWidth,
                child: _CategoryTile(
                  name: category.name,
                  icon: IconData(
                    category.iconCodePoint,
                    fontFamily: 'MaterialIcons',
                  ),
                  color: colorFromHex(
                    category.colorHex,
                    fallback: palette.textMuted,
                  ),
                  isSelected: category.id == selectedId,
                  onTap: () => onSelected(category.id),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.name,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String name;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tileSize = context.rs(54);

    return Semantics(
      button: true,
      selected: isSelected,
      label: name,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: tileSize,
              height: tileSize,
              decoration: BoxDecoration(
                color: isSelected ? color : color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(context.rs(18)),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.35),
                            blurRadius: context.rs(12),
                            offset: Offset(0, context.rs(4)),
                          ),
                        ]
                        : null,
              ),
              child: Icon(
                icon,
                size: context.rs(24),
                color: isSelected ? Colors.white : color,
              ),
            ),
            SizedBox(height: context.rs(6)),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.rs(11.5),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? palette.textPrimary : palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
