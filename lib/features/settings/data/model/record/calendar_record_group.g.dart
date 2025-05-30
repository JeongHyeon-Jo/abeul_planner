// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_record_group.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CalendarRecordGroupAdapter extends TypeAdapter<CalendarRecordGroup> {
  @override
  final int typeId = 21;

  @override
  CalendarRecordGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CalendarRecordGroup(
      date: fields[0] as DateTime,
      tasks: (fields[1] as List).cast<CalendarTaskModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, CalendarRecordGroup obj) {
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
      other is CalendarRecordGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
