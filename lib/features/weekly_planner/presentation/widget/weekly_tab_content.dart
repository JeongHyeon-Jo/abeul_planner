// weekly_tab_content.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/features/weekly_planner/data/model/weekly_task_model.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/provider/weekly_task_provider.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/widget/weekly_theme_section.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/widget/weekly_task_list.dart';
import 'package:abeul_planner/core/color.dart';

/// 요일별 탭에 보여질 개별 플래너 콘텐츠 위젯
class WeeklyTabContent extends ConsumerWidget {
  final String day;
  final bool isEditing;

  const WeeklyTabContent({super.key, required this.day, required this.isEditing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekTask = ref.watch(weeklyTaskProvider)
        .firstWhere((t) => t.day == day, orElse: () => WeeklyTaskModel(day: day, theme: '', tasks: []));

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 테마 영역 위젯 분리
            WeeklyThemeSection(
              day: day,
              theme: weekTask.theme,
              isEditing: isEditing,
            ),
            SizedBox(height: 12.h),

            // 구분선
            Container(
              width: 1.sw,
              height: 1.h,
              color: AppColors.primary,
            ),
            SizedBox(height: 12.h),

            // 할 일 목록 위젯 분리
            Expanded(
              child: WeeklyTaskList(day: day, tasks: weekTask.tasks),
            ),
          ],
        ),
      ),
    );
  }
}