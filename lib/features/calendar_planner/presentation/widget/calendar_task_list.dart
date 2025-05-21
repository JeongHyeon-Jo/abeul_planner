// calendar_task_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/utils/priority_icon.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/calendar_task_model.dart';
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
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h), // 좌우 넓게
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
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
                    // 새 일정 추가 다이얼로그
                    showDialog(
                      context: context,
                      builder: (_) => CalendarTaskDialog(selectedDate: selectedDate),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // 일정이 없을 때
            if (tasks.isEmpty)
              Text('등록된 일정이 없습니다.', style: AppTextStyles.body)
            else
              // 일정 리스트 출력
              SizedBox(
                height: 400.h,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return InkWell(
                      onTap: () {
                        // 일정 수정 다이얼로그 열기
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
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 중요도 아이콘
                            getPriorityIcon(task.priority),
                            SizedBox(width: 12.w),
                            // 텍스트 내용
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '상황: ${DateFormat('yyyy년 MM월 dd일').format(task.date)}',
                                    style: AppTextStyles.caption,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    '행동: ${task.memo}',
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
                            // 완료 체크박스
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
              ),

            SizedBox(height: 16.h),

            // 닫기 버튼
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
    );
  }

  /// 날짜 비교 함수
  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
