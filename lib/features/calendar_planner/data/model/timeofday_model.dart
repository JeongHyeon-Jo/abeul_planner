// lib/features/calendar_planner/data/model/timeofday_model.dart
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'timeofday_model.g.dart';

// 시간 모델 클래스
@HiveType(typeId: 11)
class TimeOfDayModel {
  @HiveField(0)
  final int hour;

  @HiveField(1)
  final int minute;

  TimeOfDayModel({
    required this.hour,
    required this.minute,
  });

  // TimeOfDay로 변환
  TimeOfDay get toTimeOfDay => TimeOfDay(hour: hour, minute: minute);

  // TimeOfDay에서 생성
  factory TimeOfDayModel.fromTimeOfDay(TimeOfDay timeOfDay) {
    return TimeOfDayModel(
      hour: timeOfDay.hour,
      minute: timeOfDay.minute,
    );
  }

  // 시간 표시 문자열
  String format(BuildContext context) {
    return toTimeOfDay.format(context);
  }

  // 24시간 형식 문자열
  String get format24Hour {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() => format24Hour;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeOfDayModel &&
          runtimeType == other.runtimeType &&
          hour == other.hour &&
          minute == other.minute;

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;
}