// weekly_record_group.dart
import 'package:hive/hive.dart';
import 'package:abeul_planner/features/weekly_planner/data/model/weekly_task_model.dart';

part 'weekly_record_group.g.dart';

@HiveType(typeId: 22)
class WeeklyRecordGroup {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final String day;

  @HiveField(2)
  final List<WeeklyTask> tasks;

  WeeklyRecordGroup({
    required this.date,
    required this.day,
    required this.tasks,
  });
}
