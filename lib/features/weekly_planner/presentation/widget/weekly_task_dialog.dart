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
  final List<String> days; // 요일 리스트
  final void Function(String selectedDay) onTaskAdded; // 일정 추가 콜백
  final WeeklyTask? existingTask; // 수정할 기존 일정
  final int? editingIndex; // 수정할 일정의 인덱스
  final String? editingDay; // 수정할 요일

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
  final TextEditingController _contentController = TextEditingController(); // 일정 내용 입력 컨트롤러
  String _selectedDay = '월'; // 선택된 요일
  String _priority = '보통'; // 선택된 중요도
  final List<String> _priorityKeys = ['낮음', '보통', '중요']; // 중요도 목록

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.editingDay ?? widget.days.first; // 수정 모드이면 해당 요일으로 초기화
    _contentController.text = widget.existingTask?.content ?? ''; // 수정 모드이면 내용 채우기
    _priority = widget.existingTask?.priority ?? '보통'; // 수정 모드이면 중요도 설정
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.existingTask != null; // 수정 모드 여부 판단

    return AlertDialog(
      title: Text(isEditMode ? '일정 수정' : '일정 추가', style: AppTextStyles.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 요일 선택
          DropdownButtonFormField<String>(
            value: _selectedDay,
            items: widget.days
                .map((day) => DropdownMenuItem(
                      value: day,
                      child: Text(day, style: AppTextStyles.body),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedDay = value);
            },
            decoration: const InputDecoration(labelText: '요일 선택'),
          ),
          SizedBox(height: 8.h),

          // 일정 내용 입력
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(labelText: '일정 내용'),
          ),
          SizedBox(height: 8.h),

          // 중요도 선택
          DropdownButtonFormField<String>(
            value: _priority,
            items: _priorityKeys.map((level) {
              return DropdownMenuItem(
                value: level,
                child: Row(
                  children: [
                    getPriorityIcon(level), // 중요도 아이콘 추가
                    SizedBox(width: 8.w),
                    Text(level, style: AppTextStyles.body),
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
        ],
      ),
      actions: [
        // 취소 버튼
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('취소', style: AppTextStyles.body.copyWith(color: AppColors.subText)),
        ),

        // 저장 버튼 (추가 또는 수정)
        ElevatedButton(
          onPressed: () {
            final content = _contentController.text.trim();
            if (content.isEmpty) return;

            final newTask = WeeklyTask(content: content, priority: _priority);

            if (isEditMode && widget.editingIndex != null && widget.editingDay != null) {
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
          child: Text('저장', style: AppTextStyles.button),
        ),
      ],
    );
  }
}
