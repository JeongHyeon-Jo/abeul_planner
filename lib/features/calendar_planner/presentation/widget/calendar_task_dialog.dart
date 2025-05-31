// calendar_task_dialog.dart
import 'package:abeul_planner/core/utils/priority_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/calendar_task_model.dart';
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
  String _selectedRepeat = '반복 없음';
  String _selectedPriority = '보통';

  final List<String> _repeatOptions = ['반복 없음','매주', '매월','매년'];
  final List<String> _priorityOptions = ['낮음', '보통', '중요'];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.existingTask?.date ?? widget.selectedDate;
    _memoController.text = widget.existingTask?.memo ?? '';
    _selectedRepeat = widget.existingTask?.repeat ?? '반복 없음';
    _selectedPriority = widget.existingTask?.priority ?? '보통';
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
                Text(isEditMode ? '일정 수정' : '새 일정 추가', style: AppTextStyles.title),
                SizedBox(height: 16.h),

                // 날짜 선택
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: DateFormat('yyyy년 MM월 dd일').format(_selectedDate),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      locale: const Locale('ko', 'KR'),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: '날짜',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
                SizedBox(height: 12.h),

                // 반복 설정
                DropdownButtonFormField<String>(
                  value: _selectedRepeat,
                  items: _repeatOptions.map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedRepeat = val!),
                  decoration: const InputDecoration(labelText: '반복 설정'),
                ),
                SizedBox(height: 12.h),

                // 중요도
                DropdownButtonFormField<String>(
                  value: _selectedPriority,
                  items: _priorityOptions.map((e) => DropdownMenuItem(
                    value: e,
                    child: Row(
                      children: [
                        getPriorityIcon(e),
                        SizedBox(width: 8.w),
                        Text(e),
                      ],
                    ),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedPriority = val!),
                  decoration: const InputDecoration(labelText: '중요도'),
                ),
                SizedBox(height: 12.h),

                // 메모 입력
                TextFormField(
                  controller: _memoController,
                  decoration: const InputDecoration(labelText: '일정 내용'),
                  validator: (val) =>
                      (val == null || val.isEmpty) ? '일정 내용을 입력하세요' : null,
                ),
                if (isEditMode)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 8.w,
                      children: [
                        // 개별 삭제 버튼
                        TextButton(
                          onPressed: _delete,
                          child: Text('일정 삭제',
                              style: AppTextStyles.caption.copyWith(color: Colors.red)),
                        ),
                        // 반복 일정 삭제 버튼 (매주, 매월, 매년 중 하나일 때만 표시)
                        if (['매주', '매월', '매년'].contains(widget.existingTask?.repeat))
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(calendarTaskProvider.notifier)
                                  .deleteAllTasksWithRepeatId(widget.existingTask!.repeatId!);
                              Navigator.of(context).pop();
                            },
                            child: Text('반복 일정 전체 삭제',
                                style: AppTextStyles.caption.copyWith(color: Colors.red)),
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
}
