import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:expenser/core/constants/branding.dart';
import 'package:expenser/core/utils/widgets/brand_watermark_background.dart';
import 'package:expenser/core/utils/widgets/brand_wordmark.dart';
import 'package:expenser/core/utils/widgets/reveal_transition.dart';
import 'package:expenser/viewmodels/auth_viewmodel.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:expenser/views/auth/widgets/auth_social_button.dart';
import 'package:expenser/views/auth/widgets/login_glow_backdrop.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:svg_flutter/svg.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  static const double _compactBreakpoint = 600;

  late final AnimationController _entranceCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  late final Animation<double> _glowReveal = _interval(0.0, 0.5);
  late final Animation<double> _logoReveal = _interval(0.0, 0.45);
  late final Animation<double> _titleReveal = _interval(0.25, 0.6);
  late final Animation<double> _subtitleReveal = _interval(0.32, 0.67);
  late final List<Animation<double>> _buttonReveals = [
    for (var i = 0; i < 3; i++) _interval(0.45 + i * 0.07, 0.8 + i * 0.07),
  ];
  late final Animation<double> _footerReveal = _interval(0.72, 1.0);

  bool get _showAppleButton => !kIsWeb && Platform.isIOS;

  Animation<double> _interval(double start, double end) => CurvedAnimation(
    parent: _entranceCtrl,
    curve: Interval(start, end, curve: Curves.easeOutCubic),
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
    if (reduceMotion) {
      _entranceCtrl.value = 1;
    } else {
      _entranceCtrl.forward();
    }
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() =>
      _socialSignIn(ref.read(authProvider.notifier).signInWithGoogle);

  Future<void> _signInWithFacebook() =>
      _socialSignIn(ref.read(authProvider.notifier).signInWithFacebook);

  Future<void> _socialSignIn(Future<void> Function() signIn) async {
    await signIn();
    if (!mounted) return;

    final error = ref.read(authProvider).errorMessage;
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    } else if (ref.read(settingsProvider).isLoggedIn) {
      context.go('/shell/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppBrand.mintAccent : AppBrand.tealPrimary;
    final isLoading = ref.watch(authProvider.select((s) => s.isLoading));
    final watermarkInset = BrandWatermarkBackground.reservedHeight(context);

    return Scaffold(
      body: BrandWatermarkBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: FadeTransition(
                opacity: _glowReveal,
                child: LoginGlowBackdrop(
                  primary: accent,
                  secondary: AppBrand.mintAccent,
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final height = constraints.maxHeight;
                  final contentWidth =
                      width *
                      (constraints.biggest.shortestSide > _compactBreakpoint
                          ? 0.55
                          : 0.86);

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      (width - contentWidth) / 2,
                      0,
                      (width - contentWidth) / 2,
                      watermarkInset,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: math.max(0, height - watermarkInset),
                      ),
                      child: IntrinsicHeight(
                        child: _buildContent(width, height, accent),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (isLoading) _LoadingOverlay(accent: accent),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(double width, double height, Color accent) {
    final gap = height * 0.016;
    final buttons = <Widget>[
      AuthSocialButton(
        primary: true,
        icon: SvgPicture.string(_googleIcon),
        label: 'Continue with Google',
        onPressed: _signInWithGoogle,
      ),
      AuthSocialButton(
        icon: SvgPicture.string(_facebookIcon),
        label: 'Continue with Facebook',
        onPressed: _signInWithFacebook,
      ),
      if (_showAppleButton)
        AuthSocialButton(
          icon: const FaIcon(FontAwesomeIcons.apple),
          label: 'Continue with Apple',
          onPressed: () {},
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(flex: 3),
        RevealTransition(
          animation: _logoReveal,
          slideFrom: const Offset(0, -0.25),
          scaleFrom: 0.85,
          child: Center(
            child: BrandWordmark(width: math.min(width * 0.82, height * 0.75)),
          ),
        ),
        SizedBox(height: height * 0.03),
        RevealTransition(
          animation: _titleReveal,
          slideFrom: const Offset(0, 0.4),
          child: const _Headline(),
        ),
        SizedBox(height: height * 0.008),
        RevealTransition(
          animation: _subtitleReveal,
          slideFrom: const Offset(0, 0.4),
          child: const _Subtitle(),
        ),
        const Spacer(flex: 2),
        for (var i = 0; i < buttons.length; i++) ...[
          if (i > 0) SizedBox(height: gap),
          RevealTransition(
            animation: _buttonReveals[i],
            slideFrom: const Offset(0, 0.5),
            child: buttons[i],
          ),
        ],
        SizedBox(height: height * 0.03),
        RevealTransition(
          animation: _footerReveal,
          child: _SignUpPrompt(
            accent: accent,
            onTap: () => context.push('/register'),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    return Text(
      'Welcome back',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: shortestSide * 0.075,
        fontWeight: FontWeight.w800,
        letterSpacing: -shortestSide * 0.0015,
        color: isDark ? AppBrand.textPrimaryDark : AppBrand.textPrimaryLight,
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    return Text(
      'Sign in to take control of your money.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: shortestSide * 0.038,
        height: 1.4,
        color:
            isDark
                ? AppBrand.textPrimaryDark.withValues(alpha: 0.7)
                : AppBrand.textSecondaryLight,
      ),
    );
  }
}

class _SignUpPrompt extends StatelessWidget {
  const _SignUpPrompt({required this.accent, required this.onTap});

  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fontSize = MediaQuery.sizeOf(context).shortestSide * 0.036;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'New to Xpenser?',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: fontSize,
            color:
                isDark
                    ? AppBrand.textPrimaryDark.withValues(alpha: 0.7)
                    : AppBrand.textSecondaryLight,
          ),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(foregroundColor: accent),
          child: Text(
            'Create an account',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final indicatorSize = MediaQuery.sizeOf(context).shortestSide * 0.1;
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.4),
        child: Center(
          child: SizedBox.square(
            dimension: indicatorSize,
            child: CircularProgressIndicator(
              strokeWidth: indicatorSize * 0.08,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
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
    '''<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M16 8.049C16 3.603 12.418 0 8 0S0 3.603 0 8.049C0 12.067 2.926 15.397 6.75 16V10.375H4.719V8.049H6.75V6.275C6.75 4.27 7.944 3.163 9.771 3.163C10.646 3.163 11.562 3.32 11.562 3.32V5.29H10.553C9.559 5.29 9.25 5.907 9.25 6.541V8.049H11.469L11.114 10.375H9.25V16C13.074 15.397 16 12.067 16 8.049Z" fill="#1877F2"/>
</svg>''';
