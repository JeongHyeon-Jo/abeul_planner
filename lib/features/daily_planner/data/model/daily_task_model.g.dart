// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyTaskModelAdapter extends TypeAdapter<DailyTaskModel> {
  @override
  final int typeId = 0;

  @override
  DailyTaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyTaskModel(
      situation: fields[0] as String,
      action: fields[1] as String,
      isCompleted: fields[2] as bool,
      priority: fields[3] as String,
      lastCheckedDate: fields[4] as DateTime?,
      goalCount: fields[5] as int?,
      completedCount: fields[6] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyTaskModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.situation)
      ..writeByte(1)
      ..write(obj.action)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.priority)
      ..writeByte(4)
      ..write(obj.lastCheckedDate)
      ..writeByte(5)
      ..write(obj.goalCount)
      ..writeByte(6)
      ..write(obj.completedCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyTaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
