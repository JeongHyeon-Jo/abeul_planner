// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// package
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// core
import 'package:abeul_planner/core/utils/screen_util.dart';
import 'package:abeul_planner/core/styles/theme.dart';
// routes
import 'package:abeul_planner/routes/planner_router.dart';
// features
import 'features/daily_planner/data/datasource/daily_task_box.dart';
import 'features/calendar_planner/data/datasource/calendar_task_box.dart';
import 'features/weekly_planner/data/datasource/weekly_task_box.dart';
// record
import 'package:abeul_planner/core/utils/record_saver.dart';
import 'package:abeul_planner/core/utils/record_watcher.dart';
import 'package:abeul_planner/features/settings/data/datasource/record/daily_record_box.dart';
import 'package:abeul_planner/features/settings/data/datasource/record/weekly_record_box.dart';
import 'package:abeul_planner/features/settings/data/datasource/record/calendar_record_box.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 날짜 포맷 초기화
  await initializeDateFormatting('ko_KR', null);

  // Hive 초기화
  await Hive.initFlutter();

  // DailyTask
  await DailyTaskBox.registerAdapters();
  await DailyTaskBox.openBox();

  // CalendarTask
  await CalendarTaskBox.registerAdapters();
  await CalendarTaskBox.openBox();

  // WeeklyTask
  await WeeklyTaskBox.registerAdapters();
  await WeeklyTaskBox.openBox();

  // Record
  await DailyRecordBox.registerAdapters();
  await DailyRecordBox.openBox();

  await CalendarRecordBox.registerAdapters();
  await CalendarRecordBox.openBox();

  await WeeklyRecordBox.registerAdapters();
  await WeeklyRecordBox.openBox();

  final container = ProviderContainer();
  await RecordSaver.saveAllIfNeeded(container);
  RecordWatcher.start(container);

  // 앱 세로 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

// 앱 루트 위젯
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Future.microtask(() async {
    //   await RecordSaver.saveAllIfNeeded(ref);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveInitializer(
      builder: (context) {
        return MaterialApp.router(
          routerConfig: router,
          title: 'Abeul Planner',
          debugShowCheckedModeBanner: false,
          theme: appLightTheme,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ko', 'KR'),
            Locale('en', 'US'),
          ],
        );
      },
    );
  }
}
