import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Design-size scaling based on a 390pt-wide reference phone.
///
/// Uses the shortest side so landscape, tablets and foldables scale
/// proportionally instead of blowing up with the long edge.
extension ResponsiveContext on BuildContext {
  static const double _referenceShortestSide = 390;
  static const double _minScale = 0.82;
  static const double _maxScale = 1.3;

  /// Max width for primary content on wide screens (tablets, landscape).
  static const double _maxContentWidth = 600;

  Size get screenSize => MediaQuery.sizeOf(this);

  double get scaleFactor => (screenSize.shortestSide / _referenceShortestSide)
      .clamp(_minScale, _maxScale);

  /// Scales a reference-design value (size, spacing, radius, font size).
  double rs(double value) => value * scaleFactor;

  /// Horizontal gutter that centers content within [_maxContentWidth].
  double get contentGutter {
    final width = screenSize.width;
    final baseGutter = rs(20);
    return math.max(baseGutter, (width - _maxContentWidth) / 2);
  }
}
