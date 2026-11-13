import 'package:flutter/material.dart';

abstract final class AppBrand {
  // Brand Assets (Authoritative SVGs)
  static const String wordmarkLight =
      'assets/xpenser-C-x-monogram-wordmark-light.svg';
  static const String wordmarkDark =
      'assets/xpenser-C-x-monogram-wordmark-dark.svg';
  static const String monogram = 'assets/images/xpenser-C-x-monogram.svg';
  static const String iconSquare = 'assets/images/icons/app_icon_square.png';

  static const String slogan = 'Track smart. Spend wise.';

  // Wordmark SVG geometry (1600×480 canvas). Artwork spans x≈80–1050, so its
  // optical centre sits left of the canvas centre.
  static const double wordmarkAspectRatio = 1600 / 480;
  static const double wordmarkOpticalCenterX = 565 / 1600;

  // Authoritative Color Palette
  static const Color spruceDark = Color(0xFF042F2E);
  static const Color tealPrimary = Color(0xFF0F766E);
  static const Color mintAccent = Color(0xFF2DD4BF);
  static const Color mintLight = Color(0xFF99F6E4);
  static const Color mintSoft = Color(0xFF5EEAD4);

  // Surface & Neutral Tokens
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  static const Color backgroundDark = Color(0xFF042F2E);
  static const Color surfaceDark = Color(0xFF073836);
  static const Color surfaceDarkElevated = Color(0xFF0C4644);
  static const Color borderDark = Color(0xFF135B58);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF99F6E4);
  static const Color textMutedDark = Color(0xFF5EEAD4);
}
