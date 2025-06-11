// calendar_task_list.dart
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
  bool _isReordering = false;

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
      .where((t) => t.containsDate(widget.selectedDate))
      .toList();
    final taskProvider = ref.read(calendarTaskProvider.notifier);

    final tasks = _isReordering || !user.autoSortCompleted
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('yyyy년 MM월 dd일').format(widget.selectedDate),
                          style: AppTextStyles.title,
                        ),
                        Builder(
                          builder: (context) {
                            final taskProvider = ref.read(calendarTaskProvider.notifier);
                            final lunarText = taskProvider.getLunarDateText(widget.selectedDate);
                            if (lunarText.isNotEmpty) {
                              return Padding(
                                padding: EdgeInsets.only(top: 4.h),
                                child: Text(
                                  lunarText,
                                  style: AppTextStyles.captionSmall.copyWith(
                                    color: AppColors.subText,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                  if (_isReordering)
                    IconButton(
                      icon: Icon(Icons.check, color: AppColors.success),
                      onPressed: () => setState(() => _isReordering = false),
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
                  child: Column(
                    children: [
                      Text('등록된 일정이 없습니다.', style: AppTextStyles.body),
                      if (_isReordering)
                        Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            '일정을 길게 눌러서 순서를 변경하세요',
                            style: AppTextStyles.caption.copyWith(color: AppColors.subText),
                          ),
                        ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    if (_isReordering)
                      Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withAlpha((0.1 * 255).toInt()),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppColors.accent.withAlpha((0.3 * 255).toInt())),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 16.sp, color: AppColors.accent),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                '드래그하여 순서를 변경하세요',
                                style: AppTextStyles.caption.copyWith(color: AppColors.accent),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                        
                        // 기간 일정인 경우 현재 날짜에서의 표시 타입 확인
                        final periodDisplayType = task.isPeriodTask 
                            ? taskProvider.getPeriodTaskDisplayType(task, widget.selectedDate)
                            : null;
                    
                    return GestureDetector(
                      key: ValueKey('${task.memo}-${task.date}'),
                      onTap: () {
                        if (!_isReordering) {
                          showDialog(
                            context: context,
                            builder: (_) => CalendarTaskDialog(
                              existingTask: task,
                              selectedDate: widget.selectedDate,
                            ),
                          );
                        }
                      },
                      onLongPress: () {
                        if (!_isReordering) {
                          setState(() => _isReordering = true);
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.primary, width: 1.2.w),
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
                              child: GestureDetector(
                                onTap: () {
                                  if (!_isReordering) {
                                    showDialog(
                                      context: context,
                                      builder: (_) => CalendarTaskDialog(
                                        existingTask: task,
                                        selectedDate: widget.selectedDate,
                                      ),
                                    );
                                  }
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            task.endDate != null
                                                ? '${DateFormat('yyyy.MM.dd').format(task.date)} ~ ${DateFormat('yyyy.MM.dd').format(task.endDate!)}'
                                                : DateFormat('yyyy.MM.dd').format(task.date),
                                            style: AppTextStyles.caption,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (task.secret == true)
                                          Padding(
                                            padding: EdgeInsets.only(left: 4.w),
                                            child: Icon(Icons.lock, size: 16.sp, color: AppColors.subText),
                                          ),
                                        if (task.isPeriodTask)
                                          Padding(
                                            padding: EdgeInsets.only(left: 4.w),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                              decoration: BoxDecoration(
                                                color: AppColors.accent.withAlpha((0.2 * 255).toInt()),
                                                borderRadius: BorderRadius.circular(4.r),
                                              ),
                                              child: Text(
                                                '기간',
                                                style: AppTextStyles.captionSmall.copyWith(
                                                  color: AppColors.accent,
                                                  fontSize: 10.sp,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    Row(
                                      children: [
                                        if (getPriorityIcon(task.priority) != null) ... [
                                          getPriorityIcon(task.priority)!,
                                          SizedBox(width: 4.w),
                                        ],
                                        Expanded(
                                          child: Text(
                                            task.memo,
                                            style: AppTextStyles.body,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // 기간 일정의 경우 현재 날짜 위치 표시
                                    if (task.isPeriodTask && periodDisplayType != null)
                                      Padding(
                                        padding: EdgeInsets.only(top: 4.h),
                                        child: Text(
                                          _getPeriodStatusText(periodDisplayType),
                                          style: AppTextStyles.captionSmall.copyWith(
                                            color: AppColors.subText,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            if (_isReordering)
                              ReorderableDragStartListener(
                                index: index,
                                child: Icon(Icons.drag_handle, color: AppColors.subText),
                              )
                            else
                              Checkbox(
                                value: task.isCompleted,
                                onChanged: (_) => ref.read(calendarTaskProvider.notifier).toggleTask(task),
                              ),
                          ],
                        ),
                      ),
                    );
                      },
                    ),
                  ],
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

  String _getPeriodStatusText(PeriodTaskDisplayType displayType) {
    switch (displayType) {
      case PeriodTaskDisplayType.start:
        return '시작일';
      case PeriodTaskDisplayType.end:
        return '종료일';
      case PeriodTaskDisplayType.middle:
        return '진행 중';
      case PeriodTaskDisplayType.single:
        return '당일 완료';
    }
  }

  bool isSameDay(DateTime d1, DateTime d2) => d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}