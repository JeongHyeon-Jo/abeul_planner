// weekly_tab_content.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/color.dart';
import 'package:abeul_planner/core/text_styles.dart';
import 'package:abeul_planner/features/weekly_planner/data/model/weekly_task_model.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/provider/weekly_task_provider.dart';

/// 요일별 탭에 보여질 개별 플래너 콘텐츠 위젯
/// - 각 요일별 테마와 할 일 목록을 표시/편집할 수 있음
/// - 할 일 추가는 상위에서 관리됨
class WeeklyTabContent extends ConsumerWidget {
  final String day; // 해당 요일 ('월', '화' 등)
  final bool isEditing; // 상위에서 전달된 편집 모드 여부

  const WeeklyTabContent({super.key, required this.day, required this.isEditing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 요일에 해당하는 주간 플래너 상태 불러오기
    final weekTask = ref.watch(weeklyTaskProvider)
        .firstWhere((t) => t.day == day, orElse: () => WeeklyTaskModel(day: day, theme: '', tasks: []));

    // 테마 입력을 위한 컨트롤러 (초기값은 기존 테마)
    final themeController = TextEditingController(text: weekTask.theme);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 편집 모드일 경우 테마 입력 필드, 아닐 경우 텍스트 출력
            isEditing
                ? TextField(
                    controller: themeController,
                    decoration: InputDecoration(
                      hintText: '$day요일의 테마를 정해보세요.',
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      ref.read(weeklyTaskProvider.notifier).setTheme(day, value);
                    },
                  )
                : Text(
                    weekTask.theme.isEmpty
                        ? '$day요일의 테마를 정해보세요.'
                        : weekTask.theme,
                    style: AppTextStyles.body,
                  ),
            SizedBox(height: 16.h),

            // 할 일 목록 표시
            Expanded(
              child: weekTask.tasks.isEmpty
                  ? Center(child: Text('등록된 할 일이 없어요.', style: AppTextStyles.body))
                  : ListView.builder(
                      itemCount: weekTask.tasks.length,
                      itemBuilder: (context, index) {
                        final t = weekTask.tasks[index];
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 6.h),
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.divider),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              // 중요도에 따른 아이콘 출력
                              Icon(
                                t.priority == '중요'
                                    ? Icons.priority_high
                                    : t.priority == '보통'
                                        ? Icons.circle
                                        : Icons.arrow_downward,
                                color: t.priority == '중요'
                                    ? Colors.red
                                    : t.priority == '보통'
                                        ? Colors.orange
                                        : Colors.grey,
                                size: 20.sp,
                              ),
                              SizedBox(width: 12.w),
                              // 할 일 내용
                              Expanded(
                                child: Text(t.content, style: AppTextStyles.body),
                              ),
                              // 완료 여부 체크박스
                              Checkbox(
                                value: t.isCompleted,
                                onChanged: (_) {
                                  ref.read(weeklyTaskProvider.notifier).toggleTask(day, index);
                                },
                              ),
                            ],
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