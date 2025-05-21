// daily_record_group.dart
import 'package:hive/hive.dart';
import 'package:abeul_planner/features/daily_planner/data/model/daily_task_model.dart';

part 'daily_record_group.g.dart';

@HiveType(typeId: 20)
class DailyRecordGroup {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final List<DailyTaskModel> tasks;

  DailyRecordGroup({
    required this.date,
    required this.tasks,
  });
}
