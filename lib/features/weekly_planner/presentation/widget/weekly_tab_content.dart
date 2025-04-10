// weekly_tab_content.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WeeklyTabContent extends StatefulWidget {
  final String day;

  const WeeklyTabContent({super.key, required this.day});

  @override
  State<WeeklyTabContent> createState() => _WeeklyTabContentState();
}

class _WeeklyTabContentState extends State<WeeklyTabContent> {
  final TextEditingController _themeController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();

  List<String> tasks = [];

  @override
  void dispose() {
    _themeController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  void _addTask() {
    final text = _taskController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        tasks.add(text);
        _taskController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 요일 테마 입력
          TextField(
            controller: _themeController,
            decoration: InputDecoration(
              labelText: '오늘은 어떤 날인가요?',
              hintText: '예: 휴식의 날, 집중의 날 등',
              border: const OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16.h),

          // 할 일 입력창 + 추가 버튼
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _taskController,
                  decoration: const InputDecoration(
                    hintText: '할 일을 입력하세요',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              ElevatedButton(
                onPressed: _addTask,
                child: const Text('추가'),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // 할 일 목록
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(tasks[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
