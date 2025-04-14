// weekly_task_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/color.dart';
import 'package:abeul_planner/core/text_styles.dart';
import 'package:abeul_planner/features/weekly_planner/data/model/weekly_task_model.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/provider/weekly_task_provider.dart';

/// 주간 할 일 리스트 표시 위젯
class WeeklyTaskList extends ConsumerWidget {
  final String day;
  final List<WeeklyTask> tasks;

  const WeeklyTaskList({super.key, required this.day, required this.tasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tasks.isEmpty) {
      return Center(child: Text('등록된 할 일이 없어요.', style: AppTextStyles.body));
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Container(
          margin: EdgeInsets.symmetric(vertical: 6.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primary),
          ),
          child: Row(
            children: [
              Icon(
                task.priority == '중요'
                    ? Icons.priority_high
                    : task.priority == '보통'
                        ? Icons.circle
                        : Icons.arrow_downward,
                color: task.priority == '중요'
                    ? Colors.red
                    : task.priority == '보통'
                        ? Colors.orange
                        : Colors.grey,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(task.content, style: AppTextStyles.body),
              ),
              Checkbox(
                value: task.isCompleted,
                onChanged: (_) {
                  ref.read(weeklyTaskProvider.notifier).toggleTask(day, index);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}