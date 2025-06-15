// features/home_planner/presentation/screen/planner_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
// core
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/onboarding/onboarding_mixin.dart';
import 'package:abeul_planner/core/onboarding/onboarding_overlay.dart';
// provider
import 'package:abeul_planner/features/calendar_planner/presentation/provider/calendar_task_provider.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/provider/weekly_task_provider.dart';
import 'package:abeul_planner/features/daily_planner/presentation/provider/daily_task_provider.dart';
// section widget
import 'package:abeul_planner/features/home_planner/presentation/widget/calendar_section.dart';
import 'package:abeul_planner/features/home_planner/presentation/widget/weekly_section.dart';
import 'package:abeul_planner/features/home_planner/presentation/widget/daily_section.dart';
import 'package:abeul_planner/features/home_planner/presentation/widget/expandable_section.dart';

class PlannerHomeScreen extends ConsumerStatefulWidget {
  const PlannerHomeScreen({super.key});

  @override
  ConsumerState<PlannerHomeScreen> createState() => _PlannerHomeScreenState();
}

class _PlannerHomeScreenState extends ConsumerState<PlannerHomeScreen> with OnboardingMixin {
  // 온보딩을 위한 GlobalKey들
  final GlobalKey _calendarSectionKey = GlobalKey();
  final GlobalKey _weeklySectionKey = GlobalKey();
  final GlobalKey _dailySectionKey = GlobalKey();

  @override
  String get onboardingKey => 'home';

  @override
  List<OnboardingStep> get onboardingSteps => [
    OnboardingStep(
      title: '달력 플래너',
      description: '날짜에 일정을 등록하고 관리할 수 있습니다.\n달력을 기반으로 일정을 계획해보세요!',
      targetKey: _calendarSectionKey,
    ),
    OnboardingStep(
      title: '주간 플래너',
      description: '요일별로 반복되는 일정을 관리할 수 있습니다.\n매주 규칙적으로 해야 할 일들을 계획해보세요!',
      targetKey: _weeklySectionKey,
    ),
    OnboardingStep(
      title: '일상 플래너',
      description: '매일 반복하는 일정을 관리할 수 있습니다.\n언제 어떤 행동을 취할지 미리 계획해보세요!',
      targetKey: _dailySectionKey,
    ),
    const OnboardingStep(
      title: '네비게이션 바',
      description: '각 플래너로 쉽게 이동할 수 있습니다.\n홈 버튼을 눌러 이 화면으로 돌아올 수 있어요!',
    ),
    const OnboardingStep(
      title: '종합 플래너 완료!',
      description: '모든 플래너를 화면에서 확인할 수 있습니다.\n각 섹션을 클릭하여 플래너로 이동하거나,\n제목을 터치하여 섹션을 접고 펼칠 수 있어요!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final calendarTasks = ref.watch(calendarTaskProvider);
    final weeklyTasks = ref.watch(weeklyTaskProvider);
    final dailyTasks = ref.watch(dailyTaskProvider);

    final now = DateTime.now();
    final appBarTitle = DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(now);
    final weekday = DateFormat('E', 'ko_KR').format(now);

    final mainContent = Scaffold(
      appBar: CustomAppBar(
        title: Text(
          appBarTitle,
          style: AppTextStyles.title.copyWith(color: AppColors.text),
        ),
        isTransparent: true,
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: EdgeInsets.all(16.0.w),
          child: Column(
            children: [
              ExpandableSection(
                key: _calendarSectionKey,
                title: '달력 플래너',
                route: '/calendar',
                child: CalendarSection(now: now, calendarTasks: calendarTasks),
              ),
              SizedBox(height: 16.h),
              ExpandableSection(
                key: _weeklySectionKey,
                title: '주간 플래너',
                route: '/weekly',
                child: WeeklySection(weekday: weekday, weeklyTasks: weeklyTasks),
              ),
              SizedBox(height: 16.h),
              ExpandableSection(
                key: _dailySectionKey,
                title: '일상 플래너',
                route: '/daily',
                child: DailySection(dailyTasks: dailyTasks),
              ),
            ],
          ),
        ),
      ),
    );

    return buildWithOnboarding(mainContent);
  }
}