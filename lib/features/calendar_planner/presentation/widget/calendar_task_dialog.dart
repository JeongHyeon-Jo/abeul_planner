// calendar_task_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/utils/priority_icon.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/calendar_task_model.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/provider/calendar_task_provider.dart';

class CalendarTaskDialog extends ConsumerStatefulWidget {
  final CalendarTaskModel? existingTask; // 수정 모드일 경우 넘겨줄 기존 데이터
  final int? index; // 수정 모드일 경우 넘겨줄 인덱스
  final DateTime selectedDate; // 기본 선택 날짜

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
  final TextEditingController _memoController = TextEditingController();
  late DateTime _selectedDate; // 선택된 날짜
  String _selectedRepeat = '반복 없음'; // 반복 설정
  String _selectedPriority = '보통'; // 선택된 중요도

  final List<String> _repeatOptions = ['반복 없음', '매일', '매주', '매월', '매년']; // 반복 옵션 리스트
  final List<String> _priorityOptions = ['낮음', '보통', '중요']; // 중요도 옵션 리스트

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

  /// 날짜 선택 다이얼로그
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ko', 'KR'),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// 저장 함수
  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newTask = CalendarTaskModel(
        memo: _memoController.text.trim(),
        date: _selectedDate,
        repeat: _selectedRepeat,
        priority: _selectedPriority, // 중요도 저장
      );

      if (widget.existingTask == null) {
        // 새 일정 추가
        ref.read(calendarTaskProvider.notifier).addTask(newTask);
      } else {
        // 기존 일정 삭제 후 새로 저장 (수정)
        ref.read(calendarTaskProvider.notifier).deleteSpecificTask(widget.existingTask!);
        ref.read(calendarTaskProvider.notifier).addTask(newTask);
      }

      Navigator.of(context).pop();
    }
  }

  /// 삭제 함수
  void _delete() {
    if (widget.existingTask != null) {
      ref.read(calendarTaskProvider.notifier).deleteSpecificTask(widget.existingTask!);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.existingTask != null;

    return AlertDialog(
      title: Text(isEditMode ? '일정 수정' : '새 일정 추가', style: AppTextStyles.title),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 날짜 선택
              TextFormField(
                readOnly: true,
                onTap: _pickDate,
                controller: TextEditingController(
                  text: DateFormat('yyyy년 MM월 dd일').format(_selectedDate),
                ),
                decoration: const InputDecoration(
                  labelText: '날짜',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              SizedBox(height: 12.h),

              // 반복 설정
              DropdownButtonFormField<String>(
                value: _selectedRepeat,
                items: _repeatOptions.map((repeat) {
                  return DropdownMenuItem(
                    value: repeat,
                    child: Text(repeat, style: AppTextStyles.body),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRepeat = value;
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: '반복 설정',
                ),
              ),
              SizedBox(height: 12.h),

              // 중요도 선택 (아이콘 포함)
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                items: _priorityOptions.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Row(
                      children: [
                        getPriorityIcon(priority),
                        SizedBox(width: 8.w),
                        Text(priority, style: AppTextStyles.body),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: '중요도',
                ),
              ),
              SizedBox(height: 12.h),

              // 메모 입력
              TextFormField(
                controller: _memoController,
                decoration: const InputDecoration(
                  labelText: '일정 내용',
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? '일정 내용을 입력하세요' : null,
              ),

              // 삭제 버튼 (수정 모드일 때만 표시)
              if (isEditMode)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _delete,
                    child: Text('일정 삭제',
                        style: AppTextStyles.caption.copyWith(color: Colors.red)),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        // 취소 버튼
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('취소', style: AppTextStyles.body.copyWith(color: AppColors.subText)),
        ),
        // 저장 버튼
        ElevatedButton(
          onPressed: _submit,
          child: Text('저장', style: AppTextStyles.button),
        ),
      ],
    );
  }
}
