// calendar_grid.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
// core
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/utils/korean_holidays.dart';
// feature
import 'package:abeul_planner/features/calendar_planner/presentation/provider/calendar_task_provider.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/widget/calendar_task_list.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CalendarGrid extends ConsumerStatefulWidget {
  final DateTime monthDate;
  final DateTime selectedDay;
  final Function(DateTime) onDaySelected;

  const CalendarGrid({
    super.key,
    required this.monthDate,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  ConsumerState<CalendarGrid> createState() => _CalendarGridState();
}

class _CalendarGridState extends ConsumerState<CalendarGrid> {
  @override
  Widget build(BuildContext context) {
    final start = DateTime(widget.monthDate.year, widget.monthDate.month, 1);
    final end = DateTime(widget.monthDate.year, widget.monthDate.month + 1, 0);
    final days = List.generate(end.day, (i) => DateTime(widget.monthDate.year, widget.monthDate.month, i + 1));
    final weekOffset = start.weekday % 7;
    final allDays = List.generate(weekOffset, (i) => start.subtract(Duration(days: weekOffset - i))) + days;
    final gridCount = (allDays.length / 7).ceil() * 7;
    final paddedDays = allDays + List.generate(gridCount - allDays.length, (i) => end.add(Duration(days: i + 1)));

    final allTasks = ref.read(calendarTaskProvider);

    final Map<String, List<Map<String, dynamic>>> mappedTasks = {};
    for (final task in allTasks) {
      final key = DateFormat('yyyy-MM-dd').format(task.date);
      mappedTasks.putIfAbsent(key, () => []).add(<String, dynamic>{
        'type': 'event',
        'name': task.secret == true ? '' : task.memo,
        'isSecret': task.secret == true,
        'color': task.colorValue != null
            ? Color(task.colorValue!)
            : AppColors.accent.withAlpha((0.15 * 255).toInt()),
        'isHoliday': false,
        'priority': task.priority,
      });
    }

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
                  final isSelected = widget.selectedDay.year == day.year && widget.selectedDay.month == day.month && widget.selectedDay.day == day.day;
                  final isCurrentMonth = day.month == widget.monthDate.month;

                  final List<Map<String, dynamic>> allItems = [
                    if (holidayNames is List<String>)
                      ...holidayNames.map((e) => <String, dynamic>{
                            'type': 'holiday',
                            'name': e,
                            'isHoliday': true,
                          }),
                    ...(mappedTasks[dateKey] ?? []),
                  ];

                  final List<Map<String, dynamic>> visibleItems = allItems.length > 4 ? allItems.take(3).toList() : allItems;
                  final overflowCount = allItems.length > 4 ? allItems.length - 3 : 0;

                  return Expanded(
                    child: CalendarDayCell(
                      day: day,
                      isToday: isToday,
                      isSelected: isSelected,
                      isCurrentMonth: isCurrentMonth,
                      isHoliday: isHoliday,
                      visibleItems: visibleItems,
                      overflowCount: overflowCount,
                      onTap: () {
                        widget.onDaySelected(day);
                        showDialog(
                          context: context,
                          builder: (_) => CalendarTaskList(selectedDate: day),
                        );
                      },
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
}

class CalendarDayCell extends StatelessWidget {
  final DateTime day;
  final bool isToday;
  final bool isSelected;
  final bool isCurrentMonth;
  final bool isHoliday;
  final List<Map<String, dynamic>> visibleItems;
  final int overflowCount;
  final VoidCallback onTap;

  const CalendarDayCell({
    super.key,
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.isCurrentMonth,
    required this.isHoliday,
    required this.visibleItems,
    required this.overflowCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        padding: EdgeInsets.only(top: 4.h, left: 4.w, right: 4.w, bottom: 2.h),
        constraints: BoxConstraints(minHeight: 90.h),
        decoration: BoxDecoration(
          color: isToday ? AppColors.highlight.withAlpha((0.2 * 255).toInt()) : null,
          border: Border.all(
              color: isSelected ? AppColors.accent : Colors.transparent,
              width: 1.5.w),
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
            ...visibleItems.map((item) => CalendarTaskItem(item: item)),
            if (overflowCount > 0)
              Text(
                '+$overflowCount',
                style: AppTextStyles.caption.copyWith(fontSize: 11.sp),
              ),
          ],
        ),
      ),
    );
  }
}

class CalendarTaskItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const CalendarTaskItem({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final isSecret = item['isSecret'] == true;
    final isHolidayItem = item['isHoliday'] == true;
    final name = item['name']?.toString() ?? '';
    final color = item['color'] as Color? ?? AppColors.accent.withAlpha((0.15 * 255).toInt());
    final isImportant = item['priority'] == '중요';

    if (isSecret) {
      return Padding(
        padding: EdgeInsets.only(bottom: 1.2.h),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 1.2.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.2.h),
        decoration: BoxDecoration(
          color: isHolidayItem
              ? AppColors.warning.withAlpha((0.2 * 255).toInt())
              : color,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          children: [
            if (!isHolidayItem && isImportant)
              Padding(
                padding: EdgeInsets.only(right: 2.w),
                child: Icon(
                  LucideIcons.alertTriangle,
                  size: 12.sp,
                  color: Colors.red,
                ),
              ),
            Expanded(
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
          ],
        ),
      ),
    );
  }
}