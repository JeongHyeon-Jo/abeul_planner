// calendar_planner_screen.dart
import 'package:abeul_planner/features/calendar_planner/presentation/screen/search_task_screen.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/widget/calendar_task_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
// core
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/core/utils/korean_holidays.dart';
// feature
import 'package:abeul_planner/features/calendar_planner/presentation/provider/calendar_task_provider.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/calendar_task_model.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/screen/calendar_all_task_screen.dart';

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
    final tasks = ref.watch(calendarTaskProvider);
    final groupedTasks = _groupTasksByDate(tasks);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          '달력 플래너',
          style: AppTextStyles.title.copyWith(color: AppColors.text),
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
        onPageChanged: (index) {
          setState(() {});
        },
        itemBuilder: (context, index) {
          final date = DateTime(DateTime.now().year, DateTime.now().month + (index - initialPage));
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${date.year}년 ${date.month}월',
                          style: AppTextStyles.title.copyWith(color: AppColors.text),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
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
              ),
              Expanded(
                child: _buildCalendarGrid(groupedTasks, date),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendarGrid(Map<String, List<CalendarTaskModel>> grouped, DateTime monthDate) {
    final start = DateTime(monthDate.year, monthDate.month, 1);
    final end = DateTime(monthDate.year, monthDate.month + 1, 0);
    final days = List.generate(end.day, (i) => DateTime(monthDate.year, monthDate.month, i + 1));
    final weekOffset = start.weekday % 7;
    final allDays = List.generate(weekOffset, (i) => start.subtract(Duration(days: weekOffset - i))) + days;
    final gridCount = (allDays.length / 7).ceil() * 7;
    final paddedDays = allDays + List.generate(gridCount - allDays.length, (i) => end.add(Duration(days: i + 1)));

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: (paddedDays.length / 7).ceil(),
      itemBuilder: (context, weekIndex) {
        final week = paddedDays.skip(weekIndex * 7).take(7).toList();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: week.map((day) {
                  final dateKey = DateFormat('yyyy-MM-dd').format(day);
                  final holidayNames = koreanHolidays[dateKey];
                  final isHoliday = holidayNames != null && holidayNames.isNotEmpty;
                  final isToday = DateTime.now().year == day.year && DateTime.now().month == day.month && DateTime.now().day == day.day;
                  final isSelected = _selectedDay.year == day.year && _selectedDay.month == day.month && _selectedDay.day == day.day;
                  final isCurrentMonth = day.month == monthDate.month;
                  final events = grouped[dateKey] ?? [];
                  final maxItems = 4;

                  final allItems = [
                    if (holidayNames is List<String>) ...holidayNames.map((e) => {'type': 'holiday', 'name': e}),
                    ...events.map((e) => {'type': 'event', 'name': e.memo}),
                  ];

                  final visibleItems = allItems.length > maxItems
                      ? allItems.take(maxItems - 1).toList()
                      : allItems;
                  final overflowCount = allItems.length > maxItems ? allItems.length - (maxItems - 1) : 0;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDay = day;
                        });
                        showDialog(
                          context: context,
                          builder: (_) => CalendarTaskList(selectedDate: day),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 2.w),
                        padding: EdgeInsets.only(top: 4.h, left: 4.w, right: 4.w, bottom: 2.h),
                        constraints: BoxConstraints(minHeight: 90.h),
                        decoration: BoxDecoration(
                          color: isToday ? AppColors.highlight.withAlpha((0.2 * 255).toInt()) : null,
                          border: Border.all(color: isSelected ? AppColors.accent : Colors.transparent, width: 1.5.w),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${day.day}',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 14.sp,
                                color: isHoliday
                                    ? Colors.red
                                    : isCurrentMonth
                                        ? (day.weekday == DateTime.sunday
                                            ? Colors.red
                                            : day.weekday == DateTime.saturday
                                                ? Colors.blue
                                                : AppColors.text)
                                        : AppColors.subText,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            ...visibleItems.map((item) {
                              final isHolidayItem = item['type'] == 'holiday';
                              final name = item['name']?.toString() ?? '';
                              return Padding(
                                padding: EdgeInsets.only(bottom: 1.2.h),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.2.h),
                                  decoration: BoxDecoration(
                                    color: isHolidayItem
                                        ? AppColors.warning.withAlpha((0.2 * 255).toInt())
                                        : AppColors.accent.withAlpha((0.15 * 255).toInt()),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    name,
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 10.sp,
                                      color: isHolidayItem ? Colors.red : AppColors.text,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                  ),
                                ),
                              );
                            }),
                            if (overflowCount > 0)
                              Text(
                                '+$overflowCount',
                                style: AppTextStyles.caption.copyWith(fontSize: 11.sp),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (weekIndex < (paddedDays.length / 7).ceil() - 1)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 2.w),
                  child: Divider(color: AppColors.primary, thickness: 1.2.w),
                )
            ],
          ),
        );
      },
    );
  }

  Map<String, List<CalendarTaskModel>> _groupTasksByDate(List<CalendarTaskModel> tasks) {
    final Map<String, List<CalendarTaskModel>> map = {};
    for (final task in tasks) {
      final key = DateFormat('yyyy-MM-dd').format(task.date);
      map.putIfAbsent(key, () => []).add(task);
    }
    return map;
  }

  Future<DateTime?> showMonthYearPickerDialog(BuildContext context, DateTime initialDate) async {
    int selectedYear = initialDate.year;
    int selectedMonth = initialDate.month;

    return showDialog<DateTime>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('연도와 월 선택'),
          content: SizedBox(
            height: 100,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<int>(
                    value: selectedYear,
                    isExpanded: true,
                    items: List.generate(30, (i) {
                      final year = DateTime.now().year - 15 + i;
                      return DropdownMenuItem(value: year, child: Text('$year년'));
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        selectedYear = value;
                        (context as Element).markNeedsBuild();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<int>(
                    value: selectedMonth,
                    isExpanded: true,
                    items: List.generate(12, (i) {
                      return DropdownMenuItem(value: i + 1, child: Text('${i + 1}월'));
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        selectedMonth = value;
                        (context as Element).markNeedsBuild();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, DateTime(selectedYear, selectedMonth));
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
