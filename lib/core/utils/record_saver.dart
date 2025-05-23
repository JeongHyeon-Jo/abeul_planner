// core/utils/record_saver.dart
import 'package:abeul_planner/features/calendar_planner/data/model/calendar_task_model.dart';
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
  /// 날짜 기준 자동 기록 저장 (하루 1회)
  static Future<void> saveAllIfNeeded(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final last = prefs.getString('last_record_date');

    if (last != today) {
      await _saveDaily(ref);
      await _saveWeekly(ref);
      await _saveCalendar(ref);
      await prefs.setString('last_record_date', today);
    }
  }

  // 일상 플래너 기록 저장
  static Future<void> _saveDaily(WidgetRef ref) async {
    final tasks = ref.read(dailyTaskProvider);
    if (tasks.isNotEmpty) {
      final date = DateTime.now();
      final exists = DailyRecordBox.box.values.any((record) =>
          DateFormat('yyyy-MM-dd').format(record.date) ==
          DateFormat('yyyy-MM-dd').format(date));
      if (!exists) {
        final record = DailyRecordGroup(date: date, tasks: List.from(tasks));
        await DailyRecordBox.box.add(record);
      }
    }
  }

  // 주간 플래너 기록 저장
  static Future<void> _saveWeekly(WidgetRef ref) async {
    final weeklyMap = ref.read(weeklyTaskProvider);
    final now = DateTime.now();
    final todayString = DateFormat('yyyy-MM-dd').format(now);

    for (final model in weeklyMap) {
      if (model.tasks.isNotEmpty) {
        final exists = WeeklyRecordBox.box.values.any((record) =>
            DateFormat('yyyy-MM-dd').format(record.date) == todayString &&
            record.day == model.day);
        if (!exists) {
          final record = WeeklyRecordGroup(
            date: now,
            day: model.day,
            tasks: List.from(model.tasks),
          );
          await WeeklyRecordBox.box.add(record);
        }
      }
    }
  }

  // 달력 플래너 기록 저장
  static Future<void> _saveCalendar(WidgetRef ref) async {
    final tasks = ref.read(calendarTaskProvider);
    if (tasks.isEmpty) return;

    // 날짜별로 task 분류
    final Map<String, List<CalendarTaskModel>> grouped = {};
    for (final task in tasks) {
      final key = DateFormat('yyyy-MM-dd').format(task.date);
      grouped.putIfAbsent(key, () => []).add(task);
    }

    // 날짜 기준으로 각각 RecordGroup 생성 및 저장
    for (final entry in grouped.entries) {
      final date = DateFormat('yyyy-MM-dd').parse(entry.key);
      final exists = CalendarRecordBox.box.values.any((record) =>
          DateFormat('yyyy-MM-dd').format(record.date) ==
          DateFormat('yyyy-MM-dd').format(date));
      if (!exists) {
        final record = CalendarRecordGroup(date: date, tasks: List.from(entry.value));
        await CalendarRecordBox.box.add(record);
      }
    }
  }
}