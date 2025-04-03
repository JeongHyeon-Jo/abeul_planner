
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// planner
import 'package:abeul_planner/features/home_planner/presentation/screen/planner_home_screen.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/screen/calendar_planner_sceen.dart';
import 'package:abeul_planner/features/daily_planner/presentation/screen/daily_planner_sceen.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/screen/weekly_planner_sceen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => const PlannerHomeScreen(),
    ),
    GoRoute(
      path: 'daily',
      builder: (context, state) => const DailyPlannerScreen(),
    ),
    GoRoute(
      path: 'weekly',
      builder: (context, state) => const WeeklyPlannerScreen(),
    ),
    GoRoute(
      path: 'calendar',
      builder: (context, state) => const CalendarPlannerScreen(),
    ),
    GoRoute(
      path: 'settings',
      builder: (context, state) => const Placeholder(), // 추후 설정 화면 교체
    ),
  ],
);
