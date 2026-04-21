import 'package:expenser/data/datasources/hive_service.dart';
import 'package:expenser/data/repositories/interfaces/i_settings_repository.dart';
import 'package:expenser/models/app_settings_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsRepository implements ISettingsRepository {
  static const String _key = 'prefs';

  Box<AppSettingsModel> get _box =>
      HiveService.box<AppSettingsModel>(HiveService.settings);

  @override
  AppSettingsModel get() => _box.get(_key) ?? AppSettingsModel.defaults();

  @override
  Future<void> save(AppSettingsModel settings) => _box.put(_key, settings);
}

final settingsRepositoryProvider =
    Provider<ISettingsRepository>((ref) => SettingsRepository());
