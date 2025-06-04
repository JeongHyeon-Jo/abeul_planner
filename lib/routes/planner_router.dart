// planner_router.dart
import 'package:go_router/go_router.dart';
// 플래너 화면
import 'package:abeul_planner/features/home_planner/presentation/screen/planner_home_screen.dart';
import 'package:abeul_planner/features/home_planner/presentation/widget/planner_scaffold.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/screen/calendar_planner_sceen.dart';
import 'package:abeul_planner/features/daily_planner/presentation/screen/daily_planner_screen.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/screen/weekly_planner_sceen.dart';
// 설정 화면
import 'package:abeul_planner/features/settings/presentation/screen/settings_screen.dart';
import 'package:abeul_planner/features/record/presentation/screen/daily_record_screen.dart';
import 'package:abeul_planner/features/record/presentation/screen/weekly_record_screen.dart';
import 'package:abeul_planner/features/record/presentation/screen/calendar_record_screen.dart';
import 'package:abeul_planner/features/settings/presentation/screen/info/app_info_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) => PlannerScaffold(child: child),
      routes: [
        // 플래너
        GoRoute(
          path: '/home',
          builder: (context, state) => const PlannerHomeScreen(),
        ),
        GoRoute(
          path: '/daily',
          builder: (context, state) => const DailyPlannerScreen(),
        ),
        GoRoute(
          path: '/weekly',
          builder: (context, state) => const WeeklyPlannerScreen(),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarPlannerScreen(),
        ),
        // 설정
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/settings/app-info',
          builder: (context, state) => const AppInfoScreen(),
        ),
        // 일정 기록
        GoRoute(
          path: '/records/daily',
          builder: (context, state) => const DailyRecordScreen(),
        ),
        GoRoute(
          path: '/records/weekly',
          builder: (context, state) => const WeeklyRecordScreen(),
        ),
        GoRoute(
          path: '/records/calendar',
          builder: (context, state) => const CalendarRecordScreen(),
        ),
      ],
    ),
  ],
);
