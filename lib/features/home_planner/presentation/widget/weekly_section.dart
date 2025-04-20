// weekly_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/color.dart';
import 'package:abeul_planner/core/text_styles.dart';
import 'package:abeul_planner/features/weekly_planner/data/model/weekly_task_model.dart';

class WeeklySection extends StatelessWidget {
  final String weekday;
  final List<WeeklyTaskModel> weeklyTasks;

  const WeeklySection({super.key, required this.weekday, required this.weeklyTasks});

  @override
  Widget build(BuildContext context) {
    final todayWeekly = weeklyTasks.where((t) => t.day == weekday);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: todayWeekly.map((t) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...t.tasks.map(
            (task) => Card(
              child: ListTile(
                leading: Icon(
                  task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: task.isCompleted ? AppColors.success : AppColors.subText,
                ),
                title: Text(task.content, style: AppTextStyles.body),
                subtitle: Text('중요도: ${task.priority}', style: AppTextStyles.caption),
              ),
            ),
          )
        ],
      )).toList(),
    );
  }
}