// daily_task_model.dart
import 'package:hive/hive.dart';

part 'daily_task_model.g.dart';

/// 일일 일정(Task)을 나타내는 모델 클래스
/// Hive에서 로컬 저장소에 저장하기 위해 어노테이션 사용
@HiveType(typeId: 0)
class DailyTaskModel {
  @HiveField(0) // 상황
  final String situation;

  @HiveField(1) // 행동
  final String action;

  @HiveField(2) // 수행 여부
  final bool isCompleted;

  @HiveField(3) // 중요도
  final String priority;

  @HiveField(4) // 마지막으로 완료 체크한 날짜
  final DateTime? lastCheckedDate;

  @HiveField(5) // 목표 횟수 (null이면 항상)
  final int? goalCount;

  @HiveField(6) // 지금까지 완료한 횟수
  final int? completedCount;


  DailyTaskModel({
    required this.situation,
    required this.action,
    this.isCompleted = false,
    this.priority = '보통',
    this.lastCheckedDate,
    this.goalCount,
    this.completedCount = 0,
  });
}
