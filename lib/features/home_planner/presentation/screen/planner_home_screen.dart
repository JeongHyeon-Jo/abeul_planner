// planner_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
// core
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/styles/color.dart';
// provider
import 'package:abeul_planner/features/calendar_planner/presentation/provider/calendar_task_provider.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/provider/weekly_task_provider.dart';
import 'package:abeul_planner/features/daily_planner/presentation/provider/daily_task_provider.dart';
// section widget
import 'package:abeul_planner/features/home_planner/presentation/widget/calendar_section.dart';
import 'package:abeul_planner/features/home_planner/presentation/widget/weekly_section.dart';
import 'package:abeul_planner/features/home_planner/presentation/widget/daily_section.dart';
import 'package:abeul_planner/features/home_planner/presentation/widget/expandable_section.dart';

class PlannerHomeScreen extends ConsumerWidget {
  const PlannerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarTasks = ref.watch(calendarTaskProvider);
    final weeklyTasks = ref.watch(weeklyTaskProvider);
    final dailyTasks = ref.watch(dailyTaskProvider);

    final now = DateTime.now();
    final appBarTitle = DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(now);
    final weekday = DateFormat('E', 'ko_KR').format(now);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          appBarTitle,
          style: AppTextStyles.title.copyWith(color: AppColors.text),
        ),
        isTransparent: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ExpandableSection(
                title: '달력 플래너',
                route: '/calendar',
                child: CalendarSection(now: now, calendarTasks: calendarTasks),
              ),
              SizedBox(height: 16.h),
              ExpandableSection(
                title: '주간 플래너',
                route: '/weekly',
                child: WeeklySection(weekday: weekday, weeklyTasks: weeklyTasks),
              ),
              SizedBox(height: 16.h),
              ExpandableSection(
                title: '일상 플래너',
                route: '/daily',
                child: DailySection(dailyTasks: dailyTasks),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
