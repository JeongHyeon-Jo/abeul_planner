// calendar_schedule_model.dart
import 'package:hive/hive.dart';

part 'calendar_schedule_model.g.dart';

/// 캘린더 일정 모델 (시간 + 내용)
@HiveType(typeId: 1)
class CalendarScheduleModel {
  @HiveField(0)
  final DateTime date; // 일정 날짜

  @HiveField(1)
  final String time; // 시간 (예: "07:30")

  @HiveField(2)
  final String content; // 일정 내용

  CalendarScheduleModel({
    required this.date,
    required this.time,
    required this.content,
  });
}
