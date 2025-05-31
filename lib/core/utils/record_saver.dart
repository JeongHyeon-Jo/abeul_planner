// core/utils/record_saver.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
// provider
import 'package:abeul_planner/features/daily_planner/presentation/provider/daily_task_provider.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/provider/weekly_task_provider.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/provider/calendar_task_provider.dart';
// task & record
import 'package:abeul_planner/features/daily_planner/data/model/daily_task_model.dart';
import 'package:abeul_planner/features/settings/data/datasource/record/daily_record_box.dart';
import 'package:abeul_planner/features/settings/data/datasource/record/weekly_record_box.dart';
import 'package:abeul_planner/features/settings/data/datasource/record/calendar_record_box.dart';
import 'package:abeul_planner/features/settings/data/model/record/daily_record_group.dart';
import 'package:abeul_planner/features/settings/data/model/record/weekly_record_group.dart';
import 'package:abeul_planner/features/settings/data/model/record/calendar_record_group.dart';

class RecordSaver {
  static Future<void> saveAllIfNeeded(ProviderContainer container) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final yesterday = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 1));

    final lastSavedDateStr = prefs.getString('last_record_date');
    final lastSavedDate = lastSavedDateStr == null
        ? yesterday.subtract(const Duration(days: 1))
        : DateFormat('yyyy-MM-dd').parse(lastSavedDateStr);

    DateTime current = lastSavedDate.add(const Duration(days: 1));

    while (!current.isAfter(yesterday)) {
      final isYesterday = current.year == yesterday.year &&
                          current.month == yesterday.month &&
                          current.day == yesterday.day;

      await _saveDaily(container, current, markIncomplete: !isYesterday);
      await _saveWeekly(container, current);
      await _saveCalendar(container, current);

      current = current.add(const Duration(days: 1));
    }

    await prefs.setString('last_record_date', DateFormat('yyyy-MM-dd').format(yesterday));
  }

  // 일상 플래너 기록 저장
  static Future<void> _saveDaily(ProviderContainer container, DateTime date, {bool markIncomplete = false}) async {
    final tasks = container.read(dailyTaskProvider);
    
    // 로깅 추가
    print('[SAVE DAILY] Target date: $date, tasks count: ${tasks.length}');
    if (tasks.isEmpty) {
      print('[SAVE DAILY] Skipped: No tasks');
      return;
    }

    final key = DateFormat('yyyy-MM-dd').format(date);
    final exists = DailyRecordBox.box.values.any(
      (record) => DateFormat('yyyy-MM-dd').format(record.date) == key,
    );

    if (exists) {
      print('[SAVE DAILY] Skipped: Already exists for $key');
      return;
    }

    final savedTasks = tasks.map((t) => DailyTaskModel(
      situation: t.situation,
      action: t.action,
      isCompleted: markIncomplete ? false : t.isCompleted,
      priority: t.priority,
      lastCheckedDate: t.lastCheckedDate,
    )).toList();

    final record = DailyRecordGroup(date: date, tasks: savedTasks);
    await DailyRecordBox.box.add(record);
    print('[SAVE DAILY] Saved for $key');
  }

  // 주간 플래너 기록 저장
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

  // 달력 플래너 기록 저장
  static Future<void> _saveCalendar(ProviderContainer container, DateTime date) async {
    final tasks = container.read(calendarTaskProvider);
    if (tasks.isEmpty) return;

    final key = DateFormat('yyyy-MM-dd').format(date);
    final filtered = tasks.where((task) => DateFormat('yyyy-MM-dd').format(task.date) == key).toList();

    if (filtered.isEmpty) return;

    final exists = CalendarRecordBox.box.values.any((record) => DateFormat('yyyy-MM-dd').format(record.date) == key);
    if (!exists) {
      final record = CalendarRecordGroup(date: date, tasks: filtered);
      await CalendarRecordBox.box.add(record);
    }
  }
}
