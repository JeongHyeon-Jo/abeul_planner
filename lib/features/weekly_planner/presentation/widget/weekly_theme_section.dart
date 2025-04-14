// weekly_theme_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/color.dart';
import 'package:abeul_planner/core/text_styles.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/provider/weekly_task_provider.dart';

/// 요일별 테마를 입력하거나 출력하는 위젯
class WeeklyThemeSection extends ConsumerWidget {
  final String day;
  final String theme;
  final bool isEditing;

  const WeeklyThemeSection({super.key, required this.day, required this.theme, required this.isEditing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeController = TextEditingController(text: theme);

    return isEditing
        ? TextField(
            controller: themeController,
            decoration: InputDecoration(
              hintText: '$day요일의 테마를 정해보세요.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            style: AppTextStyles.body,
            onSubmitted: (value) {
              ref.read(weeklyTaskProvider.notifier).setTheme(day, value);
            },
          )
        : Text(
            theme.isEmpty ? '$day요일의 테마를 정해보세요.' : theme,
            style: AppTextStyles.body,
          );
  }
}
