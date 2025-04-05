import 'package:hive/hive.dart';

part 'daily_task_model.g.dart'; // Hive가 자동 생성하는 어댑터 파일 (build_runner로 생성됨)

/// 일일 할 일(Task)을 나타내는 모델 클래스
/// Hive에서 로컬 저장소에 저장하기 위해 어노테이션 사용
@HiveType(typeId: 0) // typeId는 고유값이어야 하며, 다른 모델과 중복되지 않아야 함
class DailyTaskModel {
  @HiveField(0) // 첫 번째 필드: 할 일 제목
  final String title;

  @HiveField(1) // 두 번째 필드: 완료 여부
  final bool isCompleted;

  DailyTaskModel({
    required this.title,
    required this.isCompleted,
  });
}
