// weekly_task_list.dart
import 'package:abeul_planner/core/utils/priority_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/features/weekly_planner/data/model/weekly_task_model.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/provider/weekly_task_provider.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/widget/weekly_task_dialog.dart';
import 'package:abeul_planner/features/auth/presentation/provider/user_provider.dart';

class WeeklyTaskList extends ConsumerWidget {
  final String day; // 해당 요일
  final List<WeeklyTask> tasks; // 일정 리스트
  final bool isEditing; // 편집 모드 여부
  final bool shrinkWrap; // 내부 스크롤 제어 여부
  final ScrollPhysics? physics; // 스크롤 설정

  const WeeklyTaskList({
    super.key,
    required this.day,
    required this.tasks,
    required this.isEditing,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    final sortedTasks = isEditing || !user.autoSortCompleted
        ? tasks
        : [
            ...tasks.where((task) => !task.isCompleted),
            ...tasks.where((task) => task.isCompleted),
          ];

    if (sortedTasks.isEmpty) {
      return SizedBox(
        height: 500.h, // 또는 Expanded로 바꿀 수도 있음
        child: Center(
          child: Text('등록된 일정이 없습니다.', style: AppTextStyles.body),
        ),
      );
    }

    return ReorderableListView.builder(
      padding: EdgeInsets.only(bottom: 80.h),
      shrinkWrap: shrinkWrap, // 상위에서 제어
      physics: physics, // 상위에서 제어
      buildDefaultDragHandles: false, // 커스텀 드래그 핸들 사용
      itemCount: sortedTasks.length,
      onReorder: (oldIndex, newIndex) {
        if (isEditing) {
          ref.read(weeklyTaskProvider.notifier).reorderTask(day, oldIndex, newIndex);
        }
      },
      itemBuilder: (context, index) {
        final task = sortedTasks[index];

        return Container(
          key: ValueKey('$index-${task.content}'), // 순서 변경을 위한 고유 키
          margin: EdgeInsets.symmetric(vertical: 6.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primary, width: 1.2.w),
          ),
          child: Row(
            children: [
              // 중요도 아이콘
              if (getPriorityIcon(task.priority) != null) getPriorityIcon(task.priority)!,
              SizedBox(width: 12.w),

              // 일정 내용 텍스트
              Expanded(
                child: Text(task.content, style: AppTextStyles.body),
              ),

              // 편집 모드일 때만 표시되는 아이콘들
              if (isEditing) ...[
                IconButton(
                  icon: Icon(Icons.edit, size: 20.sp, color: AppColors.subText),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => WeeklyTaskDialog(
                        days: ['월', '화', '수', '목', '금', '토', '일'],
                        onTaskAdded: (_) {}, // 수정 시 탭 이동 없음
                        existingTask: task,
                        editingIndex: index,
                        editingDay: day,
                      ),
                    );
                  },
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: Icon(Icons.drag_handle, size: 24.sp, color: AppColors.subText),
                ),
              ] else
                // 체크박스 (수행 여부)
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (_) {
                    final realIndex = ref.read(weeklyTaskProvider).firstWhere((model) => model.day == day)
                        .tasks
                        .indexOf(task);
                    ref.read(weeklyTaskProvider.notifier).toggleTask(day, realIndex);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}