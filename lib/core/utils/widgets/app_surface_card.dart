import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:flutter/material.dart';

/// Standard bordered surface used for cards, list groups and form sections.
class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderColor,
  });

  final Widget child;

  /// Defaults to 16 (scaled) on all sides.
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final radius = BorderRadius.circular(context.rs(18));

    return Material(
      color: color ?? palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: borderColor ?? palette.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding ?? EdgeInsets.all(context.rs(16)),
          child: child,
        ),
      ),
    );
  }
}
