// weekly_task_model.dart
import 'package:hive/hive.dart';

part 'weekly_task_model.g.dart';

@HiveType(typeId: 2)
class WeeklyTaskModel extends HiveObject {
  @HiveField(0)
  final String day; // 요일

  @HiveField(1)
  String theme; // 오늘의 테마 ("집중의 날" 등)

  @HiveField(2)
  List<String> tasks; // 할 일 리스트

  WeeklyTaskModel({
    required this.day,
    required this.theme,
    required this.tasks,
  });
}
