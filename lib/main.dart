// main.dart
import 'package:flutter/material.dart';
// package
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
// core
import 'package:abeul_planner/core/screen_util.dart';
import 'package:abeul_planner/core/theme.dart';
// routes
import 'package:abeul_planner/routes/planner_router.dart';
// features
import 'features/daily_planner/data/datasource/daily_task_box.dart';
import 'features/calendar_planner/data/datasource/calendar_task_box.dart';
import 'features/weekly_planner/data/datasource/weekly_task_box.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 날짜 포맷 초기화
  await initializeDateFormatting('ko_KR', null);

  // Hive 초기화
  await Hive.initFlutter();

  // DailyTask 어댑터 등록 및 박스 열기
  await DailyTaskBox.registerAdapters();
  await DailyTaskBox.openBox();

  // CalendarTask 어댑터 등록 및 박스 열기
  await CalendarTaskBox.registerAdapters();
  await CalendarTaskBox.openBox();

  // WeeklyTask 어댑터 등록 및 박스 열기
  await WeeklyTaskBox.registerAdapters();
  await WeeklyTaskBox.openBox();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveInitializer(
      child: MaterialApp.router(
        routerConfig: router,
        title: 'Abeul Planner',
        debugShowCheckedModeBanner: false,
        theme: appLightTheme,
      ),
    );
  }
}
