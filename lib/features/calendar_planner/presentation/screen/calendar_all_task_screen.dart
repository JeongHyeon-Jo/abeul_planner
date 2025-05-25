// calendar_all_task_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/calendar_task_model.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/provider/calendar_task_provider.dart';
import 'package:abeul_planner/core/utils/priority_icon.dart';

class CalendarAllTaskScreen extends ConsumerWidget {
  const CalendarAllTaskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(calendarTaskProvider);
    final sortedTasks = [...tasks]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: CustomAppBar(
        title: Text('달력 플래너 기록', style: AppTextStyles.title.copyWith(color: AppColors.text)),
        isTransparent: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: sortedTasks.isEmpty
            ? const Center(child: Text('등록된 일정이 없습니다.'))
            : ListView.separated(
                itemCount: sortedTasks.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final task = sortedTasks[index];

                  return Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.primary, width: 1.w),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4.r,
                          offset: Offset(0, 2.h),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        getPriorityIcon(task.priority),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('yyyy.MM.dd').format(task.date),
                                style: AppTextStyles.caption,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                task.memo,
                                style: AppTextStyles.body.copyWith(
                                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                  color: task.isCompleted ? AppColors.subText : AppColors.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: Checkbox(
                            value: task.isCompleted,
                            onChanged: (_) {
                              ref.read(calendarTaskProvider.notifier).toggleTask(task);
                            },
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
