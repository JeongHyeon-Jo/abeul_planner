// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_record_group.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyRecordGroupAdapter extends TypeAdapter<DailyRecordGroup> {
  @override
  final int typeId = 20;

  @override
  DailyRecordGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyRecordGroup(
      date: fields[0] as DateTime,
      tasks: (fields[1] as List).cast<DailyTaskModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, DailyRecordGroup obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.tasks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
