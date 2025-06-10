// lib/features/calendar_planner/data/model/task_type_model.dart
import 'package:hive/hive.dart';

part 'task_type_model.g.dart';

/// 일정 타입 열거형
@HiveType(typeId: 12)
enum TaskTypeModel {
  @HiveField(0)
  single, // 단일 일정
  
  @HiveField(1)
  period, // 기간 일정
  
  @HiveField(2)
  allDay, // 종일 일정
}