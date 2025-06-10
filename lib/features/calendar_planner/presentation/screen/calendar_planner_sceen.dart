// calendar_planner_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// core
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
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

class _CalendarPlannerScreenState extends ConsumerState<CalendarPlannerScreen> {
  late PageController _pageController;
  final int initialPage = 1000;
  DateTime _selectedDay = DateTime.now();

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
    return Scaffold(
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
          icon: Icon(Icons.menu, color: AppColors.text, size: 22.sp),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CalendarAllTaskScreen()),
            );
          },
        ),
        actions: [
          IconButton(
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      _buildWeekHeader(),
                      CalendarGrid(
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