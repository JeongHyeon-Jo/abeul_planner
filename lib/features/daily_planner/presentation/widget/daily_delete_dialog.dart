// delete_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/features/daily_planner/presentation/provider/daily_task_provider.dart';

/// 플랜 제거 확인 다이얼로그
class DailyDeleteDialog extends ConsumerWidget {
  final int index; // 삭제할 인덱스

  const DailyDeleteDialog({super.key, required this.index});

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
            ref.read(dailyTaskProvider.notifier).removeTask(index);
            Navigator.of(context).pop();
          },
          child: Text('제거', style: AppTextStyles.button),
        ),
      ],
    );
  }
}