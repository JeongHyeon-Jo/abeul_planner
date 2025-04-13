// weekly_tab_content.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/color.dart';
import 'package:abeul_planner/core/text_styles.dart';
import 'package:abeul_planner/features/weekly_planner/data/model/weekly_task_model.dart';

class WeeklyTabContent extends StatefulWidget {
  final String day;

  const WeeklyTabContent({super.key, required this.day});

  @override
  State<WeeklyTabContent> createState() => _WeeklyTabContentState();
}

class _WeeklyTabContentState extends State<WeeklyTabContent> {
  final TextEditingController _themeController = TextEditingController();
  final List<WeeklyTask> task = [];

  String _selectedPriority = '보통';
  final List<String> _priorityKeys = ['낮음', '보통', '중요'];

  Icon _getPriorityIcon(String priority) {
    switch (priority) {
      case '중요':
        return Icon(Icons.priority_high, color: Colors.red, size: 20.sp);
      case '보통':
        return Icon(Icons.circle, color: Colors.orange, size: 14.sp);
      case '낮음':
      default:
        return Icon(Icons.arrow_downward, color: Colors.grey, size: 14.sp);
    }
  }

  void _showAddTaskDialog() {
    final TextEditingController _contentController = TextEditingController();
    String priority = '보통';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('할 일 추가', style: AppTextStyles.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: '할 일 내용'),
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<String>(
                value: priority,
                items: _priorityKeys.map((level) => DropdownMenuItem(
                  value: level,
                  child: Row(
                    children: [
                      _getPriorityIcon(level),
                      SizedBox(width: 8.w),
                      Text(level, style: AppTextStyles.body),
                    ],
                  ),
                )).toList(),
                onChanged: (value) {
                  if (value != null) priority = value;
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

                setState(() {
                  task.add(WeeklyTask(content: content, priority: priority));
                });
                Navigator.of(context).pop();
              },
              child: Text('추가', style: AppTextStyles.button),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _themeController,
              decoration: InputDecoration(
                labelText: '오늘은 어떤 날인가요?',
                hintText: '예: 휴식의 날, 집중의 날 등',
                border: const OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView.builder(
                itemCount: task.length,
                itemBuilder: (context, index) {
                  final t = task[index];
                  return ListTile(
                    leading: _getPriorityIcon(t.priority),
                    title: Text(t.content, style: AppTextStyles.body),
                    trailing: Checkbox(
                      value: t.isCompleted,
                      onChanged: (value) {
                        setState(() {
                          task[index] = WeeklyTask(
                            content: t.content,
                            priority: t.priority,
                            isCompleted: value ?? false,
                          );
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}