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
  final String day; // 현재 요일
  final bool isEditing; // 편집 모드 여부
  final String filterPriority; // 중요도 필터 값

  const WeeklyTabContent({super.key, required this.day, required this.isEditing, required this.filterPriority});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 해당 요일의 일정 모델 가져오기 (없으면 빈 모델 생성)
    final weekTask = ref.watch(weeklyTaskProvider)
        .firstWhere((t) => t.day == day, orElse: () => WeeklyTaskModel(day: day, theme: '', tasks: []));

    // 중요도 필터 적용된 일정 목록 생성
    final filteredTasks = filterPriority == '전체'
        ? weekTask.tasks
        : weekTask.tasks.where((task) => task.priority == filterPriority).toList();

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 테마 입력/출력 영역
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

            // 일정 리스트 영역
            Expanded(
              child: WeeklyTaskList(
                day: day,
                tasks: filteredTasks,
                isEditing: isEditing,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
