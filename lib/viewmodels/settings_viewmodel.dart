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

  Future<void> setLoggedIn(
    bool value, {
    String? userName,
    String? uid,
    String? photoUrl,
    bool isNewUser = false,
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

    // Persist login state + user info to Hive settings
    state = state.copyWith(
      isLoggedIn: true,
      userName: userName ?? state.userName,
      uid: uid ?? state.uid,
      userAvatarPath: photoUrl ?? state.userAvatarPath,
    );
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
    await ref
        .read(dataBootstrapServiceProvider)
        .seedIfNeeded(state.preferredCurrency);
    _bumpSyncVersion();

    // Upload the freshly seeded defaults to RTDB so they exist on next device
    if (uid != null) {
      final accounts = ref.read(accountRepositoryProvider).getAll();
      final categories = ref.read(categoryRepositoryProvider).getAll();
      firebaseService
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
    await HiveService.box<RecurringRuleModel>(HiveService.recurringRules).clear();
  }

  void _bumpSyncVersion() {
    ref.read(syncVersionProvider.notifier).update((v) => v + 1);
  }

  /// Clears all 6 Hive data boxes and repopulates them from the RTDB payload.
  Future<void> _applySync(SyncPayload payload) async {
    final txBox =
        HiveService.box<TransactionModel>(HiveService.transactions);
    final accBox =
        HiveService.box<AccountModel>(HiveService.accounts);
    final catBox =
        HiveService.box<CategoryModel>(HiveService.categories);
    final budBox =
        HiveService.box<BudgetModel>(HiveService.budgets);
    final sgBox =
        HiveService.box<SavingsGoalModel>(HiveService.savingsGoals);
    final rrBox =
        HiveService.box<RecurringRuleModel>(HiveService.recurringRules);

    await txBox.clear();
    if (payload.transactions.isNotEmpty) {
      await txBox.putAll(
          {for (final t in payload.transactions) t.id: t});
    }

    await accBox.clear();
    if (payload.accounts.isNotEmpty) {
      await accBox
          .putAll({for (final a in payload.accounts) a.id: a});
    }

    await catBox.clear();
    if (payload.categories.isNotEmpty) {
      await catBox
          .putAll({for (final c in payload.categories) c.id: c});
    }

    await budBox.clear();
    if (payload.budgets.isNotEmpty) {
      await budBox
          .putAll({for (final b in payload.budgets) b.id: b});
    }

    await sgBox.clear();
    if (payload.savingsGoals.isNotEmpty) {
      await sgBox
          .putAll({for (final g in payload.savingsGoals) g.id: g});
    }

    await rrBox.clear();
    if (payload.recurringRules.isNotEmpty) {
      await rrBox
          .putAll({for (final r in payload.recurringRules) r.id: r});
    }
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettingsModel>(SettingsNotifier.new);
