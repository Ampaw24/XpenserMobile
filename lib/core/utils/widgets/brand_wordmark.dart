import 'package:expenser/core/constants/branding.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

/// The Xpenser wordmark for the current brightness, shifted so its artwork
/// (not its canvas) is centred where it's placed.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Transform.translate(
      offset: Offset(width * (0.5 - AppBrand.wordmarkOpticalCenterX), 0),
      child: SvgPicture.asset(
        isDark ? AppBrand.wordmarkDark : AppBrand.wordmarkLight,
        width: width,
        height: width / AppBrand.wordmarkAspectRatio,
        fit: BoxFit.contain,
      ),
    );
  }
}
