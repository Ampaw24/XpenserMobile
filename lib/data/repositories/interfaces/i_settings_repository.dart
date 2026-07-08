import 'package:expenser/models/app_settings_model.dart';

abstract class ISettingsRepository {
  AppSettingsModel get();
  Future<void> save(AppSettingsModel settings);
}
