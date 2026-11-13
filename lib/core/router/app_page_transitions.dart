import 'package:expenser/core/utils/theme/app_motion.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Route pages for flows that should not use the platform push transition.
/// Regular drill-down routes use [AppMotion.pageTransitionsTheme] instead.
abstract final class AppPageTransitions {
  /// Cross-fade with a subtle zoom for flow switches (splash, auth, shell).
  static Page<void> fadeThrough(GoRouterState state, Widget child) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      name: state.name,
      child: child,
      transitionDuration: AppMotion.page,
      reverseTransitionDuration: AppMotion.medium,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (AppMotion.reduced(context)) return child;
        final curve = CurveTween(curve: AppMotion.enter);
        return FadeTransition(
          opacity: animation.drive(curve),
          child: ScaleTransition(
            scale: animation.drive(Tween(begin: 0.96, end: 1.0).chain(curve)),
            child: child,
          ),
        );
      },
    );
  }

  /// Slides up like a sheet for create flows; shows a close button.
  static Page<void> modal(GoRouterState state, Widget child) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      name: state.name,
      child: child,
      fullscreenDialog: true,
      transitionDuration: AppMotion.page,
      reverseTransitionDuration: AppMotion.medium,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (AppMotion.reduced(context)) return child;
        final curve = CurveTween(curve: AppMotion.enter);
        return SlideTransition(
          position: animation.drive(
            Tween(begin: const Offset(0, 0.12), end: Offset.zero).chain(curve),
          ),
          child: FadeTransition(opacity: animation.drive(curve), child: child),
        );
      },
    );
  }
}
