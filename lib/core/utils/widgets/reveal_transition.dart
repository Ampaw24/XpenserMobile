import 'package:flutter/widgets.dart';

/// Fades [child] in while sliding it (as a fraction of its own size) from
/// [slideFrom] and scaling it from [scaleFrom], driven by [animation] (0→1).
class RevealTransition extends StatelessWidget {
  const RevealTransition({
    super.key,
    required this.animation,
    required this.child,
    this.slideFrom = Offset.zero,
    this.scaleFrom = 1,
  });

  final Animation<double> animation;
  final Widget child;
  final Offset slideFrom;
  final double scaleFrom;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: AnimatedBuilder(
        animation: animation,
        child: child,
        builder: (context, child) {
          final progress = animation.value;
          return FractionalTranslation(
            translation: slideFrom * (1 - progress),
            child: Transform.scale(
              scale: scaleFrom + (1 - scaleFrom) * progress,
              child: child,
            ),
          );
        },
      ),
    );
  }
}
