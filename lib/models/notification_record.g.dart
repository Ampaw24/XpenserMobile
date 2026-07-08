// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationRecordAdapter extends TypeAdapter<NotificationRecord> {
  @override
  final int typeId = 7;

  @override
  NotificationRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationRecord(
      id: fields[0] as String,
      title: fields[1] as String,
      body: fields[2] as String,
      type: fields[3] as String,
      route: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      isRead: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationRecord obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.body)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.route)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.isRead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
