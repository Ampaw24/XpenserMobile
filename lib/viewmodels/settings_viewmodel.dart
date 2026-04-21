import 'package:expenser/data/repositories/interfaces/i_settings_repository.dart';
import 'package:expenser/data/repositories/settings_repository.dart';
import 'package:expenser/models/app_settings_model.dart';
import 'package:expenser/services/data_bootstrap_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsNotifier extends Notifier<AppSettingsModel> {
  late ISettingsRepository _repo;

  @override
  AppSettingsModel build() {
    _repo = ref.read(settingsRepositoryProvider);
    return _repo.get();
  }

  Future<void> _save() => _repo.save(state);

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
      await ref
          .read(dataBootstrapServiceProvider)
          .seedIfNeeded(state.preferredCurrency);
    }
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettingsModel>(SettingsNotifier.new);
