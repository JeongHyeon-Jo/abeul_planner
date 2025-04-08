// calendar_task_model.dart
import 'package:hive/hive.dart';

part 'calendar_task_model.g.dart'; // build_runner로 생성될 어댑터 파일

/// 날짜별 메모를 위한 모델 클래스
@HiveType(typeId: 1) // typeId는 고유값이어야 하며 다른 모델과 중복되면 안 됨
class CalendarTaskModel {
  @HiveField(0) // 메모 내용
  final String memo;

  @HiveField(1) // 선택한 시간 (HH:mm 형식의 문자열)
  final String time;

  @HiveField(2) // 저장된 날짜 (yyyy-MM-dd 형식의 문자열)
  final DateTime date;

  CalendarTaskModel({
    required this.memo,
    required this.time,
    required this.date,
  });
}
