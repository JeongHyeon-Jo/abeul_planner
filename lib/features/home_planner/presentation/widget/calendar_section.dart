// calendar_section.dart
import 'package:flutter/material.dart';
import 'package:abeul_planner/core/text_styles.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/calendar_task_model.dart';

class CalendarSection extends StatelessWidget {
  final DateTime now;
  final List<CalendarTaskModel> calendarTasks;

  const CalendarSection({super.key, required this.now, required this.calendarTasks});

  @override
  Widget build(BuildContext context) {
    final todayTasks = calendarTasks.where(
      (task) => task.date.year == now.year &&
                task.date.month == now.month &&
                task.date.day == now.day,
    );

    if (todayTasks.isEmpty) {
      return Text('오늘 일정이 없습니다.', style: AppTextStyles.body);
    }

    return Column(
      children: todayTasks
          .map((task) => Card(
                child: ListTile(
                  title: Text(task.memo, style: AppTextStyles.body),
                  subtitle: Text(task.time, style: AppTextStyles.caption),
                ),
              ))
          .toList(),
    );
  }
}