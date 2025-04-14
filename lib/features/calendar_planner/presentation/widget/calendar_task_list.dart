// calendar_task_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/color.dart';
import 'package:abeul_planner/core/text_styles.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/calendar_task_model.dart';

/// 선택된 날짜의 일정 목록을 보여주는 위젯
class CalendarTaskList extends StatelessWidget {
  final List<CalendarTaskModel> tasks;

  const CalendarTaskList({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
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
                          '${task.time} - ${task.memo}',
                          style: AppTextStyles.body,
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}