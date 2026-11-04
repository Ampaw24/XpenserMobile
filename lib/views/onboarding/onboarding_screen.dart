import 'package:expenser/core/constants/branding.dart';
import 'package:expenser/core/utils/widgets/brand_watermark_background.dart';
import 'package:expenser/core/utils/widgets/reveal_transition.dart';
import 'package:expenser/viewmodels/onboarding_viewmodel.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:expenser/views/onboarding/widgets/onboarding_illustration_pager.dart';
import 'package:expenser/views/onboarding/widgets/onboarding_next_button.dart';
import 'package:expenser/views/onboarding/widgets/onboarding_page_indicator.dart';
import 'package:expenser/views/onboarding/widgets/onboarding_page_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:svg_flutter/svg.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  late final AnimationController _entranceCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  late final Animation<double> _topBarReveal = _interval(0.0, 0.5);
  late final Animation<double> _illustrationReveal = _interval(0.1, 0.8);
  late final Animation<double> _bottomReveal = _interval(0.4, 1.0);

  int _currentPage = 0;

  Animation<double> _interval(double start, double end) => CurvedAnimation(
    parent: _entranceCtrl,
    curve: Interval(start, end, curve: Curves.easeOutCubic),
  );

  @override
  void initState() {
    super.initState();
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    HapticFeedback.selectionClick();
    setState(() => _currentPage = index);
  }

  void _advance(int total) {
    if (_currentPage < total - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await ref.read(settingsProvider.notifier).markOnboardingComplete();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final pages = ref.watch(onboardingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppBrand.mintAccent : AppBrand.tealPrimary;
    final isLast = _currentPage == pages.length - 1;
    final watermarkInset = BrandWatermarkBackground.reservedHeight(context);

    return Scaffold(
      body: BrandWatermarkBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              final gutter = EdgeInsets.symmetric(horizontal: width * 0.06);

              return Column(
                children: [
                  SizedBox(height: height * 0.015),
                  RevealTransition(
                    animation: _topBarReveal,
                    slideFrom: const Offset(0, -0.4),
                    child: Padding(
                      padding: gutter,
                      child: _TopBar(
                        accent: accent,
                        showSkip: !isLast,
                        onSkip: _finish,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: RevealTransition(
                      animation: _illustrationReveal,
                      scaleFrom: 0.85,
                      child: OnboardingIllustrationPager(
                        controller: _pageCtrl,
                        pages: pages,
                        accent: accent,
                        onPageChanged: _onPageChanged,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: gutter,
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          layoutBuilder:
                              (current, previous) => Stack(
                                alignment: Alignment.topLeft,
                                children: [
                                  ...previous,
                                  if (current != null) current,
                                ],
                              ),
                          child: OnboardingPageText(
                            key: ValueKey(_currentPage),
                            stepLabel: _stepLabel(_currentPage, pages.length),
                            title: pages[_currentPage].title,
                            description: pages[_currentPage].description,
                            accent: accent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  RevealTransition(
                    animation: _bottomReveal,
                    slideFrom: const Offset(0, 0.5),
                    child: Padding(
                      padding: gutter,
                      child: Row(
                        children: [
                          OnboardingPageIndicator(
                            controller: _pageCtrl,
                            count: pages.length,
                            activeColor: accent,
                            inactiveColor: accent.withValues(alpha: 0.18),
                            dotSize: width * 0.022,
                          ),
                          const Spacer(),
                          OnboardingNextButton(
                            controller: _pageCtrl,
                            pageCount: pages.length,
                            isLast: isLast,
                            accent: accent,
                            foreground:
                                isDark ? AppBrand.spruceDark : Colors.white,
                            onPressed: () => _advance(pages.length),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: watermarkInset + height * 0.02),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _stepLabel(int index, int total) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(index + 1)} / ${pad(total)}';
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.accent,
    required this.showSkip,
    required this.onSkip,
  });

  final Color accent;
  final bool showSkip;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppBrand.textPrimaryDark : AppBrand.textPrimaryLight;

    return Row(
      children: [
        SvgPicture.asset(AppBrand.monogram, height: width * 0.085),
        SizedBox(width: width * 0.025),
        Text(
          'Xpenser',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: width * 0.048,
            fontWeight: FontWeight.w800,
            letterSpacing: -width * 0.001,
            color: textColor,
          ),
        ),
        const Spacer(),
        AnimatedOpacity(
          opacity: showSkip ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: IgnorePointer(
            ignoring: !showSkip,
            child: TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                foregroundColor: accent,
                backgroundColor: accent.withValues(alpha: 0.1),
                shape: const StadiumBorder(),
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.045,
                  vertical: width * 0.02,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Skip',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: width * 0.036,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
