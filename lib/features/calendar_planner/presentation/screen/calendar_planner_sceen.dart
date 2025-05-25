// calendar_planner_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/provider/calendar_task_provider.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/calendar_task_model.dart';

class CalendarPlannerScreen extends ConsumerStatefulWidget {
  const CalendarPlannerScreen({super.key});

  @override
  ConsumerState<CalendarPlannerScreen> createState() => _CalendarPlannerScreenState();
}

class _CalendarPlannerScreenState extends ConsumerState<CalendarPlannerScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(calendarTaskProvider);
    final groupedTasks = _groupTasksByDate(tasks);

    return Scaffold(
      appBar: CustomAppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: AppColors.text),
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                });
              },
            ),
            SizedBox(width: 4.w),
            Text('${_focusedDay.year}년 ${_focusedDay.month}월', style: AppTextStyles.title.copyWith(color: AppColors.text)),
            SizedBox(width: 4.w),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: AppColors.text),
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
                });
              },
            ),
          ],
        ),
        isTransparent: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.text),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.text),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
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
                          style: AppTextStyles.body.copyWith(color: color),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 4.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Divider(color: AppColors.primary, thickness: 1.2),
                ),
              ],
            ),
          ),
          Expanded(child: _buildCalendarGrid(groupedTasks)),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.r),
                      color: AppColors.cardBackground,
                    ),
                    child: Text(
                      '${DateFormat('M월 d일').format(_selectedDay)}에 일정 추가',
                      style: AppTextStyles.body,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                CircleAvatar(
                  backgroundColor: AppColors.accent,
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(Map<String, List<CalendarTaskModel>> grouped) {
    final start = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final end = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final days = List.generate(end.day, (i) => DateTime(_focusedDay.year, _focusedDay.month, i + 1));
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
                  final isToday = DateTime.now().year == day.year && DateTime.now().month == day.month && DateTime.now().day == day.day;
                  final isSelected = _selectedDay.year == day.year && _selectedDay.month == day.month && _selectedDay.day == day.day;
                  final isCurrentMonth = day.month == _focusedDay.month;
                  final events = grouped[DateFormat('yyyy-MM-dd').format(day)] ?? [];

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDay = day;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 2.w),
                        padding: EdgeInsets.only(top: 6.h, left: 6.w, right: 6.w, bottom: 6.h),
                        constraints: BoxConstraints(minHeight: 80.h),
                        decoration: BoxDecoration(
                          color: isToday ? AppColors.highlight.withOpacity(0.2) : null,
                          border: Border.all(color: isSelected ? AppColors.accent : Colors.transparent, width: 1.5.w),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${day.day}',
                              style: AppTextStyles.body.copyWith(
                                color: isCurrentMonth
                                    ? (day.weekday == DateTime.sunday
                                        ? Colors.red
                                        : day.weekday == DateTime.saturday
                                            ? Colors.blue
                                            : AppColors.text)
                                    : AppColors.subText,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            ...events.take(3).map((e) => Padding(
                                  padding: EdgeInsets.only(bottom: 2.h),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      e.memo.length > 6 ? '${e.memo.substring(0, 6)}…' : e.memo,
                                      style: AppTextStyles.caption,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )),
                            if (events.length > 3)
                              Text('+${events.length - 3}', style: AppTextStyles.caption)
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (weekIndex < (paddedDays.length / 7).ceil() - 1)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Divider(color: AppColors.primary, thickness: 1),
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
}