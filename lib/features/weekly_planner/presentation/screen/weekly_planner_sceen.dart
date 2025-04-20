// weekly_planner_screen.dart
// 주간 플래너 화면: 요일별 할 일 목록과 테마를 관리하는 UI

import 'package:flutter/material.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/core/text_styles.dart';
import 'package:abeul_planner/core/color.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/widget/weekly_task_dialog.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/widget/weekly_theme_section.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/widget/weekly_task_list.dart';
import 'package:abeul_planner/core/widgets/priority_icon.dart';
import 'package:abeul_planner/features/weekly_planner/data/model/weekly_task_model.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/provider/weekly_task_provider.dart';

class WeeklyPlannerScreen extends ConsumerStatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  ConsumerState<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends ConsumerState<WeeklyPlannerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final List<String> days = ['월', '화', '수', '목', '금', '토', '일'];
  final List<String> _priorities = ['전체', '낮음', '보통', '중요'];
  bool _isEditing = false; // 편집 모드 여부
  String _filterPriority = '전체'; // 필터링할 중요도

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final weekday = now.weekday;
    final todayIndex = (weekday - 1).clamp(0, 6); // 월(1) ~ 일(7) → 0~6 인덱스로 변환
    _tabController = TabController(length: days.length, vsync: this, initialIndex: todayIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 일정 추가 다이얼로그
  void _showAddTaskDialog(BuildContext context) {
    final currentDay = days[_tabController.index];
    showDialog(
      context: context,
      builder: (context) => WeeklyTaskDialog(
        days: days,
        onTaskAdded: (selectedDay) {
          setState(() {
            _tabController.index = days.indexOf(selectedDay);
          });
        },
        editingDay: currentDay,
      ),
    );
  }

  /// 중요도 필터 다이얼로그
  void _showPriorityFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _priorities.map((priority) {
            return ListTile(
              leading: priority == '전체'
                  ? const Icon(Icons.close, color: AppColors.subText)
                  : getPriorityIcon(priority),
              title: Text(priority == '전체' ? '전체 보기' : '중요도: $priority'),
              onTap: () {
                setState(() => _filterPriority = priority);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: days.length,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight + 48.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 커스텀 앱바 (필터 및 편집 모드 토글)
              CustomAppBar(
                title: _filterPriority == '전체'
                    ? Text('', style: AppTextStyles.title)
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          getPriorityIcon(_filterPriority),
                          SizedBox(width: 6.w),
                          Text('중요도: $_filterPriority', style: AppTextStyles.title.copyWith(color: AppColors.text)),
                          SizedBox(width: 8.w),
                          GestureDetector(
                            onTap: () => setState(() => _filterPriority = '전체'),
                            child: Icon(Icons.close, size: 20.sp, color: AppColors.subText),
                          ),
                        ],
                      ),
                isTransparent: true,
                leading: IconButton(
                  icon: Icon(Icons.filter_list, color: AppColors.text, size: 27.sp),
                  onPressed: _showPriorityFilterDialog,
                  tooltip: '중요도 필터',
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _isEditing ? Icons.check : Icons.edit,
                      color: _isEditing ? AppColors.success : AppColors.text,
                      size: 27.sp,
                    ),
                    onPressed: () => setState(() => _isEditing = !_isEditing),
                  ),
                ],
              ),
              // 요일 탭바
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4.r,
                        offset: Offset(0, 2.h),
                      )
                    ],
                    border: Border.all(color: AppColors.primary, width: 1.w),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(width: 3.h, color: AppColors.highlight),
                      insets: EdgeInsets.symmetric(horizontal: 8.w),
                    ),
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: AppColors.text,
                    unselectedLabelColor: AppColors.subText,
                    labelStyle: AppTextStyles.body,
                    tabs: List.generate(days.length, (index) {
                      return Container(
                        alignment: Alignment.center,
                        child: Text(days[index], style: AppTextStyles.body),
                      );
                    }),
                    dividerColor: Colors.transparent,
                    indicatorPadding: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    labelPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        // 추가 버튼
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddTaskDialog(context),
          backgroundColor: AppColors.accent,
          child: Icon(Icons.add, size: 24.sp),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4.r,
                  offset: Offset(0, 2.h),
                ),
              ],
              border: Border.all(color: AppColors.primary, width: 1.w),
            ),
            // 요일별 탭 화면 콘텐츠
            child: TabBarView(
              controller: _tabController,
              children: days.map((day) {
                final weekTask = ref.watch(weeklyTaskProvider)
                    .firstWhere((t) => t.day == day, orElse: () => WeeklyTaskModel(day: day, theme: '', tasks: []));

                final filteredTasks = _filterPriority == '전체'
                    ? weekTask.tasks
                    : weekTask.tasks.where((task) => task.priority == _filterPriority).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 테마 입력/출력 영역
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      child: WeeklyThemeSection(
                        day: day,
                        theme: weekTask.theme,
                        isEditing: _isEditing,
                      ),
                    ),
                    // 구분선
                    const Divider(height: 1, thickness: 1, color: AppColors.primary),
                    // 할 일 목록 영역
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: WeeklyTaskList(
                          day: day,
                          tasks: filteredTasks,
                          isEditing: _isEditing,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}