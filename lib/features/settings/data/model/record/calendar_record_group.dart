// calendar_record_group.dart
import 'package:hive/hive.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/calendar_task_model.dart';

part 'calendar_record_group.g.dart';

@HiveType(typeId: 21)
class CalendarRecordGroup {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final List<CalendarTaskModel> tasks;

  CalendarRecordGroup({
    required this.date,
    required this.tasks,
  });
}
