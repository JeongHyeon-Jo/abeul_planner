// planner_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
// core
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/core/text_styles.dart';
import 'package:abeul_planner/core/color.dart';
// provider
import 'package:abeul_planner/features/calendar_planner/presentation/provider/calendar_task_provider.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/provider/weekly_task_provider.dart';
import 'package:abeul_planner/features/daily_planner/presentation/provider/daily_task_provider.dart';
// section widget
import 'package:abeul_planner/features/home_planner/presentation/widget/calendar_section.dart';
import 'package:abeul_planner/features/home_planner/presentation/widget/weekly_section.dart';
import 'package:abeul_planner/features/home_planner/presentation/widget/daily_section.dart';

/// 종합 플래너 화면 (홈 플래너)
class PlannerHomeScreen extends ConsumerWidget {
  const PlannerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarTasks = ref.watch(calendarTaskProvider);
    final weeklyTasks = ref.watch(weeklyTaskProvider);
    final dailyTasks = ref.watch(dailyTaskProvider);

    final now = DateTime.now();
    final dateText = DateFormat('M월 d일 (E)', 'ko_KR').format(now);
    final weekday = DateFormat('E', 'ko_KR').format(now);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          '',
          style: AppTextStyles.title.copyWith(color: AppColors.text),
        ),
        isTransparent: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.primary, width: 1.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0.w),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateText, style: AppTextStyles.title),
                  SizedBox(height: 20.h),

                  // 📅 달력 플래너
                  Text('달력 플래너', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                  Divider(color: AppColors.primary),
                  CalendarSection(now: now, calendarTasks: calendarTasks),

                  Divider(color: AppColors.primary),

                  // 📆 주간 플래너
                  Text('주간 플래너 ($weekday요일)', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                  Divider(color: AppColors.primary),
                  WeeklySection(weekday: weekday, weeklyTasks: weeklyTasks),

                  Divider(color: AppColors.primary),

                  // 📝 일상 플래너
                  Text('일상 플래너', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                  Divider(color: AppColors.primary),
                  DailySection(dailyTasks: dailyTasks),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
