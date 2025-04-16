// weekly_planner_screen.dart
import 'package:flutter/material.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/core/text_styles.dart';
import 'package:abeul_planner/core/color.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/widget/weekly_tab_content.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/widget/weekly_task_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 주간 플래너 메인 화면
/// - 요일별 탭(TabBar) 구성
/// - FloatingActionButton을 통해 할 일 추가
/// - 편집 버튼을 통해 테마 수정 가능
class WeeklyPlannerScreen extends ConsumerStatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  ConsumerState<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends ConsumerState<WeeklyPlannerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final List<String> days = ['월', '화', '수', '목', '금', '토', '일']; // 요일 목록
  bool _isEditing = false; // 편집 모드 여부

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: days.length, vsync: this); // 탭 컨트롤러 초기화
  }

  @override
  void dispose() {
    _tabController.dispose(); // 탭 컨트롤러 해제
    super.dispose();
  }

  /// 할 일 추가 다이얼로그 표시
  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => WeeklyTaskDialog(
        days: days,
        onTaskAdded: (selectedDay) {
          setState(() {
            _tabController.index = days.indexOf(selectedDay); // 선택된 요일 탭으로 이동
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: days.length,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight + 48.h), // AppBar 높이 설정
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상단 커스텀 앱바
              CustomAppBar(
                title: Text(
                  '주간 플래너',
                  style: AppTextStyles.title.copyWith(color: AppColors.text),
                ),
                isTransparent: true,
                actions: [
                  // 편집 모드 토글 버튼
                  TextButton(
                    onPressed: () => setState(() => _isEditing = !_isEditing),
                    child: Text(
                      _isEditing ? '완료' : '편집',
                      style: AppTextStyles.body.copyWith(color: AppColors.text),
                    ),
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
                      borderSide: BorderSide(width: 3.h, color: AppColors.highlight), // 선택 탭 인디케이터 스타일
                      insets: EdgeInsets.symmetric(horizontal: 8.w),
                    ),
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: AppColors.text,
                    unselectedLabelColor: AppColors.subText,
                    labelStyle: AppTextStyles.body,
                    tabs: List.generate(days.length, (index) {
                      return Container(
                        alignment: Alignment.center,
                        child: Text(days[index], style: AppTextStyles.body), // 요일 이름 표시
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
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddTaskDialog(context), // 플랜 추가 버튼
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
            child: TabBarView(
              controller: _tabController,
              children: days.map((day) {
                return WeeklyTabContent(day: day, isEditing: _isEditing); // 각 요일에 해당하는 할 일 목록
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
