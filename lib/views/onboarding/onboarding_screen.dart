import 'dart:ui';

import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/viewmodels/onboarding_viewmodel.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageCtrl;
  late final AnimationController _entranceCtrl;

  late final Animation<double> _orbScale;
  late final Animation<double> _illustrationFade;
  late final Animation<Offset> _illustrationSlide;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;

  int _currentPage = 0;
  bool _isAnimatingForward = true;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _orbScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
      ),
    );

    _illustrationFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.20, 0.60, curve: Curves.easeOut),
    );
    _illustrationSlide = Tween<Offset>(
      begin: const Offset(0, -0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.20, 0.60, curve: Curves.easeOut),
    ));

    _cardFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.42, 0.78, curve: Curves.easeOut),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.20),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.42, 0.78, curve: Curves.easeOut),
    ));

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _isAnimatingForward = index > _currentPage;
      _currentPage = index;
    });
  }

  Future<void> _advance(int total) async {
    if (_currentPage < total - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    } else {
      await ref.read(settingsProvider.notifier).markOnboardingComplete();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = ref.watch(onboardingProvider);
    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;
    final isLast = _currentPage == pages.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A0E21),
                  Color(0xFF0D1B2A),
                  Color(0xFF0A1628),
                ],
              ),
            ),
          ),

          // Orb — top left
          Positioned(
            top: -sh * 0.08,
            left: -sw * 0.22,
            child: ScaleTransition(
              scale: _orbScale,
              child: Container(
                width: sw * 0.75,
                height: sw * 0.75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.PRIMARY.withValues(alpha: 0.50),
                      AppColors.ACCENT.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Orb — bottom right
          Positioned(
            bottom: sh * 0.12,
            right: -sw * 0.25,
            child: ScaleTransition(
              scale: _orbScale,
              child: Container(
                width: sw * 0.75,
                height: sw * 0.75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF1DE9B6).withValues(alpha: 0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Illustration area (PageView — full swipe gesture)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: sh * 0.52,
            child: FadeTransition(
              opacity: _illustrationFade,
              child: SlideTransition(
                position: _illustrationSlide,
                child: PageView.builder(
                  controller: _pageCtrl,
                  itemCount: pages.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (_, i) => _IllustrationPage(
                    imagePath: pages[i].imagePath,
                    sw: sw,
                    sh: sh,
                  ),
                ),
              ),
            ),
          ),

          // Glass card (bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: sh * 0.52,
            child: FadeTransition(
              opacity: _cardFade,
              child: SlideTransition(
                position: _cardSlide,
                child: _BottomCard(
                  pages: pages,
                  currentPage: _currentPage,
                  isLast: isLast,
                  isAnimatingForward: _isAnimatingForward,
                  sw: sw,
                  sh: sh,
                  onAdvance: () => _advance(pages.length),
                ),
              ),
            ),
          ),

          // Skip button (top right, hidden on last page)
          if (!isLast)
            Positioned(
              top: MediaQuery.of(context).padding.top + sh * 0.018,
              right: sw * 0.06,
              child: FadeTransition(
                opacity: _illustrationFade,
                child: GestureDetector(
                  onTap: () async {
                    await ref
                        .read(settingsProvider.notifier)
                        .markOnboardingComplete();
                    if (context.mounted) context.go('/login');
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.04,
                      vertical: sh * 0.010,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(sw * 0.05),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.60),
                        fontSize: sw * 0.033,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Illustration page ─────────────────────────────────────────────────────────

class _IllustrationPage extends StatelessWidget {
  const _IllustrationPage({
    required this.imagePath,
    required this.sw,
    required this.sh,
  });
  final String imagePath;
  final double sw, sh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        sw * 0.08,
        sh * 0.10,
        sw * 0.08,
        sh * 0.02,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft glow behind illustration
          Container(
            width: sw * 0.60,
            height: sw * 0.60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.ACCENT.withValues(alpha: 0.18),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

// ─── Bottom glass card ─────────────────────────────────────────────────────────

class _BottomCard extends StatelessWidget {
  const _BottomCard({
    required this.pages,
    required this.currentPage,
    required this.isLast,
    required this.isAnimatingForward,
    required this.sw,
    required this.sh,
    required this.onAdvance,
  });

  final List pages;
  final int currentPage;
  final bool isLast;
  final bool isAnimatingForward;
  final double sw, sh;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(sw * 0.05, 0, sw * 0.05, sh * 0.028),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(sw * 0.07),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(sw * 0.07),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.13),
                width: 1.2,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.07,
                vertical: sh * 0.032,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Pill page indicator
                  _PillIndicator(
                    count: pages.length,
                    current: currentPage,
                    sw: sw,
                    sh: sh,
                  ),

                  SizedBox(height: sh * 0.028),

                  // Animated text content
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 380),
                      transitionBuilder: (child, anim) {
                        final offset = isAnimatingForward
                            ? const Offset(0.18, 0)
                            : const Offset(-0.18, 0);
                        return FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: offset,
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: anim,
                              curve: Curves.easeOut,
                            )),
                            child: child,
                          ),
                        );
                      },
                      child: _PageText(
                        key: ValueKey(currentPage),
                        title: pages[currentPage].title,
                        description: pages[currentPage].description,
                        sw: sw,
                        sh: sh,
                      ),
                    ),
                  ),

                  SizedBox(height: sh * 0.022),

                  // CTA button
                  _CtaButton(
                    label: isLast ? 'Get Started' : 'Next',
                    sw: sw,
                    sh: sh,
                    onTap: onAdvance,
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

// ─── Pill page indicator ───────────────────────────────────────────────────────

class _PillIndicator extends StatelessWidget {
  const _PillIndicator({
    required this.count,
    required this.current,
    required this.sw,
    required this.sh,
  });
  final int count, current;
  final double sw, sh;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: sw * 0.012),
          width: isActive ? sw * 0.080 : sw * 0.022,
          height: sh * 0.008,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.ACCENT
                : Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(sh * 0.004),
          ),
        );
      }),
    );
  }
}

// ─── Page text content ─────────────────────────────────────────────────────────

class _PageText extends StatelessWidget {
  const _PageText({
    super.key,
    required this.title,
    required this.description,
    required this.sw,
    required this.sh,
  });
  final String title, description;
  final double sw, sh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: sw * 0.058,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.25,
          ),
        ),
        SizedBox(height: sh * 0.014),
        Text(
          description.replaceAll('\n', ' '),
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: sw * 0.036,
            color: Colors.white.withValues(alpha: 0.55),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

// ─── CTA button ────────────────────────────────────────────────────────────────

class _CtaButton extends StatefulWidget {
  const _CtaButton({
    required this.label,
    required this.sw,
    required this.sh,
    required this.onTap,
  });
  final String label;
  final double sw, sh;
  final VoidCallback onTap;

  @override
  State<_CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<_CtaButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: widget.sh * 0.065,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.PRIMARY,
                AppColors.ACCENT,
              ],
            ),
            borderRadius: BorderRadius.circular(widget.sw * 0.035),
            boxShadow: [
              BoxShadow(
                color: AppColors.ACCENT.withValues(alpha: _pressed ? 0.20 : 0.35),
                blurRadius: _pressed ? 8 : 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.montserrat(
                fontSize: widget.sw * 0.040,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
