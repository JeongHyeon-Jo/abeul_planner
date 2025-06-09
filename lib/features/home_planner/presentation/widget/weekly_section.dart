// weekly_section.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/utils/priority_icon.dart';
import 'package:abeul_planner/features/weekly_planner/data/model/weekly_task_model.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/provider/weekly_task_provider.dart';

class WeeklySection extends ConsumerWidget {
  final String weekday;
  final List<WeeklyTaskModel> weeklyTasks;

  const WeeklySection({super.key, required this.weekday, required this.weeklyTasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayWeekly = weeklyTasks.where((t) => t.day == weekday).toList();

    // 모든 할 일(flatten) 리스트로 변환
    final allTasks = todayWeekly.expand((t) => t.tasks.map((task) => (t.day, task))).toList();

    // 완료 여부 + 중요도 기준 정렬
    allTasks.sort((a, b) {
      final aTask = a.$2;
      final bTask = b.$2;

      if (aTask.isCompleted != bTask.isCompleted) {
        return aTask.isCompleted ? 1 : -1;
      }

      int priorityA = aTask.priority == '중요' ? 0 : 1;
      int priorityB = bTask.priority == '중요' ? 0 : 1;

      return priorityA.compareTo(priorityB);
    });

    final displayTasks = allTasks.take(3).toList(); // 최대 3개만 표시

    // 할 일이 없는 경우: 텍스트 + 버튼 표시
    if (displayTasks.isEmpty) {
      return SizedBox(
        height: 100.h,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$weekday요일에 등록된 일정이 없습니다.', style: AppTextStyles.body),
              SizedBox(height: 12.h),
              ElevatedButton.icon(
                onPressed: () {
                  context.go('/weekly');
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

    return Column(
      children: displayTasks.map((entry) {
        final (day, task) = entry;
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
              task.content,
              style: AppTextStyles.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Checkbox(
              value: task.isCompleted,
              onChanged: (_) {
                final todayModel = ref.watch(weeklyTaskProvider).firstWhere((model) => model.day == day);
                final taskIndex = todayModel.tasks.indexOf(task);
                if (taskIndex != -1) {
                  ref.read(weeklyTaskProvider.notifier).toggleTask(day, taskIndex);
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
