// weekly_task_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// core
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/utils/priority_icon.dart';
// feature
import 'package:abeul_planner/features/weekly_planner/data/model/weekly_task_model.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/provider/weekly_task_provider.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/widget/weekly_delete_dialog.dart';

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
  bool _isImportant = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.editingDay ?? widget.days.first;
    _contentController.text = widget.existingTask?.content ?? '';
    _isImportant = widget.existingTask?.priority == '중요';
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.existingTask != null;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Dialog(
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
                    isEditMode ? '일정 수정' : '일정 추가',
                    style: AppTextStyles.title,
                  ),
                ),
                SizedBox(height: 24.h),

                DropdownButtonFormField<String>(
                  value: _selectedDay,
                  decoration: InputDecoration(
                    labelText: '요일 선택',
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.highlight, width: 2),
                    ),
                  ),
                  items: widget.days
                      .map((day) => DropdownMenuItem(value: day, child: Text(day)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedDay = value);
                  },
                ),
                SizedBox(height: 16.h),

                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: '일정 내용',
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.highlight, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                GestureDetector(
                  onTap: () => setState(() => _isImportant = !_isImportant),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      border: Border.all(
                        color: _isImportant ? AppColors.highlight : AppColors.primary,
                        width: 2.w,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        getPriorityIcon('중요') ?? const SizedBox(),
                        SizedBox(width: 6.w),
                        Text('중요 일정', style: AppTextStyles.body),
                        Spacer(),
                        Icon(
                          Icons.check,
                          color: _isImportant ? AppColors.success : AppColors.subText,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                if (isEditMode) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => WeeklyDeleteDialog(
                            day: widget.editingDay!,
                            index: widget.editingIndex!,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text('일정 제거',
                          style: AppTextStyles.body.copyWith(color: Colors.white)),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
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
                        final content = _contentController.text.trim();
                        if (content.isEmpty) return;

                        final newTask = WeeklyTask(
                          content: content,
                          priority: _isImportant ? '중요' : '보통',
                        );

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
      ),
    );
  }
}