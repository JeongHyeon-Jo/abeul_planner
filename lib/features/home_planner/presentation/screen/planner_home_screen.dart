import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

// calendar, weekly, daily provider 불러오기
import '../../../calendar_planner/presentation/provider/calendar_task_provider.dart';
import '../../../weekly_planner/presentation/provider/weekly_task_provider.dart';
import '../../../daily_planner/presentation/provider/daily_task_provider.dart';

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
      appBar: AppBar(
        title: const Text('아블 플래너'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 오늘 날짜 표시
            Text(
              dateText,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),

            // 📅 캘린더 일정 섹션
            Text('캘린더 일정', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            if (calendarTasks
                .where((task) => task.date.year == now.year &&
                                 task.date.month == now.month &&
                                 task.date.day == now.day)
                .isEmpty)
              const Text('오늘 일정이 없습니다.')
            else
              ...calendarTasks
                  .where((task) => task.date.year == now.year &&
                                   task.date.month == now.month &&
                                   task.date.day == now.day)
                  .map((task) => Card(
                        child: ListTile(
                          title: Text(task.memo),
                          subtitle: Text(task.time),
                        ),
                      )),
            SizedBox(height: 20.h),

            // 📆 요일별 테마 & 할 일 섹션
            Text('$weekday요일 플래너', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            ...weeklyTasks
                .where((t) => t.day == weekday)
                .map((t) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('테마: ${t.theme}'),
                        ...t.tasks.map((task) => Card(child: ListTile(title: Text(task))))
                      ],
                    )),
            SizedBox(height: 20.h),

            // 🧩 일상 플래너 섹션
            Text('일상 플래너', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            if (dailyTasks.isEmpty)
              const Text('일상 기록이 없습니다.')
            else
              ...dailyTasks.map((t) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.check),
                      title: Text(t.situation),
                      subtitle: Text(t.action),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
