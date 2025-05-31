// calendar_task_model.dart
import 'package:hive/hive.dart';

part 'calendar_task_model.g.dart'; // build_runner로 생성될 어댑터 파일

/// 날짜별 메모를 위한 모델 클래스 (리팩토링 버전)
@HiveType(typeId: 1)
class CalendarTaskModel {
  @HiveField(0) 
  final String memo; // 메모 내용

  @HiveField(1) 
  final DateTime date; // 저장된 날짜 (yyyy-MM-dd)

  @HiveField(2)
  final String repeat; // 반복 설정 (없음, 매주, 매월, 매년)

  @HiveField(3)
  bool isCompleted; // 완료 여부

  @HiveField(4)
  final String priority; // 중요도

  @HiveField(5)
  final String? repeatId;

  CalendarTaskModel({
    required this.memo,
    required this.date,
    required this.repeat,
    this.isCompleted = false,
    this.priority = '보통',
    this.repeatId,
  });
}
