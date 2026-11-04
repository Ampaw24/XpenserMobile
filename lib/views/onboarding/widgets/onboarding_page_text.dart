import 'package:expenser/core/constants/branding.dart';
import 'package:expenser/core/utils/widgets/reveal_transition.dart';
import 'package:flutter/material.dart';

/// Step label, title and description that stagger in each time a page
/// appears. Give it a distinct key per page so it re-plays on change.
class OnboardingPageText extends StatefulWidget {
  const OnboardingPageText({
    super.key,
    required this.stepLabel,
    required this.title,
    required this.description,
    required this.accent,
  });

  final String stepLabel;
  final String title;
  final String description;
  final Color accent;

  @override
  State<OnboardingPageText> createState() => _OnboardingPageTextState();
}

class _OnboardingPageTextState extends State<OnboardingPageText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  late final List<Animation<double>> _stagger = [
    for (final (start, end) in const [(0.0, 0.55), (0.12, 0.75), (0.3, 1.0)])
      CurvedAnimation(
        parent: _ctrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        isDark ? AppBrand.textPrimaryDark : AppBrand.textPrimaryLight;
    final bodyColor =
        isDark
            ? AppBrand.textPrimaryDark.withValues(alpha: 0.7)
            : AppBrand.textSecondaryLight;

    final splitAt = widget.title.lastIndexOf(' ') + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RevealTransition(
          animation: _stagger[0],
          slideFrom: const Offset(0, 0.35),
          child: Text(
            widget.stepLabel,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: width * 0.032,
              fontWeight: FontWeight.w700,
              letterSpacing: width * 0.004,
              color: widget.accent,
            ),
          ),
        ),
        SizedBox(height: width * 0.025),
        RevealTransition(
          animation: _stagger[1],
          slideFrom: const Offset(0, 0.35),
          child: Text.rich(
            TextSpan(
              text: widget.title.substring(0, splitAt),
              children: [
                TextSpan(
                  text: widget.title.substring(splitAt),
                  style: TextStyle(color: widget.accent),
                ),
              ],
            ),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: width * 0.072,
              fontWeight: FontWeight.w800,
              letterSpacing: -width * 0.0015,
              height: 1.15,
              color: titleColor,
            ),
          ),
        ),
        SizedBox(height: width * 0.03),
        RevealTransition(
          animation: _stagger[2],
          slideFrom: const Offset(0, 0.35),
          child: Text(
            widget.description.replaceAll('\n', ' '),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: width * 0.038,
              height: 1.5,
              color: bodyColor,
            ),
          ),
        ),
      ],
    );
  }
}
