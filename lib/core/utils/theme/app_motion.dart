import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

/// Central motion tokens (Material 3 durations and easing).
abstract final class AppMotion {
  static const Duration fast = Durations.short4;
  static const Duration medium = Durations.medium2;
  static const Duration page = Durations.medium4;

  static const Curve enter = Easing.emphasizedDecelerate;
  static const Curve exit = Easing.emphasizedAccelerate;
  static const Curve standard = Easing.standard;
  static const Curve bounce = Curves.easeOutBack;

  /// Native per-platform route transitions; Android supports predictive back.
  static const pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.fuchsia: FadeForwardsPageTransitionsBuilder(),
    },
  );

  /// True when the OS asks for reduced motion.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// [duration], or zero when reduced motion is requested.
  static Duration of(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;
}
