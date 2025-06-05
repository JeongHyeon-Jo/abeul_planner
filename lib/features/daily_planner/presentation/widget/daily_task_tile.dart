// task_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/features/daily_planner/data/model/daily_task_model.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/utils/priority_icon.dart';

/// 개별 할 일 항목 위젯
class DailyTaskTile extends StatelessWidget {
  final DailyTaskModel task;
  final int index;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  const DailyTaskTile({
    super.key,
    required this.task,
    required this.index,
    required this.isEditing,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final remainingCount = task.goalCount != null
      ? task.goalCount! - (task.completedCount ?? 0)
      : null;

    final showRemaining = remainingCount != null && remainingCount > 0;

    return Container(
      key: ValueKey('$index-${task.situation}'),
      margin: EdgeInsets.symmetric(vertical: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
          if (getPriorityIcon(task.priority) != null)
            getPriorityIcon(task.priority)!,
            SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.situation,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  task.action,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.actionText,
                  ),
                ),
                if (showRemaining)
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Text(
                      '$remainingCount회 남음',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.subText,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isEditing) ...[
            IconButton(
              icon: Icon(Icons.edit, color: AppColors.subText, size: 20.sp),
              onPressed: onEdit,
            ),
            ReorderableDragStartListener(
              index: index,
              child: Icon(Icons.drag_handle, size: 24.sp, color: AppColors.subText),
            ),
          ] else
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: Checkbox(
                value: task.isCompleted,
                onChanged: (_) => onToggle(),
              ),
            ),
        ],
      ),
    );
  }
}
