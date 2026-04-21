import 'package:expenser/data/repositories/account_repository.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/data/repositories/settings_repository.dart';
import 'package:expenser/models/account_model.dart';
import 'package:expenser/models/account_type.dart';
import 'package:expenser/models/app_settings_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class SettingsNotifier extends Notifier<AppSettingsModel> {
  @override
  AppSettingsModel build() {
    return ref.read(settingsRepositoryProvider).get();
  }

  Future<void> _save() =>
      ref.read(settingsRepositoryProvider).save(state);

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    _save();
  }

  void setCurrency(String code) {
    state = state.copyWith(preferredCurrency: code);
    _save();
  }

  void toggleNotifications() {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
    _save();
  }

  void toggleBiometric() {
    state = state.copyWith(biometricEnabled: !state.biometricEnabled);
    _save();
  }

  void setUserName(String name) {
    state = state.copyWith(userName: name);
    _save();
  }

  Future<void> markOnboardingComplete() async {
    state = state.copyWith(isFirstLaunch: false);
    await _save();
  }

  Future<void> setLoggedIn(bool value, {String? userName}) async {
    state = state.copyWith(
      isLoggedIn: value,
      userName: userName ?? state.userName,
    );
    await _save();

    if (value) {
      await _seedFirstTimeData();
    }
  }

  Future<void> _seedFirstTimeData() async {
    final categoryRepo = ref.read(categoryRepositoryProvider);
    if (categoryRepo.isEmpty) {
      await categoryRepo.seedDefaults();
    }
    final accountRepo = ref.read(accountRepositoryProvider);
    if (accountRepo.getAll().isEmpty) {
      await accountRepo.add(AccountModel(
        id: const Uuid().v4(),
        name: 'Cash',
        type: AccountType.cash,
        initialBalance: 0.0,
        currencyCode: state.preferredCurrency,
        colorHex: 'FF4CAF50',
        iconCodePoint: Icons.wallet_rounded.codePoint,
        createdAt: DateTime.now(),
      ));
    }
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettingsModel>(SettingsNotifier.new);
