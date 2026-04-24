import 'package:hive_flutter/hive_flutter.dart';

part 'app_settings_model.g.dart';

@HiveType(typeId: 6)
class AppSettingsModel extends HiveObject {
  @HiveField(0)
  bool isDarkMode;

  @HiveField(1)
  String preferredCurrency;

  @HiveField(2)
  bool notificationsEnabled;

  @HiveField(3)
  bool biometricEnabled;

  @HiveField(4)
  String userName;

  @HiveField(5)
  String? userAvatarPath;

  @HiveField(6)
  bool isFirstLaunch;

  @HiveField(7)
  bool isLoggedIn;

  @HiveField(8)
  String? uid;

  AppSettingsModel({
    this.isDarkMode = false,
    this.preferredCurrency = 'GHS',
    this.notificationsEnabled = true,
    this.biometricEnabled = false,
    this.userName = '',
    this.userAvatarPath,
    this.isFirstLaunch = true,
    this.isLoggedIn = false,
    this.uid,
  });

  factory AppSettingsModel.defaults() => AppSettingsModel();

  AppSettingsModel copyWith({
    bool? isDarkMode,
    String? preferredCurrency,
    bool? notificationsEnabled,
    bool? biometricEnabled,
    String? userName,
    String? userAvatarPath,
    bool? isFirstLaunch,
    bool? isLoggedIn,
    String? uid,
  }) {
    return AppSettingsModel(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      userName: userName ?? this.userName,
      userAvatarPath: userAvatarPath ?? this.userAvatarPath,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      uid: uid ?? this.uid,
    );
  }
}
