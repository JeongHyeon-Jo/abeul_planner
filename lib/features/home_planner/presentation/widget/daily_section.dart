// daily_section.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/utils/priority_icon.dart';
import 'package:abeul_planner/features/daily_planner/data/model/daily_task_model.dart';
import 'package:abeul_planner/features/daily_planner/presentation/provider/daily_task_provider.dart';

class DailySection extends ConsumerWidget {
  final List<DailyTaskModel> dailyTasks;

  const DailySection({super.key, required this.dailyTasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (dailyTasks.isEmpty) {
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
                  context.go('/daily');
                },
                icon: Icon(Icons.add, size: 18.sp, color: AppColors.text),
                label: Text('일정 추가', style: AppTextStyles.body.copyWith(color: AppColors.text)),
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

    final sortedTasks = [...dailyTasks];
    sortedTasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }

      int priorityA = a.priority == '중요' ? 0 : 1;
      int priorityB = b.priority == '중요' ? 0 : 1;

      return priorityA.compareTo(priorityB);
    });

    final displayTasks = sortedTasks.take(5).toList();

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
              task.situation,
              style: AppTextStyles.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              task.action,
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Checkbox(
              value: task.isCompleted,
              onChanged: (_) {
                final originalIndex = ref.read(dailyTaskProvider).indexOf(task);
                if (originalIndex != -1) {
                  ref.read(dailyTaskProvider.notifier).toggleTask(originalIndex);
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
