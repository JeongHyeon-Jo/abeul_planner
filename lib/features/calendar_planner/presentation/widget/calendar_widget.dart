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
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          onDaySelected: onDaySelected,
          eventLoader: (day) => _getEventsForDay(allTasks, day),
          availableCalendarFormats: const {
            CalendarFormat.month: '월간',
          },
          daysOfWeekHeight: 35.h,
          rowHeight: 100.h,
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
            weekdayStyle: AppTextStyles.body.copyWith(fontSize: 14.sp),
            weekendStyle: AppTextStyles.body.copyWith(fontSize: 14.sp),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: AppColors.highlight,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            defaultTextStyle: AppTextStyles.body,
            weekendTextStyle: AppTextStyles.body,
            markerDecoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 3,
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              if (events.isEmpty) return const SizedBox.shrink();
              final tasks = events.cast<CalendarTaskModel>();
              return Padding(
                padding: EdgeInsets.only(top: 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var task in tasks.take(2))
                      Text(
                        '· ${task.memo.length > 6 ? '${task.memo.substring(0, 6)}…' : task.memo}',
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