import 'dart:math' as math;

import 'package:expenser/core/constants/branding.dart';
import 'package:expenser/core/constants/imageconstants.dart';
import 'package:flutter/material.dart';

/// Pins the coastal skyline watermark flush to the bottom edge of the screen,
/// behind [child]. Use as a Scaffold `body`, outside any SafeArea.
///
/// Screens with bottom-anchored content should lift it by
/// [BrandWatermarkBackground.reservedHeight] so the skyline stays visible.
class BrandWatermarkBackground extends StatelessWidget {
  const BrandWatermarkBackground({super.key, required this.child, this.isDark});

  final Widget child;

  /// Overrides the theme brightness when a screen resolves dark mode itself.
  final bool? isDark;

  static const double _aspectRatio = 2408 / 722;
  static const double _maxHeightFraction = 0.2;
  static const double _lightAlpha = 0.14;
  static const double _darkAlpha = 0.18;

  static bool _isKeyboardOpen(BuildContext context) =>
      MediaQuery.viewInsetsOf(context).bottom > 0;

  static double _watermarkHeight(Size screen) =>
      math.min(screen.width / _aspectRatio, screen.height * _maxHeightFraction);

  /// Space content inside a bottom SafeArea needs to clear the skyline.
  static double reservedHeight(BuildContext context) {
    if (_isKeyboardOpen(context)) return 0;
    final height = _watermarkHeight(MediaQuery.sizeOf(context));
    return math.max(0, height - MediaQuery.viewPaddingOf(context).bottom);
  }

  @override
  Widget build(BuildContext context) {
    final dark = isDark ?? Theme.of(context).brightness == Brightness.dark;
    final tint =
        dark
            ? AppBrand.mintAccent.withValues(alpha: _darkAlpha)
            : AppBrand.tealPrimary.withValues(alpha: _lightAlpha);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (!_isKeyboardOpen(context))
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _watermarkHeight(MediaQuery.sizeOf(context)),
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: Image.asset(
                  Imageconstants.watermarkSkyline,
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                  color: tint,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
          ),
        child,
      ],
    );
  }
}
