import 'package:expenser/core/utils/theme/themes.dart';
import 'package:expenser/models/account_model.dart';
import 'package:expenser/models/account_type.dart';
import 'package:expenser/models/app_settings_model.dart';
import 'package:expenser/viewmodels/account_viewmodel.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:expenser/views/profile/profile_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSettings extends SettingsNotifier {
  ({String country, String currency})? saved;

  @override
  AppSettingsModel build() =>
      AppSettingsModel(isFirstLaunch: false, isLoggedIn: true, uid: 'u1');

  @override
  Future<bool> restoreProfileLocale() async => false;

  @override
  Future<void> completeProfile({
    required String countryCode,
    required String currencyCode,
  }) async {
    saved = (country: countryCode, currency: currencyCode);
  }
}

class _FakeAccounts extends AccountNotifier {
  _FakeAccounts(this.accounts);

  final List<AccountModel> accounts;

  @override
  AccountState build() => AccountState(accounts: accounts);
}

AccountModel _cash() => AccountModel(
  id: 'a1',
  name: 'Cash',
  type: AccountType.cash,
  initialBalance: 0,
  currencyCode: 'GHS',
  colorHex: 'FF4CAF50',
  iconCodePoint: 0,
  createdAt: DateTime(2026),
);

Future<_FakeSettings> _pump(
  WidgetTester tester, {
  List<AccountModel> accounts = const [],
}) async {
  final settings = _FakeSettings();
  tester.platformDispatcher.localeTestValue = const Locale('en', 'GH');
  addTearDown(tester.platformDispatcher.clearLocaleTestValue);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsProvider.overrideWith(() => settings),
        accountProvider.overrideWith(() => _FakeAccounts(accounts)),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const ProfileSetupScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return settings;
}

void main() {
  testWidgets('suggests the device country and saves it on continue', (
    tester,
  ) async {
    final settings = await _pump(tester);

    expect(find.text('Ghana'), findsOneWidget);
    expect(find.text('GHS'), findsOneWidget);
    expect(find.textContaining('missing your country'), findsNothing);

    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(settings.saved, (country: 'GH', currency: 'GHS'));
  });

  testWidgets('warns existing users that the details are missing', (
    tester,
  ) async {
    await _pump(tester, accounts: [_cash()]);
    expect(find.textContaining('missing your country'), findsOneWidget);
  });
}
