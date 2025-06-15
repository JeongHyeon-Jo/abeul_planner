// weekly_planner_screen.dart
import 'package:flutter/material.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/onboarding/onboarding_mixin.dart';
import 'package:abeul_planner/core/onboarding/onboarding_overlay.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/widget/weekly_task_dialog.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/widget/weekly_task_list.dart';
import 'package:abeul_planner/features/weekly_planner/data/model/weekly_task_model.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/provider/weekly_task_provider.dart';
import 'package:intl/intl.dart';

class WeeklyPlannerScreen extends ConsumerStatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  ConsumerState<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends ConsumerState<WeeklyPlannerScreen>
    with TickerProviderStateMixin, OnboardingMixin {
  late TabController _tabController;
  final List<String> days = ['월', '화', '수', '목', '금', '토', '일'];
  final appBarTitle = DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(DateTime.now());
  bool _isEditing = false;
  int _selectedIndex = 0;

  // 온보딩을 위한 GlobalKey들
  final GlobalKey _tabBarKey = GlobalKey();
  final GlobalKey _editButtonKey = GlobalKey();
  final GlobalKey _fabKey = GlobalKey();

  @override
  String get onboardingKey => 'weekly';

  @override
  List<OnboardingStep> get onboardingSteps => [
    OnboardingStep(
      title: '요일 탭',
      description: '상단의 요일 탭을 눌러\n각 요일별 일정을 확인할 수 있습니다.\n오늘 요일이 기본으로 선택됩니다!',
      targetKey: _tabBarKey,
    ),
    OnboardingStep(
      title: '일정 추가하기',
      description: '우측 하단의 + 버튼을 눌러\n새로운 주간 일정을 추가할 수 있습니다.\n요일별로 반복되는 일정을 계획해보세요!',
      targetKey: _fabKey,
    ),
    OnboardingStep(
      title: '편집 모드',
      description: '우측 상단의 편집 버튼을 눌러\n일정을 수정하거나 삭제할 수 있습니다.\n각 요일별로 일정을 관리해보세요!',
      targetKey: _editButtonKey,
    ),
    const OnboardingStep(
      title: '주간 플래너 완료!',
      description: '이제 요일별로 반복되는 일정을\n체계적으로 관리할 수 있습니다.\n매주 규칙적으로 해야 할 일들을\n미리 계획해보세요!',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final weekday = now.weekday;
    final todayIndex = (weekday - 1).clamp(0, 6);
    _selectedIndex = todayIndex;
    _tabController = TabController(length: days.length, vsync: this, initialIndex: todayIndex);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final tabWidth = (MediaQuery.of(context).size.width - 32.w) / 7;

    final mainContent = DefaultTabController(
      length: days.length,
      child: Scaffold(
        appBar: CustomAppBar(
          title: Text(
            appBarTitle,
            style: AppTextStyles.title.copyWith(color: AppColors.text),
          ),
          isTransparent: true,
          actions: [
            IconButton(
              key: _editButtonKey,
              icon: Icon(
                _isEditing ? Icons.check : Icons.edit_calendar,
                color: _isEditing ? AppColors.success : AppColors.text,
                size: 27.sp,
              ),
              onPressed: () => setState(() => _isEditing = !_isEditing),
            ),
          ],
        ),

        floatingActionButton: Transform.translate(
          offset: Offset(-6.w, -6.h),
          child: FloatingActionButton(
            key: _fabKey,
            onPressed: () => _showAddTaskDialog(context),
            backgroundColor: AppColors.accent,
            child: Icon(Icons.add, size: 24.sp),
          ),
        ),

        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            children: [
              SizedBox(
                key: _tabBarKey,
                height: 48.h,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.primary, width: 1.w),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4.r,
                            offset: Offset(0, 2.h),
                          )
                        ],
                      ),
                    ),
                    ...List.generate(6, (i) {
                      return Positioned(
                        left: tabWidth * (i + 1),
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 1.w,
                          color: AppColors.primary,
                        ),
                      );
                    }),
                    TabBar(
                      controller: _tabController,
                      onTap: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      isScrollable: false,
                      indicator: const BoxDecoration(),
                      dividerColor: Colors.transparent,
                      labelPadding: EdgeInsets.zero,
                      tabs: List.generate(days.length, (index) {
                        final isSelected = _selectedIndex == index;
                        return Center(
                          child: Text(
                            days[index],
                            style: AppTextStyles.body.copyWith(
                              color: isSelected ? AppColors.highlight : AppColors.text,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),

              Expanded(
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
                      final weekTask = ref.watch(weeklyTaskProvider).firstWhere(
                          (t) => t.day == day,
                          orElse: () => WeeklyTaskModel(day: day, tasks: []));

                      return SingleChildScrollView(
                        controller: scrollController,
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WeeklyTaskList(
                                day: day,
                                tasks: weekTask.tasks,
                                isEditing: _isEditing,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return buildWithOnboarding(mainContent);
  }
}