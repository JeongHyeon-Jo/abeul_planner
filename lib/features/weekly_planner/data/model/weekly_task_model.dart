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
  final bool isCompleted; // 수행 여부

  WeeklyTask({
    required this.content,
    this.priority = '보통',
    this.isCompleted = false,
  });
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