// 개선된 calendar_task_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/utils/priority_icon.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/provider/calendar_task_provider.dart';
import 'package:abeul_planner/features/auth/presentation/provider/user_provider.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/widget/calendar_task_dialog.dart';
import 'package:abeul_planner/core/utils/korean_holidays.dart';

class CalendarTaskList extends ConsumerStatefulWidget {
  final DateTime selectedDate;

  const CalendarTaskList({super.key, required this.selectedDate});

  @override
  ConsumerState<CalendarTaskList> createState() => _CalendarTaskListState();
}

class _CalendarTaskListState extends ConsumerState<CalendarTaskList> {
  bool _isEditing = false;

  Color getDisplayColor(Color color) {
    if (color == AppColors.accent.withAlpha((0.15 * 255).toInt())) {
      return AppColors.accent.withAlpha((0.4 * 255).toInt());
    } else if (color == Colors.green.withAlpha((0.15 * 255).toInt())) {
      return Colors.green.withAlpha((0.4 * 255).toInt());
    } else if (color == Colors.orange.withAlpha((0.15 * 255).toInt())) {
      return Colors.orange.withAlpha((0.4 * 255).toInt());
    } else if (color == Colors.purple.withAlpha((0.15 * 255).toInt())) {
      return Colors.purple.withAlpha((0.4 * 255).toInt());
    } else if (color == Colors.blue.withAlpha((0.15 * 255).toInt())) {
      return Colors.blue.withAlpha((0.4 * 255).toInt());
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final allTasks = ref.watch(calendarTaskProvider)
        .where((task) => isSameDay(task.date, widget.selectedDate))
        .toList();

    final tasks = _isEditing || !user.autoSortCompleted
        ? allTasks
        : [...allTasks.where((t) => !t.isCompleted), ...allTasks.where((t) => t.isCompleted)];

    final dateKey = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
    final holidayNames = koreanHolidays[dateKey] ?? [];

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('yyyy년 MM월 dd일').format(widget.selectedDate),
                      style: AppTextStyles.title,
                    ),
                  ),
                  IconButton(
                    icon: Icon(_isEditing ? Icons.check : Icons.edit_calendar,
                        color: _isEditing ? AppColors.success : AppColors.text),
                    onPressed: () => setState(() => _isEditing = !_isEditing),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: AppColors.accent),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => CalendarTaskDialog(selectedDate: widget.selectedDate),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              if (holidayNames.isNotEmpty)
                ...holidayNames.map((h) => Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withAlpha((0.15 * 255).toInt()),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.warning),
                      ),
                      child: Row(
                        children: [Expanded(child: Text(h, style: AppTextStyles.body.copyWith(color: Colors.red)))]
                      ),
                    )),
              if (tasks.isEmpty && holidayNames.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Text('등록된 일정이 없습니다.', style: AppTextStyles.body),
                )
              else
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  itemCount: tasks.length,
                  onReorder: (oldIndex, newIndex) => ref
                      .read(calendarTaskProvider.notifier)
                      .reorderTask(widget.selectedDate, oldIndex, newIndex),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final lunarText = ref.read(calendarTaskProvider.notifier).getLunarDateText(task.date);
                    return Container(
                      key: ValueKey('${task.memo}-${task.date}'),
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 18.w,
                                height: 18.w,
                                margin: EdgeInsets.only(bottom: 6.h),
                                decoration: BoxDecoration(
                                  color: getDisplayColor(task.color),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      task.endDate != null
                                          ? '${DateFormat('yyyy.MM.dd').format(task.date)} ~ ${DateFormat('yyyy.MM.dd').format(task.endDate!)}'
                                          : DateFormat('yyyy.MM.dd').format(task.date),
                                      style: AppTextStyles.caption,
                                    ),
                                    if (task.secret == true)
                                      Padding(
                                        padding: EdgeInsets.only(left: 4.w),
                                        child: Icon(Icons.lock, size: 16.sp, color: AppColors.subText),
                                      ),
                                  ],
                                ),
                                if (lunarText.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 2.h),
                                    child: Text(
                                      lunarText,
                                      style: AppTextStyles.captionSmall.copyWith(color: AppColors.subText),
                                    ),
                                  ),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    if (getPriorityIcon(task.priority) != null) ... [
                                      getPriorityIcon(task.priority)!,
                                      SizedBox(width: 4.w),
                                    ],
                                    Text(task.memo, style: AppTextStyles.body),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (_isEditing) ...[
                            IconButton(
                              icon: Icon(Icons.edit, size: 20.sp, color: AppColors.subText),
                              onPressed: () => showDialog(
                                context: context,
                                builder: (_) => CalendarTaskDialog(
                                  existingTask: task,
                                  selectedDate: widget.selectedDate,
                                ),
                              ),
                            ),
                            ReorderableDragStartListener(
                              index: index,
                              child: Icon(Icons.drag_handle, color: AppColors.subText),
                            ),
                          ] else
                            Checkbox(
                              value: task.isCompleted,
                              onChanged: (_) => ref.read(calendarTaskProvider.notifier).toggleTask(task),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              SizedBox(height: 16.h),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('닫기', style: AppTextStyles.body),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isSameDay(DateTime d1, DateTime d2) => d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}