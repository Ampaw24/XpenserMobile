import 'dart:io' show Platform;
import 'dart:ui';

import 'package:expenser/core/constants/imageconstants.dart';
import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/viewmodels/auth_viewmodel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:svg_flutter/svg.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  late final Animation<double> _bgFade;
  late final Animation<double> _orb1Scale;
  late final Animation<double> _orb2Scale;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _btn1Fade;
  late final Animation<double> _btn2Fade;
  late final Animation<double> _btn3Fade;


  bool get _showAppleButton => !kIsWeb && Platform.isIOS;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _bgFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
    );

    _orb1Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.40, curve: Curves.elasticOut),
      ),
    );

    _orb2Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.08, 0.45, curve: Curves.elasticOut),
      ),
    );

    _headerFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.20, 0.50, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.20, 0.50, curve: Curves.easeOut),
    ));

    _cardFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.38, 0.65, curve: Curves.easeOut),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.38, 0.65, curve: Curves.easeOut),
    ));

    _btn1Fade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.58, 0.76, curve: Curves.easeOut),
    );
    _btn2Fade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.68, 0.86, curve: Curves.easeOut),
    );
    _btn3Fade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.78, 0.96, curve: Curves.easeOut),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    await ref.read(authProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    final error = ref.read(authProvider).errorMessage;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red.shade700),
      );
    }
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
          FadeTransition(
            opacity: _bgFade,
            child: Container(
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
          ),

          // Top-left orb
          Positioned(
            top: -sh * 0.08,
            left: -sw * 0.20,
            child: ScaleTransition(
              scale: _orb1Scale,
              child: Container(
                width: sw * 0.75,
                height: sw * 0.75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.PRIMARY.withValues(alpha: 0.55),
                      AppColors.ACCENT.withValues(alpha: 0.25),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Bottom-right orb
          Positioned(
            bottom: sh * 0.10,
            right: -sw * 0.25,
            child: ScaleTransition(
              scale: _orb2Scale,
              child: Container(
                width: sw * 0.80,
                height: sw * 0.80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF1DE9B6).withValues(alpha: 0.30),
                      AppColors.ACCENT.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.50, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Small accent orb center-right
          Positioned(
            top: sh * 0.30,
            right: -sw * 0.10,
            child: ScaleTransition(
              scale: _orb1Scale,
              child: Container(
                width: sw * 0.40,
                height: sw * 0.40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF7C4DFF).withValues(alpha: 0.30),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header: logo + branding
                Expanded(
                  flex: 4,
                  child: FadeTransition(
                    opacity: _headerFade,
                    child: SlideTransition(
                      position: _headerSlide,
                      child: _buildHeader(sw, sh),
                    ),
                  ),
                ),

                // Glass card
                Expanded(
                  flex: 6,
                  child: FadeTransition(
                    opacity: _cardFade,
                    child: SlideTransition(
                      position: _cardSlide,
                      child: _buildGlassCard(sw, sh),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading overlay
          if (ref.watch(authProvider).isLoading) _buildLoadingOverlay(sw),
        ],
      ),
    );
  }

  Widget _buildHeader(double sw, double sh) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glass logo container
          ClipRRect(
            borderRadius: BorderRadius.circular(sw * 0.06),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                width: sw * 0.22,
                height: sw * 0.22,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(sw * 0.06),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                    width: 1.2,
                  ),
                ),
                padding: EdgeInsets.all(sw * 0.035),
                child: Image.asset(Imageconstants.applogo),
              ),
            ),
          ),
          SizedBox(height: sh * 0.022),
          Text(
            'Xpenser',
            style: GoogleFonts.montserrat(
              fontSize: sw * 0.082,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: sh * 0.008),
          Text(
            'Smart money management',
            style: GoogleFonts.inter(
              fontSize: sw * 0.036,
              color: Colors.white.withValues(alpha: 0.55),
              fontWeight: FontWeight.w400,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard(double sw, double sh) {
    return Padding(
      padding: EdgeInsets.fromLTRB(sw * 0.06, 0, sw * 0.06, sh * 0.02),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(sw * 0.07),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(sw * 0.07),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.2,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.07,
                vertical: sh * 0.035,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome back',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: sw * 0.055,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: sh * 0.008),
                  Text(
                    'Sign in to continue',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: sw * 0.033,
                      color: Colors.white.withValues(alpha: 0.50),
                    ),
                  ),
                  SizedBox(height: sh * 0.032),

                  // Google
                  FadeTransition(
                    opacity: _btn1Fade,
                    child: _GlassButton(
                      icon: SvgPicture.string(_googleIcon),
                      label: 'Continue with Google',
                      onTap: _handleGoogleSignIn,
                    ),
                  ),
                  SizedBox(height: sh * 0.016),

                  // Facebook
                  FadeTransition(
                    opacity: _btn2Fade,
                    child: _GlassButton(
                      icon: SvgPicture.string(_facebookIcon),
                      label: 'Continue with Facebook',
                      onTap: () {},
                    ),
                  ),

                  // Apple (iOS only)
                  if (_showAppleButton) ...[
                    SizedBox(height: sh * 0.016),
                    FadeTransition(
                      opacity: _btn3Fade,
                      child: _GlassButton(
                        icon: FittedBox(
                          child: Icon(
                            FontAwesomeIcons.apple,
                            color: Colors.white,
                            size: sw * 0.048,
                          ),
                        ),
                        label: 'Continue with Apple',
                        onTap: () {},
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Divider row
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.white.withValues(alpha: 0.15),
                          thickness: 0.8,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: sw * 0.03),
                        child: Text(
                          'New here?',
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.40),
                            fontSize: sw * 0.031,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.white.withValues(alpha: 0.15),
                          thickness: 0.8,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sh * 0.016),

                  // Sign up button — ghost style
                  GestureDetector(
                    onTap: () => context.push('/register'),
                    child: Container(
                      height: sh * 0.060,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(sw * 0.035),
                        border: Border.all(
                          color: AppColors.ACCENT.withValues(alpha: 0.60),
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Create an account',
                          style: GoogleFonts.inter(
                            fontSize: sw * 0.038,
                            fontWeight: FontWeight.w500,
                            color: AppColors.ACCENT,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(double sw) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Container(
        color: Colors.black.withValues(alpha: 0.40),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(sw * 0.05),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: EdgeInsets.all(sw * 0.08),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(sw * 0.05),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                ),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Glass social button ───────────────────────────────────────────────────────

class _GlassButton extends StatefulWidget {
  const _GlassButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<_GlassButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(sw * 0.035),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              height: sh * 0.068,
              decoration: BoxDecoration(
                color: _pressed
                    ? Colors.white.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(sw * 0.035),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.20),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: sw * 0.052,
                    height: sw * 0.052,
                    child: widget.icon,
                  ),
                  SizedBox(width: sw * 0.038),
                  Text(
                    widget.label,
                    style: GoogleFonts.inter(
                      fontSize: sw * 0.038,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
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

// ─── SVG brand icons ───────────────────────────────────────────────────────────

const _googleIcon =
    '''<svg width="16" height="17" viewBox="0 0 16 17" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M15.9988 8.3441C15.9988 7.67295 15.9443 7.18319 15.8265 6.67529H8.1626V9.70453H12.6611C12.5705 10.4573 12.0807 11.5911 10.9923 12.3529L10.9771 12.4543L13.4002 14.3315L13.5681 14.3482C15.1099 12.9243 15.9988 10.8292 15.9988 8.3441Z" fill="#4285F4"/>
<path d="M8.16265 16.3254C10.3666 16.3254 12.2168 15.5998 13.5682 14.3482L10.9924 12.3528C10.3031 12.8335 9.37796 13.1691 8.16265 13.1691C6.00408 13.1691 4.17202 11.7452 3.51894 9.7771L3.42321 9.78523L0.903556 11.7352L0.870605 11.8268C2.2129 14.4933 4.9701 16.3254 8.16265 16.3254Z" fill="#34A853"/>
<path d="M3.519 9.77716C3.34668 9.26927 3.24695 8.72505 3.24695 8.16275C3.24695 7.6004 3.34668 7.05624 3.50994 6.54834L3.50537 6.44017L0.954141 4.45886L0.870669 4.49857C0.317442 5.60508 0 6.84765 0 8.16275C0 9.47785 0.317442 10.7204 0.870669 11.8269L3.519 9.77716Z" fill="#FBBC05"/>
<path d="M8.16265 3.15623C9.69541 3.15623 10.7293 3.81831 11.3189 4.3716L13.6226 2.12231C12.2077 0.807206 10.3666 0 8.16265 0C4.9701 0 2.2129 1.83206 0.870605 4.49853L3.50987 6.54831C4.17202 4.58019 6.00408 3.15623 8.16265 3.15623Z" fill="#EB4335"/>
</svg>''';

const _facebookIcon =
    '''<svg width="8" height="15" viewBox="0 0 8 15" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M5.02224 14.8963V8.10133H7.30305L7.64452 5.45323H5.02224V3.7625C5.02224 2.99583 5.23517 2.4733 6.33467 2.4733L7.73695 2.47265V0.104232C7.49432 0.0720777 6.66197 0 5.6936 0C3.67183 0 2.28768 1.23402 2.28768 3.50037V5.4533H0.000976562V8.1014H2.28761V14.8963L5.02224 14.8963Z" fill="#FFFFFF"/>
</svg>''';
