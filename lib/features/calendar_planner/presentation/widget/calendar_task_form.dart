// calendar_task_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/provider/calendar_task_provider.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/calendar_task_model.dart';

class CalendarTaskForm extends ConsumerStatefulWidget {
  final DateTime selectedDate;

  const CalendarTaskForm({super.key, required this.selectedDate});

  @override
  ConsumerState<CalendarTaskForm> createState() => _CalendarTaskFormState();
}

class _CalendarTaskFormState extends ConsumerState<CalendarTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  TimeOfDay? _selectedTime;

  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedTime != null) {
      final newTask = CalendarTaskModel(
        date: widget.selectedDate,
        time: _selectedTime!.format(context),
        memo: _memoController.text.trim(),
      );

      ref.read(calendarTaskProvider.notifier).addTask(newTask);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _timeController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('yyyy년 MM월 dd일').format(widget.selectedDate);

    return AlertDialog(
      title: Text('$dateFormatted 일정 추가'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 시간 선택 필드
            TextFormField(
              controller: _timeController,
              readOnly: true,
              onTap: _pickTime,
              decoration: const InputDecoration(
                labelText: '시간 선택',
                suffixIcon: Icon(Icons.access_time),
              ),
              validator: (value) => value == null || value.isEmpty ? '시간을 선택하세요' : null,
            ),
            const SizedBox(height: 12),
            // 메모 입력 필드
            TextFormField(
              controller: _memoController,
              decoration: const InputDecoration(
                labelText: '메모',
              ),
              validator: (value) => value == null || value.isEmpty ? '메모를 입력하세요' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('추가'),
        ),
      ],
    );
  }
}
