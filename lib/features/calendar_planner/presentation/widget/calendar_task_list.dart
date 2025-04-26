// calendar_task_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/color.dart';
import 'package:abeul_planner/core/text_styles.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/calendar_task_model.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/provider/calendar_task_provider.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/widget/calendar_task_dialog.dart'; // ✅ 추가 필요!

class CalendarTaskList extends ConsumerWidget {
  final List<CalendarTaskModel> tasks;

  const CalendarTaskList({super.key, required this.tasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
          border: Border.all(color: AppColors.primary, width: 1.w),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: SizedBox(
            height: 260.h,
            child: tasks.isEmpty
                ? Center(
                    child: Text(
                      '해당 날짜에 등록된 일정이 없어요.',
                      style: AppTextStyles.body,
                    ),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];

                      return ListTile(
                        leading: Icon(Icons.event_note, size: 20.sp),
                        title: Text(
                          task.memo,
                          style: AppTextStyles.body,
                        ),
                        // 클릭 시 수정 다이얼로그 열기
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => CalendarTaskDialog(
                              existingTask: task,
                              selectedDate: task.date,
                            ),
                          );
                        },
                        // 길게 누르면 삭제 다이얼로그
                        onLongPress: () {
                          _showDeleteDialog(context, ref, task);
                        },
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  /// 삭제 확인 다이얼로그
  void _showDeleteDialog(BuildContext context, WidgetRef ref, CalendarTaskModel task) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('일정 삭제', style: AppTextStyles.title),
        content: Text('정말 이 일정을 삭제하시겠습니까?', style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('취소', style: AppTextStyles.body.copyWith(color: AppColors.subText)),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = ref.read(calendarTaskProvider.notifier);
              provider.deleteSpecificTask(task);
              Navigator.of(context).pop();
            },
            child: Text('삭제', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }
}
