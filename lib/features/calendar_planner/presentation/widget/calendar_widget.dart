// calendar_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/calendar_task_model.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/provider/calendar_task_provider.dart';

class CalendarWidget extends ConsumerWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;

  const CalendarWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
  });

  List<CalendarTaskModel> _getEventsForDay(List<CalendarTaskModel> allTasks, DateTime day) {
    return allTasks.where((task) =>
      task.date.year == day.year &&
      task.date.month == day.month &&
      task.date.day == day.day
    ).toList();
  }

  int _getWeekNumberInMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    return ((date.day + firstWeekday - 1) / 7).floor() + 1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTasks = ref.watch(calendarTaskProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
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
        child: TableCalendar<CalendarTaskModel>(
          locale: 'ko_KR',
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: focusedDay,
          selectedDayPredicate: (_) => false, // ✅ 선택 비활성화
          onDaySelected: (selectedDay, focusedDay) => onDaySelected(selectedDay, focusedDay),
          eventLoader: (day) => _getEventsForDay(allTasks, day),
          availableCalendarFormats: const {
            CalendarFormat.month: '월간',
          },
          daysOfWeekHeight: 30.h,
          rowHeight: 85.h,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: AppTextStyles.title,
            leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.text),
            rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.text),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.primary),
              ),
            ),
            titleTextFormatter: (date, locale) => '${date.month}월',
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            dowTextFormatter: (date, locale) => ['일', '월', '화', '수', '목', '금', '토'][date.weekday % 7],
            weekdayStyle: AppTextStyles.body.copyWith(fontSize: 14.sp),
            weekendStyle: AppTextStyles.body.copyWith(fontSize: 14.sp),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          calendarStyle: CalendarStyle(
            selectedDecoration: const BoxDecoration(), // ✅ 선택 배경 제거
            defaultTextStyle: AppTextStyles.body,
            weekendTextStyle: AppTextStyles.body,
            markerDecoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 3,
            outsideTextStyle: AppTextStyles.caption.copyWith(color: AppColors.subText),
          ),
          calendarBuilders: CalendarBuilders(
            dowBuilder: (context, day) {
              final weekday = day.weekday;
              final isSunday = weekday == DateTime.sunday;
              final isSaturday = weekday == DateTime.saturday;
              return Center(
                child: Text(
                  ['일', '월', '화', '수', '목', '금', '토'][weekday % 7],
                  style: AppTextStyles.body.copyWith(
                    color: isSunday
                        ? Colors.red
                        : isSaturday
                            ? Colors.blue
                            : AppColors.text,
                  ),
                ),
              );
            },
            defaultBuilder: (context, day, focused) {
              final isSunday = day.weekday == DateTime.sunday;
              final isSaturday = day.weekday == DateTime.saturday;
              final isOutside = day.month != focusedDay.month;
              final weekInMonth = _getWeekNumberInMonth(day);
              final showDivider = weekInMonth > 1;

              return SizedBox(
                height: 85.h,
                child: Stack(
                  children: [
                    if (showDivider)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(height: 1.2, color: AppColors.primary),
                      ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(top: 6.h),
                        child: Padding(
                          padding: EdgeInsets.all(6.r),
                          child: Text(
                            '${day.day}',
                            style: AppTextStyles.body.copyWith(
                              color: isOutside
                                  ? AppColors.subText
                                  : isSunday
                                      ? Colors.red
                                      : isSaturday
                                          ? Colors.blue
                                          : AppColors.text,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            outsideBuilder: (context, day, focused) {
              final isSunday = day.weekday == DateTime.sunday;
              final isSaturday = day.weekday == DateTime.saturday;
              final isCurrentMonth = day.month == focusedDay.month;
              final weekInMonth = _getWeekNumberInMonth(day);
              final showDivider = isCurrentMonth && weekInMonth > 1;

              return SizedBox(
                height: 85.h,
                child: Stack(
                  children: [
                    if (showDivider)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(height: 1.2, color: AppColors.primary),
                      ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(top: 6.h),
                        child: Padding(
                          padding: EdgeInsets.all(6.r),
                          child: Text(
                            '${day.day}',
                            style: AppTextStyles.caption.copyWith(
                              color: isSunday
                                  ? Colors.red.shade200
                                  : isSaturday
                                      ? Colors.blue.shade200
                                      : AppColors.subText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            markerBuilder: (context, day, events) {
              if (events.isEmpty) return const SizedBox.shrink();
              final tasks = events.cast<CalendarTaskModel>();
              return Padding(
                padding: EdgeInsets.only(top: 32.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var task in tasks.take(2))
                      Text(
                        task.memo.length > 6 ? '${task.memo.substring(0, 6)}…' : task.memo,
                        style: AppTextStyles.caption.copyWith(fontSize: 12.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (tasks.length > 2)
                      Text(
                        '+${tasks.length - 2}',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.subText,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
