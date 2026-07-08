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

  String? redirect(String path) {
    if (path == '/splash') return null;

    if (_settings.isFirstLaunch && path != '/onboarding') return '/onboarding';

    if (!_settings.isLoggedIn && !_authPaths.contains(path)) return '/login';

    if (_settings.isLoggedIn && _authPaths.contains(path)) {
      return '/shell/dashboard';
    }

    return null;
  }
}
