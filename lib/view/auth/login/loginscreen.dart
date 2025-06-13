import 'package:expenser/core/constants/imageconstants.dart';
import 'package:expenser/core/constants/strings.dart';
import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/core/utils/theme/texttheme.dart';
import 'package:expenser/view/auth/widget/loginText.widget.dart';
import 'package:expenser/view/auth/widget/loginbtn.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void _onGoogleLogin() {
    // Handle Google login
  }

  void _onFacebookLogin() {
    // Handle Facebook login
  }

  void _onAppleLogin() {
    // Handle Apple login
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    // Responsive button width
    final buttonWidth =
        isTablet
            ? screenWidth * 0.4
            : (isSmallScreen ? screenWidth * 0.85 : screenWidth * 0.75);

    // Responsive spacing
    final verticalSpacing = screenHeight * 0.02;
    final buttonHeight = isSmallScreen ? 44.0 : 48.0;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(Imageconstants.bannerImage, fit: BoxFit.cover),
            Container(color: AppColors.OPBLACK),
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenHeight * 0.02,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TitlTextLogin(),
                            if (screenHeight > 600) ...[
                              SizedBox(height: screenHeight * 0.1),
                            ],

                            CustomLoginButton(
                              context: context,
                              icon: FontAwesomeIcons.google,
                              iconColor: Colors.red,
                              label: 'Continue with Google',
                              backgroundColor: Colors.white,
                              textColor: Colors.black,
                              width: buttonWidth,
                              height: buttonHeight,
                              onPressed: _onGoogleLogin,
                            ),

                            SizedBox(height: verticalSpacing),

                            CustomLoginButton(
                              context: context,
                              icon: FontAwesomeIcons.facebook,
                              iconColor: Colors.white,
                              label: 'Continue with Facebook',
                              backgroundColor: const Color(0xFF1877F3),
                              textColor: Colors.white,
                              width: buttonWidth,
                              height: buttonHeight,
                              onPressed: _onFacebookLogin,
                            ),

                            SizedBox(height: verticalSpacing),

                            CustomLoginButton(
                              context: context,
                              icon: FontAwesomeIcons.apple,
                              iconColor: Colors.white,
                              label: 'Continue with Apple',
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              width: buttonWidth,
                              height: buttonHeight,
                              onPressed: _onAppleLogin,
                            ),

                            if (screenHeight > 600) ...[
                              SizedBox(height: screenHeight * 0.1),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
