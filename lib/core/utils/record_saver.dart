// core/utils/record_saver.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
// 프로바이더
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

    // 기준 날짜: 마지막 완료 체크 날짜 중 가장 최신 값
    final tasks = container.read(dailyTaskProvider);
    final checkedDates = tasks
        .where((t) => t.lastCheckedDate != null)
        .map((t) => DateTime(t.lastCheckedDate!.year, t.lastCheckedDate!.month, t.lastCheckedDate!.day))
        .toList();

    final lastCheckedDate = checkedDates.isEmpty
        ? yesterday.subtract(const Duration(days: 1))
        : checkedDates.reduce((a, b) => a.isAfter(b) ? a : b);

    DateTime current = lastCheckedDate;

    while (!current.isAfter(yesterday)) {
      final useRealData = current == lastCheckedDate;

      await _saveDaily(container, current, useRealData: useRealData);
      await _saveWeekly(container, current);
      await _saveCalendar(container, current);

      current = current.add(const Duration(days: 1));
    }

    await prefs.setString('last_record_date', DateFormat('yyyy-MM-dd').format(yesterday));
  }

  /// 일상 플래너 기록 저장
  static Future<void> _saveDaily(ProviderContainer container, DateTime date, {required bool useRealData}) async {
    final tasks = container.read(dailyTaskProvider);
    if (tasks.isEmpty) return;

    final key = DateFormat('yyyy-MM-dd').format(date);
    final exists = DailyRecordBox.box.values.any(
      (record) => DateFormat('yyyy-MM-dd').format(record.date) == key,
    );
    if (exists) return;

    final savedTasks = useRealData
        ? List<DailyTaskModel>.from(tasks)
        : tasks.map((t) => DailyTaskModel(
              situation: t.situation,
              action: t.action,
              isCompleted: false,
              priority: t.priority,
              lastCheckedDate: null,
            )).toList();

    final record = DailyRecordGroup(date: date, tasks: savedTasks);
    await DailyRecordBox.box.add(record);
  }

  /// 주간 플래너 기록 저장
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

  /// 달력 플래너 기록 저장
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
