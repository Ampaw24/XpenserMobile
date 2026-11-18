import 'package:expenser/core/providers/sync_version_provider.dart';
import 'package:expenser/data/datasources/hive_service.dart';
import 'package:expenser/data/repositories/account_repository.dart';
import 'package:expenser/data/repositories/category_repository.dart';
import 'package:expenser/data/repositories/interfaces/i_settings_repository.dart';
import 'package:expenser/data/repositories/settings_repository.dart';
import 'package:expenser/models/account_model.dart';
import 'package:expenser/models/app_settings_model.dart';
import 'package:expenser/models/budget_model.dart';
import 'package:expenser/models/category_model.dart';
import 'package:expenser/models/recurring_rule_model.dart';
import 'package:expenser/models/savings_goal_model.dart';
import 'package:expenser/models/transaction_model.dart';
import 'package:expenser/services/data_bootstrap_service.dart';
import 'package:expenser/services/firebase_user_data_service.dart';
import 'package:expenser/services/user_profile_service.dart';
import 'package:flutter/foundation.dart';
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
    _mirrorLocale(currencyCode: code);
  }

  void setCountry(String code) {
    state = state.copyWith(countryCode: code);
    _save();
    _mirrorLocale(countryCode: code);
  }

  /// Saves the country and currency asked for after sign-in. Starter data
  /// for a new user is created here, so its "Cash" account uses the
  /// chosen currency.
  Future<void> completeProfile({
    required String countryCode,
    required String currencyCode,
  }) async {
    if (ref.read(accountRepositoryProvider).getAll().isEmpty) {
      await _seedDefaults(currencyCode);
    }
    // Published last: the router leaves the setup screen on this change.
    state = state.copyWith(
      countryCode: countryCode,
      preferredCurrency: currencyCode,
    );
    await _save();
    _mirrorLocale(countryCode: countryCode, currencyCode: currencyCode);
  }

  /// For sessions restored without signing in: adopts country and currency
  /// already saved on the profile (e.g. from another device). Returns
  /// whether they were found.
  Future<bool> restoreProfileLocale() async {
    final uid = state.uid;
    if (uid == null) return false;
    final profile = await ref
        .read(userProfileServiceProvider)
        .get(uid)
        .timeout(const Duration(seconds: 10));
    if (profile == null || !profile.hasLocale) return false;
    await completeProfile(
      countryCode: profile.countryCode!,
      currencyCode: profile.currencyCode!,
    );
    return true;
  }

  /// Best effort: the local copy is the source of truth while offline.
  void _mirrorLocale({String? countryCode, String? currencyCode}) {
    final uid = state.uid;
    if (uid == null) return;
    ref
        .read(userProfileServiceProvider)
        .updateLocale(uid, countryCode: countryCode, currencyCode: currencyCode)
        .catchError((Object e) => debugPrint('Profile locale sync: $e'));
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

  Future<void> setLoggedIn(
    bool value, {
    String? userName,
    String? uid,
    String? photoUrl,
    bool isNewUser = false,
    String? countryCode,
    String? currencyCode,
  }) async {
    if (!value) {
      await _clearUserData();
      state = AppSettingsModel(
        isDarkMode: state.isDarkMode,
        preferredCurrency: state.preferredCurrency,
        notificationsEnabled: state.notificationsEnabled,
        biometricEnabled: state.biometricEnabled,
        isFirstLaunch: state.isFirstLaunch,
        isLoggedIn: false,
      );
      await _save();
      _bumpSyncVersion();
      return;
    }

    // Persist login state + user info to Hive settings. Country and currency
    // come from the profile in the same update, so users who have them never
    // see the setup screen.
    final hasLocale = countryCode != null && currencyCode != null;
    final next = state.copyWith(
      isLoggedIn: true,
      userName: userName ?? state.userName,
      uid: uid ?? state.uid,
      userAvatarPath: photoUrl ?? state.userAvatarPath,
      preferredCurrency: hasLocale ? currencyCode : null,
    );
    next.countryCode = hasLocale ? countryCode : null;
    state = next;
    await _save();

    final firebaseService = ref.read(firebaseUserDataServiceProvider);

    if (!isNewUser && uid != null) {
      // Returning user — fetch all data from RTDB and hydrate Hive
      final payload = await firebaseService.fetchAll(uid);
      if (!payload.isEmpty) {
        await _applySync(payload);
        _bumpSyncVersion();
        return;
      }
    }

    // New user (or returning user with empty RTDB) — wipe any stale local data
    // before seeding so a shared device never leaks a previous user's records.
    await _clearUserData();
    _bumpSyncVersion();
    // Without a currency yet, seeding waits for [completeProfile].
    if (state.hasLocale) await _seedDefaults(state.preferredCurrency);
  }

  Future<void> _seedDefaults(String currency) async {
    await ref.read(dataBootstrapServiceProvider).seedIfNeeded(currency);
    _bumpSyncVersion();

    // Upload the freshly seeded defaults to RTDB so they exist on next device
    final uid = state.uid;
    if (uid != null) {
      final accounts = ref.read(accountRepositoryProvider).getAll();
      final categories = ref.read(categoryRepositoryProvider).getAll();
      ref
          .read(firebaseUserDataServiceProvider)
          .seedToRTDB(uid, accounts: accounts, categories: categories)
          .catchError((e) => null);
    }
  }

  /// Clears all six user-data Hive boxes without touching app settings.
  Future<void> _clearUserData() async {
    await HiveService.box<TransactionModel>(HiveService.transactions).clear();
    await HiveService.box<AccountModel>(HiveService.accounts).clear();
    await HiveService.box<CategoryModel>(HiveService.categories).clear();
    await HiveService.box<BudgetModel>(HiveService.budgets).clear();
    await HiveService.box<SavingsGoalModel>(HiveService.savingsGoals).clear();
    await HiveService.box<RecurringRuleModel>(
      HiveService.recurringRules,
    ).clear();
  }

  void _bumpSyncVersion() {
    ref.read(syncVersionProvider.notifier).update((v) => v + 1);
  }

  /// Clears all 6 Hive data boxes and repopulates them from the RTDB payload.
  Future<void> _applySync(SyncPayload payload) async {
    final txBox = HiveService.box<TransactionModel>(HiveService.transactions);
    final accBox = HiveService.box<AccountModel>(HiveService.accounts);
    final catBox = HiveService.box<CategoryModel>(HiveService.categories);
    final budBox = HiveService.box<BudgetModel>(HiveService.budgets);
    final sgBox = HiveService.box<SavingsGoalModel>(HiveService.savingsGoals);
    final rrBox = HiveService.box<RecurringRuleModel>(
      HiveService.recurringRules,
    );

    await txBox.clear();
    if (payload.transactions.isNotEmpty) {
      await txBox.putAll({for (final t in payload.transactions) t.id: t});
    }

    await accBox.clear();
    if (payload.accounts.isNotEmpty) {
      await accBox.putAll({for (final a in payload.accounts) a.id: a});
    }

    await catBox.clear();
    if (payload.categories.isNotEmpty) {
      await catBox.putAll({for (final c in payload.categories) c.id: c});
    }

    await budBox.clear();
    if (payload.budgets.isNotEmpty) {
      await budBox.putAll({for (final b in payload.budgets) b.id: b});
    }

    await sgBox.clear();
    if (payload.savingsGoals.isNotEmpty) {
      await sgBox.putAll({for (final g in payload.savingsGoals) g.id: g});
    }

    await rrBox.clear();
    if (payload.recurringRules.isNotEmpty) {
      await rrBox.putAll({for (final r in payload.recurringRules) r.id: r});
    }
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettingsModel>(
  SettingsNotifier.new,
);
