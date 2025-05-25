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
  /// 하루에 한 번, 어제 날짜 기준으로 자동 기록 저장
  static Future<void> saveAllIfNeeded(ProviderContainer container) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final last = prefs.getString('last_record_date');

    if (last != today) {
      await _saveDaily(container);
      await _saveWeekly(container);
      await _saveCalendar(container);
      await prefs.setString('last_record_date', today);
    }
  }

  /// 어제 날짜를 구하는 헬퍼 함수
  static DateTime get _yesterday {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
  }

  // 일상 플래너 기록 저장 (어제 기준)
  static Future<void> _saveDaily(ProviderContainer container) async {
    final tasks = container.read(dailyTaskProvider);
    if (tasks.isNotEmpty) {
      final date = _yesterday;
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

  // 주간 플래너 기록 저장 (어제 기준 요일만 저장)
  static Future<void> _saveWeekly(ProviderContainer container) async {
    final weeklyMap = container.read(weeklyTaskProvider);
    final date = _yesterday;
    final weekday = DateFormat('E', 'ko_KR').format(date); // 예: '월', '화', ...

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

  // 달력 플래너 기록 저장 (어제 날짜에 해당하는 task만 저장)
  static Future<void> _saveCalendar(ProviderContainer container) async {
    final tasks = container.read(calendarTaskProvider);
    if (tasks.isEmpty) return;

    final yesterday = _yesterday;
    final key = DateFormat('yyyy-MM-dd').format(yesterday);
    final filtered = tasks.where((task) =>
        DateFormat('yyyy-MM-dd').format(task.date) == key).toList();

    if (filtered.isEmpty) return;

    final exists = CalendarRecordBox.box.values.any((record) =>
        DateFormat('yyyy-MM-dd').format(record.date) == key);
    if (!exists) {
      final record = CalendarRecordGroup(date: yesterday, tasks: filtered);
      await CalendarRecordBox.box.add(record);
    }
  }
}
