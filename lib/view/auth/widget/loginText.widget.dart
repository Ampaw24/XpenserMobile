import 'package:expenser/core/constants/strings.dart';
import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/core/utils/theme/texttheme.dart';
import 'package:flutter/material.dart';

class TitlTextLogin extends StatelessWidget {
  const TitlTextLogin({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App logo or title (optional)
        Text(
          AppStrings.appName,
          style: AppTextStyles.bodyText1.copyWith(
            fontSize: isSmallScreen ? 32 : 42,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          AppStrings.spend,
          style: AppTextStyles.bodyText1.copyWith(
            fontSize: isSmallScreen ? 20 : 28,
            fontWeight: FontWeight.bold,
            color: AppColors.ACCENT,
          ),
        ),
        Text(
          AppStrings.tracker,
          style: AppTextStyles.bodyText1.copyWith(
            fontSize: isSmallScreen ? 10 : 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
