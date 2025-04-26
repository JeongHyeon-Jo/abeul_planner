// calendar_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';

/// 캘린더 위젯 박스 (둥근 테두리 + 그림자 포함)
class CalendarWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;

  const CalendarWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
        child: TableCalendar(
          locale: 'ko_KR',
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: focusedDay,
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          onDaySelected: onDaySelected,
          availableCalendarFormats: const {
            CalendarFormat.month: '월간',
          },
          daysOfWeekHeight: 35.h,
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
          ),
        ),
      ),
    );
  }
}