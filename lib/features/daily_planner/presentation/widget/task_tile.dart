// task_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/features/daily_planner/data/model/daily_task_model.dart';
import 'package:abeul_planner/core/color.dart';
import 'package:abeul_planner/core/text_styles.dart';
import 'package:abeul_planner/core/widgets/priority_icon.dart';

/// 개별 할 일 항목 위젯
class TaskTile extends StatelessWidget {
  final DailyTaskModel task; // 할 일 모델
  final int index; // 해당 항목의 인덱스
  final bool isEditing; // 편집 모드 여부
  final VoidCallback onEdit; // 편집 버튼 콜백
  final VoidCallback onToggle; // 체크박스 변경 콜백

  const TaskTile({
    super.key,
    required this.task,
    required this.index,
    required this.isEditing,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
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
          getPriorityIcon(task.priority), // 중요도에 따른 아이콘 사용
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상황 텍스트 (완료 시 회색 + 취소선)
                Text(
                  task.situation,
                  style: AppTextStyles.body.copyWith(
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted ? AppColors.subText : AppColors.text,
                  ),
                ),
                SizedBox(height: 4.h),
                // 행동 텍스트 (완료 시 회색 + 취소선)
                Text(
                  task.action,
                  style: AppTextStyles.caption.copyWith(
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted ? AppColors.subText : AppColors.subText,
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
            Icon(Icons.drag_indicator, size: 24.sp),
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
