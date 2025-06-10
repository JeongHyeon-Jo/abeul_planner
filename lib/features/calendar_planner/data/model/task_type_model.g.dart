// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_type_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskTypeModelAdapter extends TypeAdapter<TaskTypeModel> {
  @override
  final int typeId = 12;

  @override
  TaskTypeModel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskTypeModel.single;
      case 1:
        return TaskTypeModel.period;
      case 2:
        return TaskTypeModel.allDay;
      default:
        return TaskTypeModel.single;
    }
  }

  @override
  void write(BinaryWriter writer, TaskTypeModel obj) {
    switch (obj) {
      case TaskTypeModel.single:
        writer.writeByte(0);
        break;
      case TaskTypeModel.period:
        writer.writeByte(1);
        break;
      case TaskTypeModel.allDay:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskTypeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
