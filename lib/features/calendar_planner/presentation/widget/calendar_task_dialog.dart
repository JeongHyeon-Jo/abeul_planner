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
  bool _isImportant = false;
  int? _selectedColorValue;
  String _selectedRepeat = '반복 없음';

  final List<String> _repeatOptions = ['반복 없음', '매주', '매월', '매년'];

  final List<Color> _colorStorageColors = [
    AppColors.accent.withAlpha((0.15 * 255).toInt()),
    Colors.green.withAlpha((0.15 * 255).toInt()),
    Colors.orange.withAlpha((0.15 * 255).toInt()),
    Colors.purple.withAlpha((0.15 * 255).toInt()),
    Colors.blue.withAlpha((0.15 * 255).toInt()),
  ];

  final List<Color> _colorDisplayColors = [
    AppColors.accent.withAlpha((0.4 * 255).toInt()),
    Colors.green.withAlpha((0.4 * 255).toInt()),
    Colors.orange.withAlpha((0.4 * 255).toInt()),
    Colors.purple.withAlpha((0.4 * 255).toInt()),
    Colors.blue.withAlpha((0.4 * 255).toInt()),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.existingTask?.date ?? widget.selectedDate;
    _memoController.text = widget.existingTask?.memo ?? '';
    _selectedRepeat = widget.existingTask?.repeat ?? '반복 없음';
    _isSecret = widget.existingTask?.secret ?? false;
    _selectedColorValue = widget.existingTask?.colorValue ?? _colorStorageColors.first.value;
    _isImportant = widget.existingTask?.priority == '중요';
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
        priority: _isImportant ? '중요' : '보통',
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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Dialog(
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            isEditMode ? '일정 수정' : '새 일정 추가',
                            style: AppTextStyles.title,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _isSecret = !_isSecret),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: _isSecret ? AppColors.accent : AppColors.divider,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isSecret ? Icons.lock : Icons.lock_open,
                            color: _isSecret ? AppColors.accent : AppColors.subText,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  _buildDateField('날짜', _selectedDate, (picked) => setState(() => _selectedDate = picked)),
                  SizedBox(height: 12.h),

                  _buildDateField('종료일 (선택)', _endDate, (picked) => setState(() => _endDate = picked), firstDate: _selectedDate),
                  SizedBox(height: 12.h),

                  TextFormField(
                    controller: _memoController,
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
                    validator: (val) => (val == null || val.isEmpty) ? '일정 내용을 입력하세요' : null,
                  ),
                  SizedBox(height: 16.h),

                  if (!isEditMode) ... [
                    DropdownButtonFormField<String>(
                      value: _selectedRepeat,
                      items: _repeatOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setState(() => _selectedRepeat = val!),
                      decoration: InputDecoration(
                        labelText: '반복 설정',
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
                  ],
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

                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      border: Border.all(color: AppColors.primary, width: 2.w),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('색상 선택', style: AppTextStyles.body),
                        Spacer(),
                        Wrap(
                          spacing: 8.w,
                          children: List.generate(_colorStorageColors.length, (index) {
                            final bool isSelected = _selectedColorValue == _colorStorageColors[index].value;

                            return GestureDetector(
                              onTap: () => setState(() => _selectedColorValue = _colorStorageColors[index].value),
                              child: Container(
                                width: 28.w,
                                height: 28.w,
                                decoration: BoxDecoration(
                                  color: _colorDisplayColors[index],
                                  shape: BoxShape.circle,
                                  border: isSelected
                                      ? Border.all(color: AppColors.primary, width: 2.w)
                                      : null,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  if (isEditMode)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (["매주", "매월", "매년"].contains(widget.existingTask?.repeat))
                            ElevatedButton(
                              onPressed: () => _showDeleteDialog(
                                title: '반복 일정 전체 삭제',
                                description: '이 반복 일정에 해당하는 모든 일정을 삭제할까요?',
                                onConfirm: () {
                                  ref.read(calendarTaskProvider.notifier)
                                      .deleteAllTasksWithRepeatId(widget.existingTask!.repeatId!);
                                  Navigator.of(context).pop();
                                },
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text('반복 일정 전체 삭제'),
                            ),
                          SizedBox(width: 8.w),
                          ElevatedButton(
                            onPressed: () => _showDeleteDialog(
                              title: '일정 삭제',
                              description: '해당 일정을 정말 삭제하시겠습니까?',
                              onConfirm: _delete,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text('일정 삭제'),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 16.h),

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
                        onPressed: _submit,
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
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, Function(DateTime) onPick, {DateTime? firstDate}) {
    final controller = TextEditingController(
      text: date != null ? DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(date) : '',
    );

    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(2000),
          lastDate: DateTime(2100),
          locale: const Locale('ko', 'KR'),
        );
        if (picked != null) onPick(picked);
      },
      decoration: InputDecoration(
        labelText: label,
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
