// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CalendarTaskModelAdapter extends TypeAdapter<CalendarTaskModel> {
  @override
  final int typeId = 1;

  @override
  CalendarTaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CalendarTaskModel(
      memo: fields[0] as String,
      date: fields[1] as DateTime,
      repeat: fields[2] as String,
      isCompleted: fields[3] as bool,
      priority: fields[4] as String,
      repeatId: fields[5] as String?,
      endDate: fields[6] as DateTime?,
      secret: fields[7] as bool?,
      colorValue: fields[8] as int?,
      taskType: fields[9] as TaskTypeModel?,
      startTime: fields[10] as TimeOfDayModel?,
      endTime: fields[11] as TimeOfDayModel?,
      isAllDay: fields[12] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, CalendarTaskModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.memo)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.repeat)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.repeatId)
      ..writeByte(6)
      ..write(obj.endDate)
      ..writeByte(7)
      ..write(obj.secret)
      ..writeByte(8)
      ..write(obj.colorValue)
      ..writeByte(9)
      ..write(obj.taskType)
      ..writeByte(10)
      ..write(obj.startTime)
      ..writeByte(11)
      ..write(obj.endTime)
      ..writeByte(12)
      ..write(obj.isAllDay);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarTaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
