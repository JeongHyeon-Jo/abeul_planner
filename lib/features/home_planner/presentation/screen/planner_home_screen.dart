// planner_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/core/text_styles.dart';
import 'package:abeul_planner/core/color.dart';

// calendar, weekly, daily provider 불러오기
import 'package:abeul_planner/features/calendar_planner/presentation/provider/calendar_task_provider.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/provider/weekly_task_provider.dart';
import 'package:abeul_planner/features/daily_planner/presentation/provider/daily_task_provider.dart';

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
      appBar: const CustomAppBar(
        title: '종합 플래너',
        isTransparent: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 오늘 날짜 표시
            Text(
              dateText,
              style: AppTextStyles.title,
            ),
            SizedBox(height: 20.h),

            // 📅 달력 플래너
            Text('달력 플래너', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            if (calendarTasks
                .where((task) => task.date.year == now.year &&
                                 task.date.month == now.month &&
                                 task.date.day == now.day)
                .isEmpty)
              Text('오늘 일정이 없습니다.', style: AppTextStyles.body)
            else
              ...calendarTasks
                  .where((task) => task.date.year == now.year &&
                                   task.date.month == now.month &&
                                   task.date.day == now.day)
                  .map((task) => Card(
                        child: ListTile(
                          title: Text(task.memo, style: AppTextStyles.body),
                          subtitle: Text(task.time, style: AppTextStyles.caption),
                        ),
                      )),
            SizedBox(height: 20.h),

            // 📆 주간 플래너
            Text('주간 플래너($weekday요일)', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            ...weeklyTasks
                .where((t) => t.day == weekday)
                .map((t) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('테마: ${t.theme}', style: AppTextStyles.body),
                        ...t.tasks.map((task) => Card(
                              child: ListTile(title: Text(task, style: AppTextStyles.body)),
                            ))
                      ],
                    )),
            SizedBox(height: 20.h),

            // 일상 플래너
            Text('일상 플래너', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            if (dailyTasks.isEmpty)
              Text('일상 기록이 없습니다.', style: AppTextStyles.body)
            else
              ...dailyTasks.map((t) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.check),
                      title: Text(t.situation, style: AppTextStyles.body),
                      subtitle: Text(t.action, style: AppTextStyles.caption),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
