// calendar_planner_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// core
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/core/onboarding/onboarding_mixin.dart';
import 'package:abeul_planner/core/onboarding/onboarding_overlay.dart';
// feature
import 'package:abeul_planner/features/calendar_planner/presentation/screen/calendar_all_task_screen.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/screen/search_task_screen.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/widget/month_picker_dialog.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/widget/calendar_grid.dart';

class CalendarPlannerScreen extends ConsumerStatefulWidget {
  const CalendarPlannerScreen({super.key});

  @override
  ConsumerState<CalendarPlannerScreen> createState() => _CalendarPlannerScreenState();
}

class _CalendarPlannerScreenState extends ConsumerState<CalendarPlannerScreen> with OnboardingMixin {
  late PageController _pageController;
  final int initialPage = 1000;
  DateTime _selectedDay = DateTime.now();

  // 온보딩을 위한 GlobalKey들
  final GlobalKey _menuButtonKey = GlobalKey();
  final GlobalKey _searchButtonKey = GlobalKey();
  final GlobalKey _monthYearKey = GlobalKey();
  final GlobalKey _calendarGridKey = GlobalKey();

  @override
  String get onboardingKey => 'calendar';

  @override
  List<OnboardingStep> get onboardingSteps => [
    OnboardingStep(
      title: '일정 목록',
      description: '좌측 상단의 메뉴 버튼을 눌러\n등록된 모든 일정을 확인할 수 있습니다!',
      targetKey: _menuButtonKey,
    ),
    OnboardingStep(
      title: '일정 검색',
      description: '우측 상단의 검색 버튼을 눌러\n원하는 일정을 빠르게 찾을 수 있습니다.\n키워드로 쉽게 검색해보세요!',
      targetKey: _searchButtonKey,
    ),
    OnboardingStep(
      title: '년도/월 변경',
      description: '상단의 년도/월 부분을 눌러\n원하는 년도와 월로 이동할 수 있습니다.\n미래나 과거 일정도 확인해보세요!',
      targetKey: _monthYearKey,
    ),
    OnboardingStep(
      title: '일정 추가',
      description: '달력의 날짜를 눌러 일정을 추가하거나\n날짜를 길게 눌러 드래그하면\n기간 일정을 쉽게 만들 수 있습니다!',
      targetKey: _calendarGridKey,
    ),
    const OnboardingStep(
      title: '달력 플래너 완료!',
      description: '이제 달력을 통해 일정을\n체계적으로 관리할 수 있습니다.\n중요한 약속과 일정을 놓치지 마세요!',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainContent = Scaffold(
      appBar: CustomAppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left, color: AppColors.text, size: 24.sp),
              onPressed: () {
                _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
              },
            ),
            SizedBox(width: 4.w),
            GestureDetector(
              key: _monthYearKey,
              onTap: () async {
                final picked = await showMonthYearPickerDialog(context, DateTime.now());
                if (picked != null) {
                  final diff = (picked.year - DateTime.now().year) * 12 + picked.month - DateTime.now().month;
                  _pageController.jumpToPage(initialPage + diff);
                }
              },
              child: Consumer(
                builder: (context, ref, _) {
                  final index = _pageController.hasClients ? _pageController.page?.round() ?? initialPage : initialPage;
                  final date = DateTime(DateTime.now().year, DateTime.now().month + (index - initialPage));
                  return Text(
                    '${date.year}년 ${date.month}월',
                    style: AppTextStyles.title.copyWith(color: AppColors.text),
                  );
                },
              ),
            ),
            SizedBox(width: 4.w),
            IconButton(
              icon: Icon(Icons.chevron_right, color: AppColors.text, size: 24.sp),
              onPressed: () {
                _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
              },
            ),
          ],
        ),
        isTransparent: true,
        leading: IconButton(
          key: _menuButtonKey,
          icon: Icon(Icons.menu, color: AppColors.text, size: 22.sp),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CalendarAllTaskScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            key: _searchButtonKey,
            icon: Icon(Icons.search, color: AppColors.text, size: 22.sp),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchTaskScreen()),
              );
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          final date = DateTime(DateTime.now().year, DateTime.now().month + (index - initialPage));
          
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                controller: scrollController,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      _buildWeekHeader(),
                      CalendarGrid(
                        key: ValueKey('calendar_grid_${date.year}_${date.month}'), // 고유한 키 추가
                        monthDate: date,
                        selectedDay: _selectedDay,
                        onDaySelected: (selectedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );

    return buildWithOnboarding(mainContent);
  }

  Widget _buildWeekHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final weekDays = ['일', '월', '화', '수', '목', '금', '토'];
              final color = i == 0
                  ? Colors.red
                  : i == 6
                      ? Colors.blue
                      : AppColors.text;
              return Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    weekDays[i],
                    style: AppTextStyles.body.copyWith(color: color, fontSize: 13.sp),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Divider(color: AppColors.primary, thickness: 1.2.w),
          ),
        ],
      ),
    );
  }
}