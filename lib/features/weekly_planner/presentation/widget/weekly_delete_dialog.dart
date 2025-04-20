// weekly_delete_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/color.dart';
import 'package:abeul_planner/core/text_styles.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/provider/weekly_task_provider.dart';

class WeeklyDeleteDialog extends ConsumerWidget {
  final int index;
  final String day;

  const WeeklyDeleteDialog({super.key, required this.index, required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text('일정 제거', style: AppTextStyles.title),
      content: Text('정말 이 일정을 제거하시겠습니까?', style: AppTextStyles.body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('취소', style: AppTextStyles.body.copyWith(color: AppColors.subText)),
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(weeklyTaskProvider.notifier).removeTask(day, index);
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          child: Text('제거', style: AppTextStyles.button),
        ),
      ],
    );
  }
}
