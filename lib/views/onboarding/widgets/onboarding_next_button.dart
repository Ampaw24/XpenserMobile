import 'dart:math' as math;

import 'package:expenser/core/constants/app_icons.dart';
import 'package:expenser/core/utils/extensions/page_controller_extensions.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// A bare arrow inside a progress ring that swaps to a "Get Started" pill on
/// the last page. Sizes itself from the screen's shortest side.
class OnboardingNextButton extends StatelessWidget {
  const OnboardingNextButton({
    super.key,
    required this.controller,
    required this.pageCount,
    required this.isLast,
    required this.accent,
    required this.foreground,
    required this.onPressed,
  });

  final PageController controller;
  final int pageCount;
  final bool isLast;
  final Color accent;
  final Color foreground;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final size = (shortestSide * 0.15).clamp(
      kMinInteractiveDimension,
      kMinInteractiveDimension * 1.6,
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      layoutBuilder:
          (current, previous) => Stack(
            alignment: Alignment.centerRight,
            children: [...previous, if (current != null) current],
          ),
      transitionBuilder:
          (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: animation,
              alignment: Alignment.centerRight,
              child: child,
            ),
          ),
      child: isLast ? _buildGetStarted(size) : _buildArrowRing(size),
    );
  }

  Widget _buildArrowRing(double size) {
    return Semantics(
      key: const ValueKey('arrow'),
      button: true,
      label: 'Next page',
      child: SizedBox.square(
        dimension: size,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: CustomPaint(
              painter: _ProgressRingPainter(
                controller: controller,
                pageCount: pageCount,
                color: accent,
              ),
              child: Center(
                child: HugeIcon(
                  icon: AppIcons.arrowRight,
                  color: accent,
                  size: size * 0.42,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGetStarted(double size) {
    return Semantics(
      key: const ValueKey('getStarted'),
      button: true,
      label: 'Get started',
      child: Material(
        color: accent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            height: size,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size * 0.45),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Get Started',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: size * 0.28,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                  ),
                  SizedBox(width: size * 0.12),
                  HugeIcon(
                    icon: AppIcons.arrowRight,
                    color: foreground,
                    size: size * 0.34,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({
    required this.controller,
    required this.pageCount,
    required this.color,
  }) : super(repaint: controller);

  final PageController controller;
  final int pageCount;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final progress = ((controller.pageOffset + 1) / pageCount).clamp(0.0, 1.0);
    final stroke = size.width * 0.05;
    final rect = (Offset.zero & size).deflate(stroke / 2);

    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = color.withValues(alpha: 0.15),
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.pageCount != pageCount ||
      oldDelegate.controller != controller;
}
