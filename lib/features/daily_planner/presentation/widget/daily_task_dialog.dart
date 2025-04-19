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
class DailyTaskDialog extends ConsumerStatefulWidget {
  final DailyTaskModel? task;
  final int? index;
  final TextEditingController situationController;
  final TextEditingController actionController;
  final String selectedPriority;
  final ValueChanged<int> onDelete;

  const DailyTaskDialog({
    super.key,
    required this.task,
    required this.index,
    required this.situationController,
    required this.actionController,
    required this.selectedPriority,
    required this.onDelete,
  });

  @override
  ConsumerState<DailyTaskDialog> createState() => _DailyTaskDialogState();
}

class _DailyTaskDialogState extends ConsumerState<DailyTaskDialog> {
  late String _localPriority;

  @override
  void initState() {
    super.initState();
    _localPriority = widget.selectedPriority;
  }

  @override
  Widget build(BuildContext context) {
    final priorityKeys = ['낮음', '보통', '중요'];

    return AlertDialog(
      title: Text(widget.task == null ? '새 일정 추가' : '일정 수정', style: AppTextStyles.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: widget.situationController,
              decoration: const InputDecoration(labelText: '상황 (예: 출근하면)'),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: widget.actionController,
              decoration: const InputDecoration(labelText: '행동 (예: 스트레칭하기)'),
            ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              value: _localPriority,
              items: priorityKeys.map((level) => DropdownMenuItem(
                value: level,
                child: Row(
                  children: [
                    getPriorityIcon(level),
                    SizedBox(width: 8.w),
                    Text(level, style: AppTextStyles.body),
                  ],
                ),
              )).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _localPriority = value);
              },
              decoration: const InputDecoration(labelText: '중요도'),
            ),
            if (widget.task != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onDelete(widget.index!);
                  },
                  child: Text('일정 제거', style: AppTextStyles.caption.copyWith(color: Colors.red)),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.situationController.clear();
            widget.actionController.clear();
            Navigator.of(context).pop();
          },
          child: Text('취소', style: AppTextStyles.body.copyWith(color: AppColors.subText)),
        ),
        ElevatedButton(
          onPressed: () {
            final situation = widget.situationController.text.trim();
            final action = widget.actionController.text.trim();

            if (situation.isEmpty || action.isEmpty) return;

            final newTask = DailyTaskModel(
              situation: situation,
              action: action,
              isCompleted: widget.task?.isCompleted ?? false,
              priority: _localPriority,
            );

            if (widget.task == null) {
              ref.read(dailyTaskProvider.notifier).addTask(newTask);
            } else {
              ref.read(dailyTaskProvider.notifier).editTask(widget.index!, newTask);
            }

            widget.situationController.clear();
            widget.actionController.clear();
            Navigator.of(context).pop();
          },
          child: Text('저장', style: AppTextStyles.button),
        ),
      ],
    );
  }
}