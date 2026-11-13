import 'package:expenser/core/constants/branding.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

/// Plays the brand intro: the monogram springs in with a twist and a ripple,
/// then the wordmark text wipes in from behind it.
///
/// Both layers are slices of the same wordmark SVG, so the asset stays the
/// single source of truth. Slice geometry matches its 1600×480 viewBox.
class AnimatedBrandLogo extends StatelessWidget {
  const AnimatedBrandLogo({
    super.key,
    required this.animation,
    required this.assetPath,
    required this.accentColor,
    required this.width,
  });

  final Animation<double> animation;
  final String assetPath;
  final Color accentColor;
  final double width;

  static const double _iconSlice = 0.27;
  static const double _iconCenterX = 0.15;
  static const double _iconSizeFactor = 320 / 1600;
  static const Alignment _iconAlignment = Alignment(_iconCenterX * 2 - 1, 0);

  static double heightFor(double width) => width / AppBrand.wordmarkAspectRatio;

  static final Animatable<double> _iconFade = CurveTween(
    curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
  );
  static final Animatable<double> _iconScale = Tween<double>(
    begin: 0.3,
    end: 1,
  ).chain(
    CurveTween(curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
  );
  static final Animatable<double> _iconTurn = Tween<double>(
    begin: -0.6,
    end: 0,
  ).chain(
    CurveTween(curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
  );
  static final Animatable<double> _ripple = CurveTween(
    curve: const Interval(0.4, 0.85, curve: Curves.easeOut),
  );
  static final Animatable<double> _textReveal = CurveTween(
    curve: const Interval(0.35, 0.8, curve: Curves.easeOutCubic),
  );

  @override
  Widget build(BuildContext context) {
    final logo = SvgPicture.asset(assetPath, width: width, fit: BoxFit.contain);

    return Transform.translate(
      offset: Offset(width * (0.5 - AppBrand.wordmarkOpticalCenterX), 0),
      child: SizedBox(
        width: width,
        height: heightFor(width),
        child: AnimatedBuilder(
          animation: animation,
          child: logo,
          builder: (context, child) {
            final progress = animation.value;
            return Stack(
              fit: StackFit.expand,
              children: [
                _buildIcon(child!, progress),
                _buildText(child, progress),
                CustomPaint(
                  painter: _RipplePainter(
                    progress: _ripple.transform(progress),
                    color: accentColor,
                    centerX: _iconCenterX,
                    baseRadiusFactor: _iconSizeFactor,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildIcon(Widget logo, double progress) {
    return Opacity(
      opacity: _iconFade.transform(progress),
      child: Transform.rotate(
        angle: _iconTurn.transform(progress),
        alignment: _iconAlignment,
        child: Transform.scale(
          scale: _iconScale.transform(progress),
          alignment: _iconAlignment,
          child: ClipRect(
            clipper: const _HorizontalSliceClipper(0, _iconSlice),
            child: logo,
          ),
        ),
      ),
    );
  }

  Widget _buildText(Widget logo, double progress) {
    final reveal = _textReveal.transform(progress);
    return Opacity(
      opacity: reveal,
      child: ClipRect(
        clipper: _HorizontalSliceClipper(
          _iconSlice,
          _iconSlice + (1 - _iconSlice) * reveal,
        ),
        child: Transform.translate(
          offset: Offset(-width * 0.04 * (1 - reveal), 0),
          child: logo,
        ),
      ),
    );
  }
}

class _HorizontalSliceClipper extends CustomClipper<Rect> {
  const _HorizontalSliceClipper(this.start, this.end);

  final double start;
  final double end;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(size.width * start, 0, size.width * end, size.height);

  @override
  bool shouldReclip(_HorizontalSliceClipper oldClipper) =>
      oldClipper.start != start || oldClipper.end != end;
}

class _RipplePainter extends CustomPainter {
  const _RipplePainter({
    required this.progress,
    required this.color,
    required this.centerX,
    required this.baseRadiusFactor,
  });

  final double progress;
  final Color color;
  final double centerX;
  final double baseRadiusFactor;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    final iconSize = size.width * baseRadiusFactor;
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = iconSize * 0.03 * (1 - progress)
          ..color = color.withValues(alpha: 0.6 * (1 - progress));

    canvas.drawCircle(
      Offset(size.width * centerX, size.height / 2),
      iconSize * (0.6 + 0.4 * progress),
      paint,
    );
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
