import 'dart:ui';

import 'package:expenser/core/constants/imageconstants.dart';
import 'package:expenser/core/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainCtrl;
  late final AnimationController _pulseCtrl;

  // Orbs
  late final Animation<double> _orb1Scale;
  late final Animation<double> _orb2Scale;
  late final Animation<double> _orb3Scale;

  // Logo glass container
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;

  // App name
  late final Animation<double> _nameFade;
  late final Animation<Offset> _nameSlide;

  // Tagline
  late final Animation<double> _tagFade;

  // Dots
  late final Animation<double> _dotsFade;
  late final Animation<double> _dot1Opacity;
  late final Animation<double> _dot2Opacity;
  late final Animation<double> _dot3Opacity;

  @override
  void initState() {
    super.initState();

    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // Orbs
    _orb1Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
      ),
    );
    _orb2Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.05, 0.50, curve: Curves.elasticOut),
      ),
    );
    _orb3Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.10, 0.50, curve: Curves.elasticOut),
      ),
    );

    // Logo
    _logoScale = Tween<double>(begin: 0.50, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOutBack),
      ),
    );
    _logoFade = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.15, 0.55, curve: Curves.easeOut),
    );

    // Name
    _nameFade = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.42, 0.68, curve: Curves.easeOut),
    );
    _nameSlide = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.42, 0.68, curve: Curves.easeOut),
    ));

    // Tagline
    _tagFade = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.60, 0.82, curve: Curves.easeIn),
    );

    // Loading dots
    _dotsFade = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.78, 1.0, curve: Curves.easeIn),
    );
    _dot1Opacity = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseCtrl,
        curve: const Interval(0.0, 0.35, curve: Curves.easeInOut),
      ),
    );
    _dot2Opacity = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseCtrl,
        curve: const Interval(0.30, 0.65, curve: Curves.easeInOut),
      ),
    );
    _dot3Opacity = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseCtrl,
        curve: const Interval(0.60, 0.95, curve: Curves.easeInOut),
      ),
    );

    _mainCtrl.forward();

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;

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

          // Orb — top left teal
          Positioned(
            top: -sh * 0.10,
            left: -sw * 0.22,
            child: ScaleTransition(
              scale: _orb1Scale,
              child: Container(
                width: sw * 0.80,
                height: sw * 0.80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.PRIMARY.withValues(alpha: 0.55),
                      AppColors.ACCENT.withValues(alpha: 0.20),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Orb — bottom right mint
          Positioned(
            bottom: sh * 0.08,
            right: -sw * 0.25,
            child: ScaleTransition(
              scale: _orb2Scale,
              child: Container(
                width: sw * 0.85,
                height: sw * 0.85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF1DE9B6).withValues(alpha: 0.28),
                      AppColors.ACCENT.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.50, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Orb — center right purple
          Positioned(
            top: sh * 0.32,
            right: -sw * 0.12,
            child: ScaleTransition(
              scale: _orb3Scale,
              child: Container(
                width: sw * 0.45,
                height: sw * 0.45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF7C4DFF).withValues(alpha: 0.28),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glass logo container
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(sw * 0.065),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          width: sw * 0.28,
                          height: sw * 0.28,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(sw * 0.065),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.20),
                              width: 1.2,
                            ),
                          ),
                          padding: EdgeInsets.all(sw * 0.045),
                          child: Image.asset(Imageconstants.applogo),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: sh * 0.028),

                // App name
                FadeTransition(
                  opacity: _nameFade,
                  child: SlideTransition(
                    position: _nameSlide,
                    child: Text(
                      'Xpenser',
                      style: GoogleFonts.montserrat(
                        fontSize: sw * 0.085,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: sh * 0.010),

                // Tagline
                FadeTransition(
                  opacity: _tagFade,
                  child: Text(
                    'Smart money management',
                    style: GoogleFonts.inter(
                      fontSize: sw * 0.037,
                      color: Colors.white.withValues(alpha: 0.50),
                      letterSpacing: 0.4,
                    ),
                  ),
                ),

                SizedBox(height: sh * 0.075),

                // Pulsing loading dots
                FadeTransition(
                  opacity: _dotsFade,
                  child: AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, __) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Dot(opacity: _dot1Opacity.value, sw: sw),
                        SizedBox(width: sw * 0.025),
                        _Dot(opacity: _dot2Opacity.value, sw: sw),
                        SizedBox(width: sw * 0.025),
                        _Dot(opacity: _dot3Opacity.value, sw: sw),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.opacity, required this.sw});
  final double opacity;
  final double sw;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: sw * 0.018,
        height: sw * 0.018,
        decoration: BoxDecoration(
          color: AppColors.ACCENT,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
