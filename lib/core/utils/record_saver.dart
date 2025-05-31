// core/utils/record_saver.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
// provider
import 'package:abeul_planner/features/weekly_planner/presentation/provider/weekly_task_provider.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/provider/calendar_task_provider.dart';
// record
import 'package:abeul_planner/features/settings/data/datasource/record/weekly_record_box.dart';
import 'package:abeul_planner/features/settings/data/datasource/record/calendar_record_box.dart';
import 'package:abeul_planner/features/settings/data/model/record/weekly_record_group.dart';
import 'package:abeul_planner/features/settings/data/model/record/calendar_record_group.dart';

class RecordSaver {
  static Future<void> saveAllIfNeeded(ProviderContainer container) async {
    final today = DateTime.now();
    final yesterday = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 1));

    for (DateTime current = yesterday;
        !current.isAfter(yesterday);
        current = current.add(const Duration(days: 1))) {
      await _saveWeekly(container, current);
      await _saveCalendar(container, current);
    }
  }

  static Future<void> _saveWeekly(ProviderContainer container, DateTime date) async {
    final weeklyMap = container.read(weeklyTaskProvider);
    final weekday = DateFormat('E', 'ko_KR').format(date);

    for (final model in weeklyMap) {
      if (model.day == weekday && model.tasks.isNotEmpty) {
        final exists = WeeklyRecordBox.box.values.any((record) =>
            DateFormat('yyyy-MM-dd').format(record.date) == DateFormat('yyyy-MM-dd').format(date) &&
            record.day == model.day);
        if (!exists) {
          final record = WeeklyRecordGroup(
            date: date,
            day: model.day,
            tasks: List.from(model.tasks),
          );
          await WeeklyRecordBox.box.add(record);
        }
      }
    }
  }

  static Future<void> _saveCalendar(ProviderContainer container, DateTime date) async {
    final tasks = container.read(calendarTaskProvider);
    if (tasks.isEmpty) return;

    final key = DateFormat('yyyy-MM-dd').format(date);
    final filtered = tasks.where((task) => DateFormat('yyyy-MM-dd').format(task.date) == key).toList();

    if (filtered.isEmpty) return;

    final exists = CalendarRecordBox.box.values.any(
      (record) => DateFormat('yyyy-MM-dd').format(record.date) == key,
    );
    if (!exists) {
      final record = CalendarRecordGroup(date: date, tasks: filtered);
      await CalendarRecordBox.box.add(record);
    }
  }
}
