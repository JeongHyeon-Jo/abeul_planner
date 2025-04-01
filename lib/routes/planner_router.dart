import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:abeul_planner/features/home_planner/presentation/screen/planner_home_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => const PlannerHomeScreen(),
    ),
    // 여기에 다른 플래너 화면들 추가 예정 (ex: 일상, 요일, 달력 등)
  ],
);
