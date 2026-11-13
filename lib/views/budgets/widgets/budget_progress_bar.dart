import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:flutter/material.dart';

/// Danger once over the limit, warning past [warningAt], otherwise [normal].
Color budgetUsageColor(
  AppPalette palette, {
  required double usage,
  required double warningAt,
  required Color normal,
}) {
  if (usage >= 1) return palette.danger;
  if (usage >= warningAt) return palette.warning;
  return normal;
}

class BudgetProgressBar extends StatelessWidget {
  const BudgetProgressBar({
    super.key,
    required this.usage,
    required this.color,
    required this.height,
  });

  /// Spent ÷ limit; values above 1 render as a full bar.
  final double usage;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: usage.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: context.palette.surfaceMuted,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}
