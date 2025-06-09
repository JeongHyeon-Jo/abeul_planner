// calendar_section.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/utils/priority_icon.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/calendar_task_model.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/provider/calendar_task_provider.dart';

class CalendarSection extends ConsumerWidget {
  final DateTime now;
  final List<CalendarTaskModel> calendarTasks;

  const CalendarSection({super.key, required this.now, required this.calendarTasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTasks = calendarTasks.where(
      (task) => task.date.year == now.year &&
                task.date.month == now.month &&
                task.date.day == now.day,
    ).toList();

    if (todayTasks.isEmpty) {
      return SizedBox(
        height: 100.h,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('등록된 일정이 없습니다.', style: AppTextStyles.body),
              SizedBox(height: 12.h),
              ElevatedButton.icon(
                onPressed: () {
                  context.go('/calendar');
                },
                icon: const Icon(Icons.add, color: AppColors.text),
                label: const Text('일정 추가', style: TextStyle(color: AppColors.text)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimary,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    side: BorderSide(color: AppColors.primary, width: 1.2.w),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 중요도 + 완료 여부 정렬 (calendar_task_list.dart와 동일하게)
    todayTasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1; // 완료 안 된 게 먼저
      }

      int priorityA = a.priority == '중요' ? 0 : 1;
      int priorityB = b.priority == '중요' ? 0 : 1;

      return priorityA.compareTo(priorityB);
    });

    final displayTasks = todayTasks.take(3).toList(); // 최대 3개만 표시

    return Column(
      children: displayTasks.map((task) {
        return Card(
          color: Colors.white,
          margin: EdgeInsets.symmetric(vertical: 6.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: AppColors.primary, width: 1.w),
          ),
          child: ListTile(
            leading: getPriorityIcon(task.priority),
            title: Text(
              task.memo,
              style: AppTextStyles.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Checkbox(
              value: task.isCompleted,
              onChanged: (value) {
                if (value != null) {
                  ref.read(calendarTaskProvider.notifier).toggleTask(task);
                }
              },
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          ),
        );
      }).toList(),
    );
  }
}
