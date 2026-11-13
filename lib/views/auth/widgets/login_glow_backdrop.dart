import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Two soft, slowly drifting colour glows that sit behind the login header.
class LoginGlowBackdrop extends StatefulWidget {
  const LoginGlowBackdrop({
    super.key,
    required this.primary,
    required this.secondary,
  });

  final Color primary;
  final Color secondary;

  @override
  State<LoginGlowBackdrop> createState() => _LoginGlowBackdropState();
}

class _LoginGlowBackdropState extends State<LoginGlowBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
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
    if (!reduceMotion) _drift.repeat(reverse: true);
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _GlowPainter(
            drift: _drift,
            primary: widget.primary,
            secondary: widget.secondary,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  _GlowPainter({
    required this.drift,
    required this.primary,
    required this.secondary,
  }) : super(repaint: drift);

  final Animation<double> drift;
  final Color primary;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    final phase = Curves.easeInOut.transform(drift.value) * 2 * math.pi;
    final wobble = size.width * 0.06;

    _drawGlow(
      canvas,
      center: Offset(
        size.width * 0.15 + math.cos(phase) * wobble,
        size.height * 0.12 + math.sin(phase) * wobble,
      ),
      radius: size.width * 0.75,
      color: primary.withValues(alpha: 0.16),
    );
    _drawGlow(
      canvas,
      center: Offset(
        size.width * 0.9 - math.sin(phase) * wobble,
        size.height * 0.28 + math.cos(phase) * wobble,
      ),
      radius: size.width * 0.6,
      color: secondary.withValues(alpha: 0.14),
    );
  }

  void _drawGlow(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
  }) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GlowPainter oldDelegate) =>
      oldDelegate.primary != primary ||
      oldDelegate.secondary != secondary ||
      oldDelegate.drift != drift;
}
