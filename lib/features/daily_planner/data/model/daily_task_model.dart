import 'package:hive/hive.dart';

part 'daily_task_model.g.dart'; // Hive가 자동 생성하는 어댑터 파일 (build_runner로 생성됨)

/// 일일 할 일(Task)을 나타내는 모델 클래스
/// Hive에서 로컬 저장소에 저장하기 위해 어노테이션 사용
@HiveType(typeId: 0)
class DailyTaskModel {
  @HiveField(0)
  final String situation;

  @HiveField(1)
  final String action;

  @HiveField(2)
  final bool isCompleted;

  DailyTaskModel({
    required this.situation,
    required this.action,
    this.isCompleted = false,
  });
}

