// daily_task_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/utils/priority_icon.dart';
import 'package:abeul_planner/features/daily_planner/data/model/daily_task_model.dart';
import 'package:abeul_planner/features/daily_planner/presentation/provider/daily_task_provider.dart';

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
  late TextEditingController _goalController;
  bool _isAlways = true;

  @override
  void initState() {
    super.initState();
    _localPriority = widget.selectedPriority;
    _goalController = TextEditingController();

    final goal = widget.task?.goalCount;
    _isAlways = goal == null;
    _goalController.text = goal?.toString() ?? '';
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final priorityKeys = ['낮음', '보통', '중요'];
    final isEditMode = widget.task != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  isEditMode ? '일정 수정' : '새 일정 추가',
                  style: AppTextStyles.title,
                ),
              ),
              SizedBox(height: 24.h),

              TextField(
                controller: widget.situationController,
                decoration: const InputDecoration(labelText: '언제'),
              ),
              SizedBox(height: 16.h),

              TextField(
                controller: widget.actionController,
                decoration: const InputDecoration(labelText: '일정 내용'),
              ),
              SizedBox(height: 16.h),

              DropdownButtonFormField<String>(
                value: _localPriority,
                decoration: const InputDecoration(labelText: '중요도'),
                items: priorityKeys.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Row(
                      children: [
                        getPriorityIcon(level),
                        SizedBox(width: 8.w),
                        Text(level, style: AppTextStyles.body),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _localPriority = value);
                },
              ),
              SizedBox(height: 16.h),

              Text('목표 횟수', style: AppTextStyles.body),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _goalController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      enabled: !_isAlways,
                      decoration: const InputDecoration(hintText: '예: 5'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Checkbox(
                    value: _isAlways,
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() => _isAlways = val);
                    },
                  ),
                  Text('항상', style: AppTextStyles.caption),
                ],
              ),
              SizedBox(height: 16.h),

              if (isEditMode)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onDelete(widget.index!);
                    },
                    child: Text('일정 제거',
                        style: TextStyle(color: Colors.red, fontSize: 13.sp)),
                  ),
                ),
              SizedBox(height: 20.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      widget.situationController.clear();
                      widget.actionController.clear();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightPrimary,
                      foregroundColor: AppColors.text,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      child: Text('취소', style: AppTextStyles.body),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final situation = widget.situationController.text.trim();
                      final action = widget.actionController.text.trim();
                      if (situation.isEmpty || action.isEmpty) return;

                      final goal = _isAlways
                          ? null
                          : int.tryParse(_goalController.text.trim());

                      final newTask = DailyTaskModel(
                        situation: situation,
                        action: action,
                        isCompleted: widget.task?.isCompleted ?? false,
                        priority: _localPriority,
                        goalCount: goal,
                        completedCount: widget.task?.completedCount ?? 0,
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      child: Text('저장', style: AppTextStyles.button),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
