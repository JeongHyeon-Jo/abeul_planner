// calendar_task_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/utils/priority_icon.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/calendar_task_model.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/widget/calendar_delete_dialog.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/provider/calendar_task_provider.dart';

class CalendarTaskDialog extends ConsumerStatefulWidget {
  final CalendarTaskModel? existingTask;
  final int? index;
  final DateTime selectedDate;

  const CalendarTaskDialog({
    super.key,
    this.existingTask,
    this.index,
    required this.selectedDate,
  });

  @override
  ConsumerState<CalendarTaskDialog> createState() => _CalendarTaskDialogState();
}

class _CalendarTaskDialogState extends ConsumerState<CalendarTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _memoController = TextEditingController();
  late DateTime _selectedDate;
  DateTime? _endDate;
  bool _isSecret = false;
  int? _selectedColorValue;
  String _selectedRepeat = '반복 없음';
  String _selectedPriority = '보통';

  final List<String> _repeatOptions = ['반복 없음', '매주', '매월', '매년'];
  final List<String> _priorityOptions = ['낮음', '보통', '중요'];

  final List<Color> _colorOptions = [
    AppColors.accent.withAlpha((0.15 * 255).toInt()),
    Colors.green.withAlpha((0.15 * 255).toInt()),
    Colors.orange.withAlpha((0.15 * 255).toInt()),
    Colors.purple.withAlpha((0.15 * 255).toInt()),
    Colors.blue.withAlpha((0.15 * 255).toInt()),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.existingTask?.date ?? widget.selectedDate;
    _memoController.text = widget.existingTask?.memo ?? '';
    _selectedRepeat = widget.existingTask?.repeat ?? '반복 없음';
    _selectedPriority = widget.existingTask?.priority ?? '보통';
    _endDate = widget.existingTask?.endDate;
    _isSecret = widget.existingTask?.secret ?? false;
    _selectedColorValue = widget.existingTask?.colorValue ?? _colorOptions.first.value;
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newTask = CalendarTaskModel(
        memo: _memoController.text.trim(),
        date: _selectedDate,
        repeat: _selectedRepeat,
        priority: _selectedPriority,
        endDate: _endDate,
        secret: _isSecret,
        colorValue: _selectedColorValue,
      );

      if (widget.existingTask == null) {
        ref.read(calendarTaskProvider.notifier).addTask(newTask);
      } else {
        ref.read(calendarTaskProvider.notifier).deleteSpecificTask(widget.existingTask!);
        ref.read(calendarTaskProvider.notifier).addTask(newTask);
      }

      Navigator.of(context).pop();
    }
  }

  void _delete() {
    if (widget.existingTask != null) {
      ref.read(calendarTaskProvider.notifier).deleteSpecificTask(widget.existingTask!);
      Navigator.of(context).pop();
    }
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isEditMode ? '일정 수정' : '새 일정 추가',
                        style: AppTextStyles.title,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _isSecret = !_isSecret),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: AppColors.lightPrimary,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                        ),
                        child: Icon(
                          _isSecret ? Icons.lock : Icons.lock_open,
                          color: _isSecret ? AppColors.accent : AppColors.subText,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                _buildDateField(label: '날짜', date: _selectedDate, onPick: (picked) => setState(() => _selectedDate = picked)),
                SizedBox(height: 12.h),

                _buildDateField(
                  label: '종료일 (선택)',
                  date: _endDate,
                  onPick: (picked) => setState(() => _endDate = picked),
                  firstDate: _selectedDate,
                ),
                SizedBox(height: 12.h),

                if (!isEditMode)
                  DropdownButtonFormField<String>(
                    value: _selectedRepeat,
                    items: _repeatOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setState(() => _selectedRepeat = val!),
                    decoration: const InputDecoration(labelText: '반복 설정'),
                  ),
                SizedBox(height: 12.h),

                DropdownButtonFormField<String>(
                  value: _selectedPriority,
                  items: _priorityOptions.map((e) => DropdownMenuItem(
                    value: e,
                    child: Row(children: [getPriorityIcon(e), SizedBox(width: 8.w), Text(e)]),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedPriority = val!),
                  decoration: const InputDecoration(labelText: '중요도'),
                ),
                SizedBox(height: 12.h),

                Row(
                  children: [
                    Text('색상 선택', style: AppTextStyles.body),
                    SizedBox(width: 12.w),
                    Wrap(
                      spacing: 8.w,
                      children: _colorOptions.map((color) {
                        final isSelected = _selectedColorValue == color.value;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColorValue = color.value),
                          child: Container(
                            width: 24.w,
                            height: 24.w,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected ? Border.all(color: AppColors.primary, width: 2.w) : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                TextFormField(
                  controller: _memoController,
                  decoration: const InputDecoration(labelText: '일정 내용'),
                  validator: (val) => (val == null || val.isEmpty) ? '일정 내용을 입력하세요' : null,
                ),

                if (isEditMode)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 8.w,
                      children: [
                        TextButton(
                          onPressed: () => _showDeleteDialog(
                            title: '일정 삭제',
                            description: '해당 일정을 정말 삭제하시겠습니까?',
                            onConfirm: _delete,
                          ),
                          child: Text('일정 삭제', style: TextStyle(color: Colors.red, fontSize: 13.sp)),
                        ),
                        if (["매주", "매월", "매년"].contains(widget.existingTask?.repeat))
                          TextButton(
                            onPressed: () => _showDeleteDialog(
                              title: '반복 일정 전체 삭제',
                              description: '이 반복 일정에 해당하는 모든 일정을 삭제할까요?',
                              onConfirm: () {
                                ref.read(calendarTaskProvider.notifier)
                                  .deleteAllTasksWithRepeatId(widget.existingTask!.repeatId!);
                                Navigator.of(context).pop();
                              },
                            ),
                            child: Text('반복 일정 전체 삭제', style: TextStyle(color: Colors.red, fontSize: 13.sp)),
                          ),
                      ],
                    ),
                  ),
                SizedBox(height: 16.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('취소', style: AppTextStyles.body),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton(
                      onPressed: _submit,
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
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    DateTime? date,
    required void Function(DateTime picked) onPick,
    DateTime? firstDate,
  }) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(
        text: date != null ? DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(date) : '',
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(2000),
          lastDate: DateTime(2100),
          locale: const Locale('ko', 'KR'),
        );
        if (picked != null) {
          onPick(picked);
        }
      },
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
    );
  }

  void _showDeleteDialog({
    required String title,
    required String description,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => CalendarDeleteDialog(
        title: title,
        description: description,
        onConfirm: onConfirm,
      ),
    );
  }
}
