import 'package:expenser/models/app_settings_model.dart';

class RouteGuard {
  RouteGuard(this._settings);

  final AppSettingsModel _settings;

  static const _authPaths = [
    '/login',
    '/register',
    '/forgot-password',
    '/onboarding',
  ];

  static const profileSetupPath = '/profile-setup';

  String? redirect(String path) {
    if (path == '/splash') return null;

    if (_settings.isFirstLaunch && path != '/onboarding') return '/onboarding';

    if (!_settings.isLoggedIn) {
      return _authPaths.contains(path) ? null : '/login';
    }

    // Country and currency come before every feature.
    if (!_settings.hasLocale) {
      return path == profileSetupPath ? null : profileSetupPath;
    }

    if (_authPaths.contains(path) || path == profileSetupPath) {
      return '/shell/dashboard';
    }

    return null;
  }
}
