// weekly_task_dialog.dart
import 'package:abeul_planner/core/utils/priority_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/features/weekly_planner/data/model/weekly_task_model.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/provider/weekly_task_provider.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/widget/weekly_delete_dialog.dart';

/// 주간 일정 추가 및 수정 다이얼로그 위젯
class WeeklyTaskDialog extends ConsumerStatefulWidget {
  final List<String> days;
  final void Function(String selectedDay) onTaskAdded;
  final WeeklyTask? existingTask;
  final int? editingIndex;
  final String? editingDay;

  const WeeklyTaskDialog({
    super.key,
    required this.days,
    required this.onTaskAdded,
    this.existingTask,
    this.editingIndex,
    this.editingDay,
  });

  @override
  ConsumerState<WeeklyTaskDialog> createState() => _WeeklyTaskDialogState();
}

class _WeeklyTaskDialogState extends ConsumerState<WeeklyTaskDialog> {
  final TextEditingController _contentController = TextEditingController();
  String _selectedDay = '월';
  String _priority = '보통';
  final List<String> _priorityKeys = ['낮음', '보통', '중요'];

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.editingDay ?? widget.days.first;
    _contentController.text = widget.existingTask?.content ?? '';
    _priority = widget.existingTask?.priority ?? '보통';
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.existingTask != null;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isEditMode ? '일정 수정' : '일정 추가', style: AppTextStyles.title),
              SizedBox(height: 16.h),

              DropdownButtonFormField<String>(
                value: _selectedDay,
                items: widget.days
                    .map((day) => DropdownMenuItem(
                          value: day,
                          child: Text(day),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedDay = value);
                },
                decoration: const InputDecoration(labelText: '요일 선택'),
              ),
              SizedBox(height: 12.h),

              TextField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: '일정 내용'),
              ),
              SizedBox(height: 12.h),

              DropdownButtonFormField<String>(
                value: _priority,
                items: _priorityKeys.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Row(
                      children: [
                        getPriorityIcon(level),
                        SizedBox(width: 8.w),
                        Text(level),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _priority = value);
                },
                decoration: const InputDecoration(labelText: '중요도'),
              ),

              if (isEditMode)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => WeeklyDeleteDialog(
                          day: widget.editingDay!,
                          index: widget.editingIndex!,
                        ),
                      );
                    },
                    child: Text('일정 제거', style: AppTextStyles.caption.copyWith(color: Colors.red)),
                  ),
                ),

              SizedBox(height: 16.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('취소', style: AppTextStyles.body.copyWith(color: AppColors.subText)),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: () {
                      final content = _contentController.text.trim();
                      if (content.isEmpty) return;

                      final newTask = WeeklyTask(content: content, priority: _priority);

                      if (isEditMode &&
                          widget.editingIndex != null &&
                          widget.editingDay != null) {
                        ref.read(weeklyTaskProvider.notifier).moveAndEditTask(
                              fromDay: widget.editingDay!,
                              toDay: _selectedDay,
                              taskIndex: widget.editingIndex!,
                              newTask: newTask,
                            );
                      } else {
                        ref.read(weeklyTaskProvider.notifier).addTask(_selectedDay, newTask);
                        widget.onTaskAdded(_selectedDay);
                      }

                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('저장', style: AppTextStyles.button),
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
