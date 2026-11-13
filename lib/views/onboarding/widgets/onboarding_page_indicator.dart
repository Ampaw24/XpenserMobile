import 'dart:ui' show lerpDouble;

import 'package:expenser/core/utils/extensions/page_controller_extensions.dart';
import 'package:flutter/material.dart';

/// Dots that stretch into a pill, tracking the swipe position continuously.
class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({
    super.key,
    required this.controller,
    required this.count,
    required this.activeColor,
    required this.inactiveColor,
    required this.dotSize,
  });

  final PageController controller;
  final int count;
  final Color activeColor;
  final Color inactiveColor;
  final double dotSize;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final page = controller.pageOffset;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(count, (index) {
            final activeness = (1 - (page - index).abs()).clamp(0.0, 1.0);
            return Container(
              margin: EdgeInsets.symmetric(horizontal: dotSize * 0.35),
              width: lerpDouble(dotSize, dotSize * 3.5, activeness),
              height: dotSize,
              decoration: BoxDecoration(
                color: Color.lerp(inactiveColor, activeColor, activeness),
                borderRadius: BorderRadius.circular(dotSize),
              ),
            );
          }),
        );
      },
    );
  }
}
