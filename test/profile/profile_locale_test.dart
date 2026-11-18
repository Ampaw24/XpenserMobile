import 'package:expenser/core/constants/countries.dart';
import 'package:expenser/core/router/route_guard.dart';
import 'package:expenser/models/app_settings_model.dart';
import 'package:expenser/models/user_profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

AppSettingsModel _settings({bool loggedIn = true, String? country}) =>
    AppSettingsModel(
      isFirstLaunch: false,
      isLoggedIn: loggedIn,
      uid: loggedIn ? 'u1' : null,
      countryCode: country,
    );

void main() {
  group('RouteGuard', () {
    test('sends signed-in users without a country to setup first', () {
      final guard = RouteGuard(_settings());
      expect(guard.redirect('/shell/dashboard'), RouteGuard.profileSetupPath);
      expect(guard.redirect('/savings'), RouteGuard.profileSetupPath);
      expect(guard.redirect('/login'), RouteGuard.profileSetupPath);
      expect(guard.redirect(RouteGuard.profileSetupPath), isNull);
    });

    test('leaves setup once the country is set', () {
      final guard = RouteGuard(_settings(country: 'GH'));
      expect(guard.redirect(RouteGuard.profileSetupPath), '/shell/dashboard');
      expect(guard.redirect('/shell/budgets'), isNull);
    });

    test('signed-out users still go to login, never setup', () {
      final guard = RouteGuard(_settings(loggedIn: false));
      expect(guard.redirect(RouteGuard.profileSetupPath), '/login');
      expect(guard.redirect('/login'), isNull);
    });
  });

  group('UserProfileModel locale', () {
    const base = {
      'uid': 'u1',
      'displayName': 'Ama',
      'email': 'ama@example.com',
      'provider': 'email',
      'date_account_created': '2026-01-01',
      'lastSignInAt': '2026-11-18',
    };

    test('round-trips country and currency', () {
      final profile = UserProfileModel.fromMap({
        ...base,
        'country': 'GH',
        'currency': 'GHS',
      });
      expect(profile.hasLocale, isTrue);
      expect(profile.toMap()['country'], 'GH');
      expect(profile.toMap()['currency'], 'GHS');
    });

    test('treats missing or blank fields as not set', () {
      expect(UserProfileModel.fromMap(base).hasLocale, isFalse);
      expect(
        UserProfileModel.fromMap({
          ...base,
          'country': ' ',
          'currency': 'GHS',
        }).hasLocale,
        isFalse,
      );
    });
  });

  group('countries', () {
    test('codes are unique ISO-shaped values', () {
      final codes = countries.map((c) => c.code).toSet();
      expect(codes.length, countries.length);
      for (final c in countries) {
        expect(c.code, matches(RegExp(r'^[A-Z]{2}$')), reason: c.name);
        expect(c.currencyCode, matches(RegExp(r'^[A-Z]{3}$')), reason: c.name);
      }
    });

    test('looks up countries case-insensitively', () {
      expect(countryByCode('gh')?.currencyCode, 'GHS');
      expect(countryByCode('NG')?.name, 'Nigeria');
      expect(countryByCode(null), isNull);
      expect(countryByCode('XX'), isNull);
    });

    test('currency list has no duplicates', () {
      expect(countryCurrencyCodes.toSet().length, countryCurrencyCodes.length);
      expect(countryCurrencyCodes, contains('GHS'));
    });
  });
}
