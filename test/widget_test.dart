import 'package:expenser/core/constants/branding.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Xpenser App Branding & Theme Tests', () {
    test('Branding asset constants are defined and correct', () {
      expect(
        AppBrand.wordmarkLight,
        'assets/xpenser-C-x-monogram-wordmark-light.svg',
      );
      expect(
        AppBrand.wordmarkDark,
        'assets/xpenser-C-x-monogram-wordmark-dark.svg',
      );
      expect(AppBrand.monogram, 'assets/images/xpenser-C-x-monogram.svg');
      expect(AppBrand.spruceDark, const Color(0xFF042F2E));
      expect(AppBrand.tealPrimary, const Color(0xFF0F766E));
      expect(AppBrand.mintAccent, const Color(0xFF2DD4BF));
    });

    test('Light theme has correct brand primary and surface colors', () {
      final light = AppTheme.light;
      expect(light.brightness, Brightness.light);
      expect(light.colorScheme.primary, AppBrand.tealPrimary);
      expect(light.scaffoldBackgroundColor, AppBrand.backgroundLight);
    });

    test('Light theme page background is neutral, not brand green', () {
      final background = AppTheme.light.scaffoldBackgroundColor;
      expect(background, isNot(AppBrand.spruceDark));
      expect(background.computeLuminance(), greaterThan(0.9));
    });

    test('Dark theme has spruce background and mint primary for contrast', () {
      final dark = AppTheme.dark;
      expect(dark.brightness, Brightness.dark);
      expect(dark.colorScheme.primary, AppBrand.mintAccent);
      expect(dark.colorScheme.secondary, AppBrand.mintAccent);
      expect(dark.scaffoldBackgroundColor, AppBrand.backgroundDark);
    });

    test('Both themes expose the AppPalette extension', () {
      expect(AppTheme.light.extension<AppPalette>(), AppPalette.light);
      expect(AppTheme.dark.extension<AppPalette>(), AppPalette.dark);
    });
  });
}
