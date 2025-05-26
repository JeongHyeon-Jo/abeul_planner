// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_record_group.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeeklyRecordGroupAdapter extends TypeAdapter<WeeklyRecordGroup> {
  @override
  final int typeId = 22;

  @override
  WeeklyRecordGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeeklyRecordGroup(
      date: fields[0] as DateTime,
      day: fields[1] as String,
      tasks: (fields[2] as List).cast<WeeklyTask>(),
    );
  }

  @override
  void write(BinaryWriter writer, WeeklyRecordGroup obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.day)
      ..writeByte(2)
      ..write(obj.tasks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyRecordGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
