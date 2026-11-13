import 'package:expenser/core/utils/theme/app_motion.dart';
import 'package:flutter/material.dart';

/// Keeps every tab's navigator alive (like IndexedStack) but slides and
/// fades between them in the direction of travel.
class AnimatedBranchContainer extends StatelessWidget {
  const AnimatedBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  /// Horizontal offset, as a fraction of width, for inactive tabs.
  static const double _travel = 0.06;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context, AppMotion.medium);
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var index = 0; index < children.length; index++)
          _Branch(
            isActive: index == currentIndex,
            offset:
                index == currentIndex
                    ? Offset.zero
                    : Offset(index < currentIndex ? -_travel : _travel, 0),
            duration: duration,
            child: children[index],
          ),
      ],
    );
  }
}

class _Branch extends StatelessWidget {
  const _Branch({
    required this.isActive,
    required this.offset,
    required this.duration,
    required this.child,
  });

  final bool isActive;
  final Offset offset;
  final Duration duration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isActive,
      child: ExcludeFocus(
        excluding: !isActive,
        child: ExcludeSemantics(
          excluding: !isActive,
          child: AnimatedOpacity(
            opacity: isActive ? 1 : 0,
            duration: duration,
            curve: isActive ? AppMotion.enter : AppMotion.exit,
            child: AnimatedSlide(
              offset: offset,
              duration: duration,
              curve: AppMotion.enter,
              child: TickerMode(enabled: isActive, child: child),
            ),
          ),
        ),
      ),
    );
  }
}
