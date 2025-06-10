// calendar_task_model.dart
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/task_type_model.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/timeofday_model.dart';

part 'calendar_task_model.g.dart';

/// 날짜별 메모를 위한 모델 클래스
@HiveType(typeId: 1)
class CalendarTaskModel {
  @HiveField(0) 
  final String memo; // 메모 내용

  @HiveField(1) 
  final DateTime date; // 시작 날짜

  @HiveField(2)
  final String repeat; // 반복 설정 (없음, 매주, 매월, 매년)

  @HiveField(3)
  bool isCompleted; // 완료 여부

  @HiveField(4)
  final String priority; // 중요도

  @HiveField(5)
  final String? repeatId; // 반복 아이디

  @HiveField(6)
  final DateTime? endDate; // 종료일 (기간 일정의 경우 필수)

  @HiveField(7)
  final bool? secret; // 비밀

  @HiveField(8)
  final int? colorValue; // 색상

  @HiveField(9)
  final TaskTypeModel? taskType; // 일정 타입

  @HiveField(10)
  final TimeOfDayModel? startTime; // 시작 시간

  @HiveField(11)
  final TimeOfDayModel? endTime; // 종료 시간

  @HiveField(12)
  final bool? isAllDay; // 종일 여부

  CalendarTaskModel({
    required this.memo,
    required this.date,
    required this.repeat,
    this.isCompleted = false,
    this.priority = '보통',
    this.repeatId,
    this.endDate,
    this.secret,
    this.colorValue,
    this.taskType,
    this.startTime,
    this.endTime,
    this.isAllDay,
  });

  // 실제 색상으로 변환
  Color get color => colorValue != null ? Color(colorValue!) : AppColors.accent.withAlpha((0.15 * 255).toInt());

  // 기간 일정 여부 확인
  bool get isPeriodTask => (taskType ?? TaskTypeModel.single) == TaskTypeModel.period && endDate != null;

  // 종일 여부 확인
  bool get isAllDayTask => isAllDay ?? true;

  // 일정 지속 기간 (일 수)
  int get durationInDays {
    if (!isPeriodTask || endDate == null) return 1;
    return endDate!.difference(date).inDays + 1;
  }

  // 특정 날짜가 이 일정 기간에 포함되는지 확인
  bool containsDate(DateTime checkDate) {
    if (!isPeriodTask || endDate == null) {
      return date.year == checkDate.year && 
             date.month == checkDate.month && 
             date.day == checkDate.day;
    }
    
    final startDay = DateTime(date.year, date.month, date.day);
    final endDay = DateTime(endDate!.year, endDate!.month, endDate!.day);
    final checkDay = DateTime(checkDate.year, checkDate.month, checkDate.day);
    
    return (checkDay.isAfter(startDay) || checkDay.isAtSameMomentAs(startDay)) &&
           (checkDay.isBefore(endDay) || checkDay.isAtSameMomentAs(endDay));
  }

  // 시간 표시 문자열
  String get timeDisplayText {
    if (isAllDayTask) return '종일';
    if (startTime == null) return '';
    
    final start = startTime!.format24Hour;
    
    if (endTime != null) {
      final end = endTime!.format24Hour;
      return '$start - $end';
    }
    
    return start;
  }

  // 일정 기간 표시 문자열
  String get periodDisplayText {
    if (!isPeriodTask || endDate == null) {
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    }
    
    final startStr = '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    final endStr = '${endDate!.year}.${endDate!.month.toString().padLeft(2, '0')}.${endDate!.day.toString().padLeft(2, '0')}';
    
    return '$startStr ~ $endStr';
  }

  // 복사 메서드
  CalendarTaskModel copyWith({
    String? memo,
    DateTime? date,
    String? repeat,
    bool? isCompleted,
    String? priority,
    String? repeatId,
    DateTime? endDate,
    bool? secret,
    int? colorValue,
    TaskTypeModel? taskType,
    TimeOfDayModel? startTime,
    TimeOfDayModel? endTime,
    bool? isAllDay,
  }) {
    return CalendarTaskModel(
      memo: memo ?? this.memo,
      date: date ?? this.date,
      repeat: repeat ?? this.repeat,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      repeatId: repeatId ?? this.repeatId,
      endDate: endDate ?? this.endDate,
      secret: secret ?? this.secret,
      colorValue: colorValue ?? this.colorValue,
      taskType: taskType ?? this.taskType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
    );
  }
}