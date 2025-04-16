// task_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abeul_planner/core/color.dart';
import 'package:abeul_planner/core/text_styles.dart';
import 'package:abeul_planner/core/widgets/priority_icon.dart';
import 'package:abeul_planner/features/daily_planner/data/model/daily_task_model.dart';
import 'package:abeul_planner/features/daily_planner/presentation/provider/daily_task_provider.dart';

/// 할 일 추가 및 수정 다이얼로그 위젯
class TaskDialog extends ConsumerWidget {
  final DailyTaskModel? task;
  final int? index;
  final TextEditingController situationController;
  final TextEditingController actionController;
  final String selectedPriority;
  final ValueChanged<String> onPriorityChanged;
  final ValueChanged<int> onDelete;

  const TaskDialog({
    super.key,
    required this.task,
    required this.index,
    required this.situationController,
    required this.actionController,
    required this.selectedPriority,
    required this.onPriorityChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priorityKeys = ['낮음', '보통', '중요'];

    return AlertDialog(
      title: Text(task == null ? '새 플랜 추가' : '플랜 수정', style: AppTextStyles.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: situationController,
              decoration: const InputDecoration(labelText: '상황 (예: 출근하면)'),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: actionController,
              decoration: const InputDecoration(labelText: '행동 (예: 스트레칭하기)'),
            ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              value: selectedPriority,
              items: priorityKeys.map((level) => DropdownMenuItem(
                value: level,
                child: Row(
                  children: [
                    getPriorityIcon(level), // 중요도 아이콘 사용
                    SizedBox(width: 8.w),
                    Text(level, style: AppTextStyles.body),
                  ],
                ),
              )).toList(),
              onChanged: (value) {
                if (value != null) onPriorityChanged(value);
              },
              decoration: const InputDecoration(labelText: '중요도'),
            ),
            if (task != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onDelete(index!);
                  },
                  child: Text('플랜 제거', style: AppTextStyles.caption.copyWith(color: Colors.red)),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            situationController.clear();
            actionController.clear();
            Navigator.of(context).pop();
          },
          child: Text('취소', style: AppTextStyles.body.copyWith(color: AppColors.subText)),
        ),
        ElevatedButton(
          onPressed: () {
            final situation = situationController.text.trim();
            final action = actionController.text.trim();

            if (situation.isEmpty || action.isEmpty) return;

            final newTask = DailyTaskModel(
              situation: situation,
              action: action,
              isCompleted: task?.isCompleted ?? false,
              priority: selectedPriority,
            );

            if (task == null) {
              ref.read(dailyTaskProvider.notifier).addTask(newTask);
            } else {
              ref.read(dailyTaskProvider.notifier).editTask(index!, newTask);
            }

            situationController.clear();
            actionController.clear();
            Navigator.of(context).pop();
          },
          child: Text('저장', style: AppTextStyles.button),
        ),
      ],
    );
  }
}