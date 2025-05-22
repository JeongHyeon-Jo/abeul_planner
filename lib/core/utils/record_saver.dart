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

  static Future<void> _saveDaily(WidgetRef ref) async {
    final tasks = ref.read(dailyTaskProvider);
    if (tasks.isNotEmpty) {
      final record = DailyRecordGroup(date: DateTime.now(), tasks: List.from(tasks));
      await DailyRecordBox.box.add(record);
    }
  }

  static Future<void> _saveWeekly(WidgetRef ref) async {
    final weeklyMap = ref.read(weeklyTaskProvider);
    final now = DateTime.now();

    for (final model in weeklyMap) {
      if (model.tasks.isNotEmpty) {
        final record = WeeklyRecordGroup(
          date: now,
          day: model.day,
          tasks: List.from(model.tasks),
        );
        await WeeklyRecordBox.box.add(record);
      }
    }
  }

  static Future<void> _saveCalendar(WidgetRef ref) async {
    final tasks = ref.read(calendarTaskProvider);
    if (tasks.isNotEmpty) {
      final record = CalendarRecordGroup(date: DateTime.now(), tasks: List.from(tasks));
      await CalendarRecordBox.box.add(record);
    }
  }
}