// test/record_saver_test.dart
import 'package:abeul_planner/features/calendar_planner/data/datasource/calendar_task_box.dart';
import 'package:abeul_planner/features/daily_planner/data/datasource/daily_task_box.dart';
import 'package:abeul_planner/features/settings/data/datasource/record/calendar_record_box.dart';
import 'package:abeul_planner/features/settings/data/datasource/record/weekly_record_box.dart';
import 'package:abeul_planner/features/weekly_planner/data/datasource/weekly_task_box.dart';
import 'package:abeul_planner/features/settings/data/datasource/record/daily_record_box.dart';
import 'package:abeul_planner/features/daily_planner/data/model/daily_task_model.dart';
import 'package:abeul_planner/features/daily_planner/presentation/provider/daily_task_provider.dart';
import 'package:abeul_planner/core/utils/record_saver.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_test/hive_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUpAll(() async {
    await initializeDateFormatting('ko_KR', null);
  });

  group('RecordSaver', () {
    setUp(() async {
      await setUpTestHive();
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();

      // Hive 박스 준비
      await DailyTaskBox.registerAdapters();
      await DailyTaskBox.openBox();

      await WeeklyTaskBox.registerAdapters();
      await WeeklyTaskBox.openBox();

      await CalendarTaskBox.registerAdapters();
      await CalendarTaskBox.openBox();         


      await DailyRecordBox.registerAdapters();
      await DailyRecordBox.openBox();

      await WeeklyRecordBox.registerAdapters();
      await WeeklyRecordBox.openBox();

      await CalendarRecordBox.registerAdapters();
      await CalendarRecordBox.openBox();

      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_record_date', DateFormat('yyyy-MM-dd').format(yesterday));
      container.read(dailyTaskProvider.notifier).state = [
        DailyTaskModel(
          situation: '시험 공부',
          action: '단어 외우기',
          isCompleted: true,
          priority: '보통',
          lastCheckedDate: yesterday,
        )
      ];
    });

    test('어제 기록이 저장되어야 한다', () async {
      await RecordSaver.saveAllIfNeeded(container);

      final records = DailyRecordBox.box.values.toList();
      expect(records.length, greaterThan(0));

      final record = records.first;
      final expectedDate = DateTime.now().subtract(const Duration(days: 1));
      final recordDate = DateTime(record.date.year, record.date.month, record.date.day);

      expect(recordDate, equals(DateTime(expectedDate.year, expectedDate.month, expectedDate.day)));
      expect(record.tasks.first.isCompleted, true);
      expect(record.tasks.first.situation, '시험 공부');
    });
  });
}
