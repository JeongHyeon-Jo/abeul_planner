// weekly_task_model.dart
import 'package:hive/hive.dart';

part 'weekly_task_model.g.dart';

@HiveType(typeId: 3)
class WeeklyTask {
  @HiveField(0)
  final String content; // 할 일 내용

  @HiveField(1)
  final String priority; // 중요도

  @HiveField(2)
  bool isCompleted; // 수행 여부

  @HiveField(3)
  DateTime? lastCheckedWeek;  // 마지막 체크 주

  WeeklyTask({
    required this.content,
    this.priority = '보통',
    this.isCompleted = false,
    this.lastCheckedWeek,
  });

  // copyWith
  WeeklyTask copyWith({
    String? content,
    String? priority,
    bool? isCompleted,
    DateTime? lastCheckedWeek,
  }) {
    return WeeklyTask(
      content: content ?? this.content,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      lastCheckedWeek: lastCheckedWeek ?? this.lastCheckedWeek,
    );
  }
}

@HiveType(typeId: 2)
class WeeklyTaskModel extends HiveObject {
  @HiveField(0)
  final String day; // 요일

  @HiveField(1)
  List<WeeklyTask> tasks; // 할 일 리스트

  WeeklyTaskModel({
    required this.day,
    required this.tasks,
  });
}