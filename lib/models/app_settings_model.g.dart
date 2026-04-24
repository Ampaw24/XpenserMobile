// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsModelAdapter extends TypeAdapter<AppSettingsModel> {
  @override
  final int typeId = 6;

  @override
  AppSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettingsModel(
      isDarkMode: fields[0] as bool,
      preferredCurrency: fields[1] as String,
      notificationsEnabled: fields[2] as bool,
      biometricEnabled: fields[3] as bool,
      userName: fields[4] as String,
      userAvatarPath: fields[5] as String?,
      isFirstLaunch: fields[6] as bool,
      isLoggedIn: fields[7] as bool,
      uid: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettingsModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.isDarkMode)
      ..writeByte(1)
      ..write(obj.preferredCurrency)
      ..writeByte(2)
      ..write(obj.notificationsEnabled)
      ..writeByte(3)
      ..write(obj.biometricEnabled)
      ..writeByte(4)
      ..write(obj.userName)
      ..writeByte(5)
      ..write(obj.userAvatarPath)
      ..writeByte(6)
      ..write(obj.isFirstLaunch)
      ..writeByte(7)
      ..write(obj.isLoggedIn)
      ..writeByte(8)
      ..write(obj.uid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
