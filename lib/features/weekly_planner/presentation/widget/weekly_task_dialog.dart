// weekly_task_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/text_styles.dart';
import 'package:abeul_planner/core/color.dart';
import 'package:abeul_planner/features/weekly_planner/data/model/weekly_task_model.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/provider/weekly_task_provider.dart';

/// 주간 플래너 할 일 추가 다이얼로그
class WeeklyTaskDialog extends ConsumerStatefulWidget {
  final List<String> days;
  final void Function(String selectedDay) onTaskAdded;

  const WeeklyTaskDialog({super.key, required this.days, required this.onTaskAdded});

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
    _selectedDay = widget.days.first;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('플래너 추가', style: AppTextStyles.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(labelText: '할 일 내용'),
          ),
          SizedBox(height: 8.h),
          DropdownButtonFormField<String>(
            value: _priority,
            items: _priorityKeys
                .map((level) => DropdownMenuItem(
                      value: level,
                      child: Text(level, style: AppTextStyles.body),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _priority = value);
            },
            decoration: const InputDecoration(labelText: '중요도'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('취소', style: AppTextStyles.body.copyWith(color: AppColors.subText)),
        ),
        ElevatedButton(
          onPressed: () {
            final content = _contentController.text.trim();
            if (content.isEmpty) return;

            ref.read(weeklyTaskProvider.notifier).addTask(
              _selectedDay,
              WeeklyTask(content: content, priority: _priority),
            );

            Navigator.of(context).pop();
            widget.onTaskAdded(_selectedDay);
          },
          child: Text('추가', style: AppTextStyles.button),
        ),
      ],
    );
  }
}
