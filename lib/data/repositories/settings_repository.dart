import 'package:expenser/data/datasources/hive_service.dart';
import 'package:expenser/models/app_settings_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsRepository {
  static const String _key = 'prefs';

  Box<AppSettingsModel> get _box =>
      HiveService.box<AppSettingsModel>(HiveService.settings);

  AppSettingsModel get() => _box.get(_key) ?? AppSettingsModel.defaults();

  Future<void> save(AppSettingsModel s) => _box.put(_key, s);
}

final settingsRepositoryProvider =
    Provider<SettingsRepository>((ref) => SettingsRepository());
