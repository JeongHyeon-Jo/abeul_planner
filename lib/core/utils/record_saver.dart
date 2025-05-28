// core/utils/record_saver.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
// 플래너 프로바이더
import 'package:abeul_planner/features/daily_planner/presentation/provider/daily_task_provider.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/provider/weekly_task_provider.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/provider/calendar_task_provider.dart';
// record 박스
import 'package:abeul_planner/features/settings/data/datasource/record/daily_record_box.dart';
import 'package:abeul_planner/features/settings/data/datasource/record/weekly_record_box.dart';
import 'package:abeul_planner/features/settings/data/datasource/record/calendar_record_box.dart';
// record 그룹
import 'package:abeul_planner/features/settings/data/model/record/daily_record_group.dart';
import 'package:abeul_planner/features/settings/data/model/record/weekly_record_group.dart';
import 'package:abeul_planner/features/settings/data/model/record/calendar_record_group.dart';

class RecordSaver {
  /// 여러 날짜에 대해 누락된 기록을 모두 저장
  static Future<void> saveAllIfNeeded(ProviderContainer container) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final lastSavedString = prefs.getString('last_record_date');
    DateTime lastSavedDate;

    if (lastSavedString == null) {
      // 저장된 기록이 없으면 어제부터 저장
      lastSavedDate = today.subtract(const Duration(days: 1));
    } else {
      lastSavedDate = DateFormat('yyyy-MM-dd').parse(lastSavedString);
    }

    final yesterday = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 1));

    // 마지막 저장일 다음날부터 어제까지 반복
    DateTime current = lastSavedDate.add(const Duration(days: 1));
    while (!current.isAfter(yesterday)) {
      await _saveDaily(container, current);
      await _saveWeekly(container, current);
      await _saveCalendar(container, current);
      current = current.add(const Duration(days: 1));
    }

    // 마지막 저장일 갱신
    await prefs.setString('last_record_date', DateFormat('yyyy-MM-dd').format(yesterday));
  }

  /// 일상 플래너 기록 저장 (지정 날짜 기준)
  static Future<void> _saveDaily(ProviderContainer container, DateTime date) async {
    final tasks = container.read(dailyTaskProvider);
    if (tasks.isNotEmpty) {
      final exists = DailyRecordBox.box.values.any(
        (record) => DateFormat('yyyy-MM-dd').format(record.date) ==
                    DateFormat('yyyy-MM-dd').format(date),
      );
      if (!exists) {
        final record = DailyRecordGroup(date: date, tasks: List.from(tasks));
        await DailyRecordBox.box.add(record);
      }
    }
  }

  /// 주간 플래너 기록 저장 (지정 날짜 기준 요일만 저장)
  static Future<void> _saveWeekly(ProviderContainer container, DateTime date) async {
    final weeklyMap = container.read(weeklyTaskProvider);
    final weekday = DateFormat('E', 'ko_KR').format(date); // '월', '화' 등

    for (final model in weeklyMap) {
      if (model.day == weekday && model.tasks.isNotEmpty) {
        final exists = WeeklyRecordBox.box.values.any((record) =>
            DateFormat('yyyy-MM-dd').format(record.date) ==
                DateFormat('yyyy-MM-dd').format(date) &&
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

  /// 달력 플래너 기록 저장 (지정 날짜 기준 task만 저장)
  static Future<void> _saveCalendar(ProviderContainer container, DateTime date) async {
    final tasks = container.read(calendarTaskProvider);
    if (tasks.isEmpty) return;

    final key = DateFormat('yyyy-MM-dd').format(date);
    final filtered = tasks.where((task) =>
        DateFormat('yyyy-MM-dd').format(task.date) == key).toList();

    if (filtered.isEmpty) return;

    final exists = CalendarRecordBox.box.values.any((record) =>
        DateFormat('yyyy-MM-dd').format(record.date) == key);
    if (!exists) {
      final record = CalendarRecordGroup(date: date, tasks: filtered);
      await CalendarRecordBox.box.add(record);
    }
  }
}
