// daily_section.dart
import 'package:flutter/material.dart';
import 'package:abeul_planner/core/text_styles.dart';
import 'package:abeul_planner/features/daily_planner/data/model/daily_task_model.dart';

class DailySection extends StatelessWidget {
  final List<DailyTaskModel> dailyTasks;

  const DailySection({super.key, required this.dailyTasks});

  @override
  Widget build(BuildContext context) {
    if (dailyTasks.isEmpty) {
      return Text('일상 기록이 없습니다.', style: AppTextStyles.body);
    }

    return Column(
      children: dailyTasks
          .map((t) => Card(
                child: ListTile(
                  leading: const Icon(Icons.check),
                  title: Text(t.situation, style: AppTextStyles.body),
                  subtitle: Text(t.action, style: AppTextStyles.caption),
                ),
              ))
          .toList(),
    );
  }
}