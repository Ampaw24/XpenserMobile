import 'dart:math' as math;

import 'package:expenser/core/constants/branding.dart';
import 'package:expenser/core/utils/widgets/brand_watermark_background.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:expenser/views/splash/widgets/animated_brand_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _sloganFade;
  late final Animation<Offset> _sloganSlide;

  static const Duration _sloganReadTime = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    final sloganCurve = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOutCubic),
    );
    _sloganFade = sloganCurve;
    _sloganSlide = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(sloganCurve);

    _playIntro()
        .then((_) => Future<void>.delayed(_sloganReadTime))
        .then((_) => _navigateToNextScreen());
  }

  Future<void> _playIntro() {
    final reduceMotion =
        WidgetsBinding
            .instance
            .platformDispatcher
            .accessibilityFeatures
            .disableAnimations;
    if (reduceMotion) {
      _animCtrl.value = 1;
      return Future<void>.value();
    }
    return _animCtrl.forward();
  }

  void _navigateToNextScreen() {
    if (!mounted) return;
    final settings = ref.read(settingsProvider);

    if (settings.isFirstLaunch) {
      context.go('/onboarding');
    } else if (settings.isLoggedIn) {
      context.go('/shell/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        ref.watch(settingsProvider.select((s) => s.isDarkMode)) ||
        Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppBrand.spruceDark : Colors.white;
    final brandAsset = isDark ? AppBrand.wordmarkDark : AppBrand.wordmarkLight;
    final accentColor = isDark ? AppBrand.mintAccent : AppBrand.tealPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      body: BrandWatermarkBackground(
        isDark: isDark,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final shortestSide = constraints.biggest.shortestSide;
            final logoWidth = math.min(
              constraints.maxWidth * 0.8,
              shortestSide * 0.7,
            );
            final sloganTop =
                constraints.maxHeight / 2 +
                AnimatedBrandLogo.heightFor(logoWidth) / 2;

            return Stack(
              children: [
                Center(
                  child: AnimatedBrandLogo(
                    animation: _animCtrl,
                    assetPath: brandAsset,
                    accentColor: accentColor,
                    width: logoWidth,
                  ),
                ),
                Positioned(
                  top: sloganTop,
                  left: constraints.maxWidth * 0.08,
                  right: constraints.maxWidth * 0.08,
                  child: FadeTransition(
                    opacity: _sloganFade,
                    child: SlideTransition(
                      position: _sloganSlide,
                      child: Text(
                        AppBrand.slogan,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: shortestSide * 0.04,
                          fontWeight: FontWeight.w500,
                          letterSpacing: shortestSide * 0.002,
                          color:
                              isDark
                                  ? AppBrand.textSecondaryDark
                                  : AppBrand.textSecondaryLight,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
