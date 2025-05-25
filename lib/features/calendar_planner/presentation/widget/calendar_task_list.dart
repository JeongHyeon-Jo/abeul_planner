// calendar_task_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/utils/priority_icon.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/provider/calendar_task_provider.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/widget/calendar_task_dialog.dart';

/// 선택된 날짜의 일정을 보여주는 리스트 다이얼로그
class CalendarTaskList extends ConsumerWidget {
  final DateTime selectedDate; // 선택된 날짜

  const CalendarTaskList({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 선택된 날짜에 해당하는 일정 필터링
    final tasks = ref.watch(calendarTaskProvider)
        .where((task) => isSameDay(task.date, selectedDate))
        .toList();

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상단 타이틀 + 일정 추가 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('yyyy년 MM월 dd일').format(selectedDate), style: AppTextStyles.title),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => CalendarTaskDialog(selectedDate: selectedDate),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              if (tasks.isEmpty)
                Text('등록된 일정이 없습니다.', style: AppTextStyles.body)
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => CalendarTaskDialog(
                            existingTask: task,
                            selectedDate: selectedDate,
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.primary),
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
                                    DateFormat('yyyy년 MM월 dd일').format(task.date),
                                    style: AppTextStyles.caption,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    task.memo,
                                    style: AppTextStyles.body.copyWith(
                                      decoration: task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                      color: task.isCompleted
                                          ? AppColors.subText
                                          : AppColors.text,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Checkbox(
                              value: task.isCompleted,
                              onChanged: (_) {
                                ref.read(calendarTaskProvider.notifier).toggleTask(task);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              SizedBox(height: 16.h),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('닫기', style: AppTextStyles.body),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
