// daily_section.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/utils/priority_utils.dart';
import 'package:abeul_planner/core/utils/priority_icon.dart';
import 'package:abeul_planner/features/daily_planner/data/model/daily_task_model.dart';
import 'package:abeul_planner/features/daily_planner/presentation/provider/daily_task_provider.dart';

class DailySection extends ConsumerWidget {
  final List<DailyTaskModel> dailyTasks;

  const DailySection({super.key, required this.dailyTasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (dailyTasks.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('일상 일정이 없습니다.', style: AppTextStyles.body),
            SizedBox(height: 12.h),
            ElevatedButton.icon(
              onPressed: () {
                context.go('/daily');
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('추가하러 가기', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 완료 여부 + 중요도 기준 정렬
    final sortedTasks = [...dailyTasks];
    sortedTasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return priorityValue(a.priority).compareTo(priorityValue(b.priority));
    });

    final displayTasks = sortedTasks.take(5).toList(); // 최대 5개만

    return Column(
      children: displayTasks.asMap().entries.map((entry) {
        final index = entry.key;
        final task = entry.value;

        return Card(
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
                ref.read(dailyTaskProvider.notifier).toggleTask(index);
              },
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          ),
        );
      }).toList(),
    );
  }
}
