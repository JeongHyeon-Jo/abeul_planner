// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeeklyTaskAdapter extends TypeAdapter<WeeklyTask> {
  @override
  final int typeId = 3;

  @override
  WeeklyTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeeklyTask(
      content: fields[0] as String,
      priority: fields[1] as String,
      isCompleted: fields[2] as bool,
      lastCheckedWeek: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, WeeklyTask obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.content)
      ..writeByte(1)
      ..write(obj.priority)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.lastCheckedWeek);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WeeklyTaskModelAdapter extends TypeAdapter<WeeklyTaskModel> {
  @override
  final int typeId = 2;

  @override
  WeeklyTaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeeklyTaskModel(
      day: fields[0] as String,
      tasks: (fields[1] as List).cast<WeeklyTask>(),
    );
  }

  @override
  void write(BinaryWriter writer, WeeklyTaskModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.day)
      ..writeByte(1)
      ..write(obj.tasks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyTaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
