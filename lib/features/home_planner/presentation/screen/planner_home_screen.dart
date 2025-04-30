// planner_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
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
              // 달력 플래너
              SizedBox(
                child: _buildSectionContainer(
                  context,
                  title: '달력 플래너',
                  route: '/calendar',
                  child: SingleChildScrollView(
                    child: CalendarSection(now: now, calendarTasks: calendarTasks),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // 주간 플래너
              SizedBox(
                child: _buildSectionContainer(
                  context,
                  title: '주간 플래너',
                  route: '/weekly',
                  child: SingleChildScrollView(
                    child: WeeklySection(weekday: weekday, weeklyTasks: weeklyTasks),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // 일상 플래너
              SizedBox(
                child: _buildSectionContainer(
                  context,
                  title: '일상 플래너',
                  route: '/daily',
                  child: SingleChildScrollView(
                    child: DailySection(dailyTasks: dailyTasks),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 공통 섹션 컨테이너 위젯
  Widget _buildSectionContainer(BuildContext context, {
    required String title,
    required String route,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(16.0.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, title, route),
          SizedBox(height: 8.h),
          child,
        ],
      ),
    );
  }

  /// 공통 섹션 타이틀 위젯
  Widget _buildSectionTitle(BuildContext context, String title, String route) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          color: AppColors.subText,
          onPressed: () {
            context.go(route);
          },
        ),
      ],
    );
  }
}
