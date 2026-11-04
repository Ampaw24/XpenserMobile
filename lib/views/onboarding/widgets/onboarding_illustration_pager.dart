import 'dart:math' as math;

import 'package:expenser/core/utils/extensions/page_controller_extensions.dart';
import 'package:expenser/models/onboarding_model.dart';
import 'package:flutter/material.dart';

/// Swipeable illustrations with parallax, a gentle float and an orbiting halo.
class OnboardingIllustrationPager extends StatefulWidget {
  const OnboardingIllustrationPager({
    super.key,
    required this.controller,
    required this.pages,
    required this.accent,
    required this.onPageChanged,
  });

  final PageController controller;
  final List<OnboardingModel> pages;
  final Color accent;
  final ValueChanged<int> onPageChanged;

  @override
  State<OnboardingIllustrationPager> createState() =>
      _OnboardingIllustrationPagerState();
}

class _OnboardingIllustrationPagerState
    extends State<OnboardingIllustrationPager>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );
  late final AnimationController _orbitCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  );

  @override
  void initState() {
    super.initState();
    final reduceMotion =
        WidgetsBinding
            .instance
            .platformDispatcher
            .accessibilityFeatures
            .disableAnimations;
    if (!reduceMotion) {
      _floatCtrl.repeat(reverse: true);
      _orbitCtrl.repeat();
    }
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _orbitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        return Stack(
          alignment: Alignment.center,
          children: [
            RepaintBoundary(
              child: CustomPaint(
                size: Size.square(side * 0.92),
                painter: _HaloPainter(orbit: _orbitCtrl, accent: widget.accent),
              ),
            ),
            PageView.builder(
              controller: widget.controller,
              itemCount: widget.pages.length,
              onPageChanged: widget.onPageChanged,
              itemBuilder: (context, index) => _buildPage(index, side * 0.82),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPage(int index, double imageSize) {
    final image = Image.asset(
      widget.pages[index].imagePath,
      width: imageSize,
      height: imageSize,
      fit: BoxFit.contain,
      cacheWidth: (imageSize * MediaQuery.devicePixelRatioOf(context)).round(),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([widget.controller, _floatCtrl]),
      child: image,
      builder: (context, child) {
        final delta = (widget.controller.pageOffset - index).clamp(-1.0, 1.0);
        final distance = delta.abs();
        final bob =
            (Curves.easeInOut.transform(_floatCtrl.value) * 2 - 1) *
            imageSize *
            0.025;

        return Opacity(
          opacity: 1 - 0.7 * distance,
          child: Transform.translate(
            offset: Offset(delta * imageSize * 0.4, bob),
            child: Transform.rotate(
              angle: -delta * 0.12,
              child: Transform.scale(scale: 1 - 0.2 * distance, child: child),
            ),
          ),
        );
      },
    );
  }
}

class _HaloPainter extends CustomPainter {
  _HaloPainter({required this.orbit, required this.accent})
    : super(repaint: orbit);

  final Animation<double> orbit;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [accent.withValues(alpha: 0.18), accent.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    canvas.drawCircle(
      center,
      radius * 0.72,
      Paint()..color = accent.withValues(alpha: 0.07),
    );

    final orbitRadius = radius * 0.88;
    canvas.drawCircle(
      center,
      orbitRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.008
        ..color = accent.withValues(alpha: 0.22),
    );

    final angle = orbit.value * 2 * math.pi;
    _drawSatellite(canvas, center, orbitRadius, angle, radius * 0.035, 0.75);
    _drawSatellite(
      canvas,
      center,
      orbitRadius,
      angle + math.pi * 0.85,
      radius * 0.022,
      0.45,
    );
  }

  void _drawSatellite(
    Canvas canvas,
    Offset center,
    double orbitRadius,
    double angle,
    double dotRadius,
    double alpha,
  ) {
    canvas.drawCircle(
      center + Offset(math.cos(angle), math.sin(angle)) * orbitRadius,
      dotRadius,
      Paint()..color = accent.withValues(alpha: alpha),
    );
  }

  @override
  bool shouldRepaint(_HaloPainter oldDelegate) =>
      oldDelegate.accent != accent || oldDelegate.orbit != orbit;
}
