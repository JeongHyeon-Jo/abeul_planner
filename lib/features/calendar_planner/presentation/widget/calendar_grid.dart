// calendar_grid.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:abeul_planner/features/calendar_planner/presentation/widget/calendar_task_dialog.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/task_type_model.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CalendarGrid extends ConsumerStatefulWidget {
  final DateTime monthDate;
  final DateTime selectedDay;
  final Function(DateTime) onDaySelected;
  final Function(bool)? onDragStateChanged;

  const CalendarGrid({
    super.key,
    required this.monthDate,
    required this.selectedDay,
    required this.onDaySelected,
    this.onDragStateChanged,
  });

  @override
  ConsumerState<CalendarGrid> createState() => _CalendarGridState();
}

class _CalendarGridState extends ConsumerState<CalendarGrid> {
  DateTime? _dragStartDate;
  DateTime? _dragEndDate;
  bool _isDragging = false;
  bool _isLongPressActive = false;
  Set<DateTime> _selectedDates = {};
  late List<DateTime> _paddedDays;

  @override
  Widget build(BuildContext context) {
    final start = DateTime(widget.monthDate.year, widget.monthDate.month, 1);
    final end = DateTime(widget.monthDate.year, widget.monthDate.month + 1, 0);
    final days = List.generate(end.day, (i) => DateTime(widget.monthDate.year, widget.monthDate.month, i + 1));
    final weekOffset = start.weekday % 7;
    final allDays = List.generate(weekOffset, (i) => start.subtract(Duration(days: weekOffset - i))) + days;
    final gridCount = (allDays.length / 7).ceil() * 7;
    _paddedDays = allDays + List.generate(gridCount - allDays.length, (i) => end.add(Duration(days: i + 1)));

    final allTasks = ref.watch(calendarTaskProvider);
    final taskProvider = ref.read(calendarTaskProvider.notifier);

    // 일정 데이터 처리
    final processedData = _processTaskData(allTasks, taskProvider);

    return Listener(
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: (_paddedDays.length / 7).ceil(),
        itemBuilder: (context, weekIndex) {
          final week = _paddedDays.skip(weekIndex * 7).take(7).toList();
          
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Column(
              children: [
                _buildWeekSizedBox(week, processedData, weekIndex),
                if (weekIndex < (_paddedDays.length / 7).ceil() - 1)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 2.w),
                    child: Divider(color: AppColors.primary, thickness: 1.2.w),
                  )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeekSizedBox(List<DateTime> week, ProcessedTaskData taskData, int weekIndex) {
    final containerHeight = 110.h;

    return SizedBox(
      height: containerHeight,
      child: Stack(
        children: [
          // 기본 날짜 셀들 (배경 + 날짜)
          _buildDateCellsLayer(week),
          
          // 기간 일정 레이어들 (우선 표시)
          ..._buildPeriodLayers(week, taskData.periodTasks),
          
          // 단일 일정 레이어들 (기간 일정과 함께 5개 제한)
          ..._buildRegularTaskLayers(week, taskData),
          
          // 드래그 선택 오버레이
          if (_isDragging && _selectedDates.isNotEmpty)
            _buildContinuousDragOverlay(week),
          
          // 터치 감지 레이어 (최상단)
          _buildTouchLayer(week),
        ],
      ),
    );
  }

  // 특정 날짜의 기간 일정들 가져오기
  List<PeriodTaskSegment> _getPeriodTasksForDay(DateTime day, List<PeriodTaskGroup> periodTasks) {
    final List<PeriodTaskSegment> dayPeriodTasks = [];
    for (final group in periodTasks) {
      for (final period in group.periods) {
        if (period.dates.contains(day)) {
          dayPeriodTasks.add(period);
        }
      }
    }
    return dayPeriodTasks;
  }

  // 두 기간 일정이 겹치는지 확인
  bool _periodsOverlap(PeriodTaskSegment period1, PeriodTaskSegment period2) {
    for (final date1 in period1.dates) {
      if (period2.dates.contains(date1)) {
        return true;
      }
    }
    return false;
  }

  // 기본 날짜 셀 레이어
  Widget _buildDateCellsLayer(List<DateTime> week) {
    return Row(
      children: week.map((day) {
        final isToday = _isToday(day);
        final isSelected = _isSelected(day);
        final isCurrentMonth = day.month == widget.monthDate.month;
        final isHoliday = _isHoliday(day);

        return Expanded(
          child: Container(
            height: 110.h,
            margin: EdgeInsets.symmetric(horizontal: 1.w),
            decoration: BoxDecoration(
              // 드래그 중이 아닐 때만 하이라이트 표시
              color: (!_isDragging && isToday) 
                  ? AppColors.highlight.withAlpha((0.15 * 255).toInt()) 
                  : null,
              border: Border.all(
                // 드래그 중이 아닐 때만 선택 테두리 표시
                color: (!_isDragging && isSelected) 
                    ? AppColors.accent 
                    : Colors.transparent,
                width: 1.5.w,
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(top: 2.h, left: 6.w, right: 6.w, bottom: 2.h),
            child: Text(
              '${day.day}',
              style: AppTextStyles.body.copyWith(
                fontSize: 14.sp,
                color: _getDayTextColor(day, isCurrentMonth, isHoliday),
                // 드래그 중이 아닐 때만 오늘 날짜 볼드 처리
                fontWeight: (!_isDragging && isToday) 
                    ? FontWeight.bold 
                    : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 기간 일정 레이어들 생성
  List<Widget> _buildPeriodLayers(List<DateTime> week, List<PeriodTaskGroup> periodTasks) {
    final List<Widget> layers = [];
    
    final weekPeriods = <PeriodTaskSegment>[];
    for (final group in periodTasks) {
      for (final period in group.periods) {
        if (week.any((day) => period.dates.contains(day))) {
          weekPeriods.add(period);
        }
      }
    }
    
    if (weekPeriods.isEmpty) return layers;
    
    final periodLayers = <List<PeriodTaskSegment>>[];
    
    for (final period in weekPeriods) {
      bool placed = false;
      for (final layer in periodLayers) {
        bool canPlace = true;
        for (final existingPeriod in layer) {
          if (_periodsOverlap(period, existingPeriod)) {
            canPlace = false;
            break;
          }
        }
        if (canPlace) {
          layer.add(period);
          placed = true;
          break;
        }
      }
      if (!placed) {
        periodLayers.add([period]);
      }
    }
    
    for (int layerIndex = 0; layerIndex < periodLayers.length; layerIndex++) {
      final layer = periodLayers[layerIndex];
      layers.add(_buildPeriodLayer(week, layer, layerIndex));
    }
    
    return layers;
  }

  Widget _buildPeriodLayer(List<DateTime> week, List<PeriodTaskSegment> periods, int layerIndex) {
    return Positioned(
      top: 30.h + (layerIndex * 14.h),
      left: 2.w,
      right: 2.w,
      height: 12.h,
      child: Stack(
        children: periods.map((period) {
          return _buildSinglePeriodBar(week, period);
        }).toList(),
      ),
    );
  }

  Widget _buildSinglePeriodBar(List<DateTime> week, PeriodTaskSegment period) {
    int? startIndex;
    int? endIndex;
    
    for (int i = 0; i < week.length; i++) {
      if (period.dates.contains(week[i])) {
        startIndex ??= i;
        endIndex = i;
      }
    }
    
    if (startIndex == null || endIndex == null) {
      return const SizedBox.shrink();
    }
    
    final isStart = period.dates.first == week[startIndex];
    final isEnd = period.dates.last == week[endIndex];
    final isSingle = startIndex == endIndex;
    
    final totalWidth = MediaQuery.of(context).size.width - 20.w;
    final cellWidth = totalWidth / 7;
    final startOffset = startIndex * cellWidth;
    final width = (endIndex - startIndex + 1) * cellWidth;
    
    final shouldShowText = isStart || _shouldShowTextInMiddleWeek(period, week);
    
    return Positioned(
      left: startOffset,
      width: width,
      top: 0,
      height: 12.h,
      child: Container(
        width: width,
        height: 12.h,
        decoration: BoxDecoration(
          color: period.color,
          borderRadius: BorderRadius.only(
            topLeft: (isStart || isSingle) ? Radius.circular(6.r) : Radius.zero,
            bottomLeft: (isStart || isSingle) ? Radius.circular(6.r) : Radius.zero,
            topRight: (isEnd || isSingle) ? Radius.circular(6.r) : Radius.zero,
            bottomRight: (isEnd || isSingle) ? Radius.circular(6.r) : Radius.zero,
          ),
        ),
        child: shouldShowText
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Center(
                child: period.isSecret
                    ? Icon(
                        Icons.lock,
                        size: 9.sp,
                        color: AppColors.subText.withAlpha((0.3 * 255).toInt()),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (period.isImportant)
                            Padding(
                              padding: EdgeInsets.only(right: 1.w),
                              child: Icon(
                                LucideIcons.alertTriangle,
                                size: 7.sp,
                                color: Colors.red,
                              ),
                            ),
                          Flexible(
                            child: Text(
                              period.displayText,
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 8.sp,
                                color: AppColors.text,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
              ),
            )
          : null,
      ),
    );
  }

  // 일반 일정 레이어들 생성 (기간 일정과 함께 5개 제한)
  List<Widget> _buildRegularTaskLayers(List<DateTime> week, ProcessedTaskData taskData) {
    final List<Widget> layers = [];
    
    // 최대 5개 슬롯까지만 표시
    for (int slotIndex = 0; slotIndex < 5; slotIndex++) {
      layers.add(_buildTaskSlot(week, taskData, slotIndex));
    }
    
    return layers;
  }

  Map<String, Set<int>> _getUsedSlotsByDate(List<DateTime> week, List<PeriodTaskGroup> periodTasks) {
    final Map<String, Set<int>> usedSlots = {};
    
    // 각 날짜 초기화
    for (final day in week) {
      final dateKey = DateFormat('yyyy-MM-dd').format(day);
      usedSlots[dateKey] = <int>{};
    }
    
    // 기간 일정들이 사용하는 슬롯 추적
    final weekPeriods = <PeriodTaskSegment>[];
    for (final group in periodTasks) {
      for (final period in group.periods) {
        if (week.any((day) => period.dates.contains(day))) {
          weekPeriods.add(period);
        }
      }
    }
    
    if (weekPeriods.isNotEmpty) {
      final periodLayers = <List<PeriodTaskSegment>>[];
      
      // 기간 일정들을 레이어별로 분류
      for (final period in weekPeriods) {
        bool placed = false;
        for (final layer in periodLayers) {
          bool canPlace = true;
          for (final existingPeriod in layer) {
            if (_periodsOverlap(period, existingPeriod)) {
              canPlace = false;
              break;
            }
          }
          if (canPlace) {
            layer.add(period);
            placed = true;
            break;
          }
        }
        if (!placed) {
          periodLayers.add([period]);
        }
      }
      
      // 각 레이어의 기간 일정들이 사용하는 슬롯 기록
      for (int layerIndex = 0; layerIndex < periodLayers.length; layerIndex++) {
        final layer = periodLayers[layerIndex];
        for (final period in layer) {
          for (final day in week) {
            if (period.dates.contains(day)) {
              final dateKey = DateFormat('yyyy-MM-dd').format(day);
              usedSlots[dateKey]!.add(layerIndex);
            }
          }
        }
      }
    }
    
    return usedSlots;
  }

  Widget _buildTaskSlot(List<DateTime> week, ProcessedTaskData taskData, int slotIndex) {
    final topPosition = 30.h + (slotIndex * 14.h);
    
    // 각 날짜별로 사용된 슬롯 정보 가져오기
    final usedSlotsByDate = _getUsedSlotsByDate(week, taskData.periodTasks);
    
    return Positioned(
      top: topPosition,
      left: 2.w,
      right: 2.w,
      height: 12.h,
      child: Row(
        children: week.map((day) {
          final dateKey = DateFormat('yyyy-MM-dd').format(day);
          final dayTasks = taskData.regularTasks[dateKey] ?? [];
          final dayPeriodTasks = _getPeriodTasksForDay(day, taskData.periodTasks);
          final usedSlots = usedSlotsByDate[dateKey] ?? <int>{};
          
          // 현재 슬롯이 기간 일정에 의해 사용되고 있는지 확인
          final isSlotUsedByPeriod = usedSlots.contains(slotIndex);
          
          Widget taskWidget;
          
          if (isSlotUsedByPeriod) {
            // 해당 슬롯이 기간 일정에 의해 사용되고 있으면 비워둠
            taskWidget = const SizedBox.shrink();
          } else {
            // 해당 슬롯이 기간 일정에 의해 사용되지 않는 경우 단일 일정 처리
            
            // 현재 슬롯보다 낮은 인덱스 중에서 기간 일정에 의해 사용되지 않는 슬롯들의 개수
            int availableSlotsBefore = 0;
            for (int i = 0; i < slotIndex; i++) {
              if (!usedSlots.contains(i)) {
                availableSlotsBefore++;
              }
            }
            
            // 전체 5개 슬롯 중에서 기간 일정에 의해 사용되지 않는 슬롯들의 개수
            int totalAvailableSlots = 0;
            for (int i = 0; i < 5; i++) {
              if (!usedSlots.contains(i)) {
                totalAvailableSlots++;
              }
            }
            
            // 총 일정 개수 (기간 일정 + 단일 일정)
            final totalTaskCount = dayPeriodTasks.length + dayTasks.length;
            
            // 단일 일정에서의 실제 인덱스
            final regularTaskIndex = availableSlotsBefore;
            
            if (totalTaskCount <= 5) {
              // 총 일정이 5개 이하면 모든 일정 표시 가능
              if (regularTaskIndex < dayTasks.length) {
                taskWidget = _buildRegularTaskWidget(dayTasks[regularTaskIndex]);
              } else {
                taskWidget = const SizedBox.shrink();
              }
            } else {
              // 총 일정이 5개 초과하면 마지막 사용 가능한 슬롯에 +N 표시
              final isLastAvailableSlot = _isLastAvailableSlotForDay(day, usedSlots, slotIndex);
              
              if (isLastAvailableSlot) {
                // 마지막 사용 가능한 슬롯에 +N 표시
                final displayedTaskCount = 4; // 기간 일정 포함하여 총 4개까지 표시
                final remainingCount = totalTaskCount - displayedTaskCount;
                taskWidget = _buildOverflowWidget(remainingCount);
              } else if (regularTaskIndex < dayTasks.length && availableSlotsBefore < totalAvailableSlots - 1) {
                // 마지막 슬롯이 아니고 표시할 단일 일정이 있으면 표시
                taskWidget = _buildRegularTaskWidget(dayTasks[regularTaskIndex]);
              } else {
                taskWidget = const SizedBox.shrink();
              }
            }
          }
          
          return Expanded(
            child: Container(
              height: 12.h,
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              child: taskWidget,
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _isLastAvailableSlotForDay(DateTime day, Set<int> usedSlots, int currentSlotIndex) {
    // 현재 슬롯부터 마지막 슬롯(4)까지 확인하여 사용 가능한 슬롯이 더 있는지 확인
    for (int i = currentSlotIndex + 1; i < 5; i++) {
      if (!usedSlots.contains(i)) {
        return false; // 뒤에 더 사용 가능한 슬롯이 있음
      }
    }
    return true; // 마지막 사용 가능한 슬롯임
  }

  // 특정 날짜의 특정 슬롯에 기간 일정이 있는지 확인
  bool _hasPeriodTaskAtSlot(DateTime day, List<PeriodTaskGroup> periodTasks, int slotIndex) {
    final dayPeriodTasks = _getPeriodTasksForDay(day, periodTasks);
    
    if (dayPeriodTasks.isEmpty) return false;
    
    // 기간 일정들을 레이어별로 분리하여 해당 슬롯에 일정이 있는지 확인
    final periodLayers = <List<PeriodTaskSegment>>[];
    
    for (final period in dayPeriodTasks) {
      bool placed = false;
      for (final layer in periodLayers) {
        bool canPlace = true;
        for (final existingPeriod in layer) {
          if (_periodsOverlap(period, existingPeriod)) {
            canPlace = false;
            break;
          }
        }
        if (canPlace) {
          layer.add(period);
          placed = true;
          break;
        }
      }
      if (!placed) {
        periodLayers.add([period]);
      }
    }
    
    return slotIndex < periodLayers.length;
  }

  // 해당 슬롯이 단일 일정을 위한 마지막 사용 가능한 슬롯인지 확인
  bool _isLastAvailableRegularSlot(DateTime day, List<PeriodTaskGroup> periodTasks, int currentSlotIndex) {
    // 현재 슬롯부터 마지막 슬롯까지 확인하여 기간 일정이 없는 마지막 슬롯인지 판단
    for (int i = currentSlotIndex + 1; i < 5; i++) {
      if (!_hasPeriodTaskAtSlot(day, periodTasks, i)) {
        return false; // 뒤에 더 사용 가능한 슬롯이 있음
      }
    }
    return true; // 마지막 사용 가능한 슬롯임
  }

  // "+N" 오버플로우 위젯
  Widget _buildOverflowWidget(int remainingCount) {
    return Container(
      width: double.infinity,
      height: 12.h,
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppColors.subText.withAlpha((0.2 * 255).toInt()),
        borderRadius: BorderRadius.circular(3.r),
      ),
      child: Center(
        child: Text(
          '+$remainingCount',
          style: AppTextStyles.caption.copyWith(
            fontSize: 8.sp,
            color: AppColors.subText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // 기간 일정이 중간 주에서 텍스트를 표시해야 하는지 결정
  bool _shouldShowTextInMiddleWeek(PeriodTaskSegment period, List<DateTime> week) {
    if (period.dates.length <= 7) return false;
    
    final startDate = period.dates.first;
    final endDate = period.dates.last;
    final weekStart = week.first;
    final weekEnd = week.last;
    
    final isMiddleWeek = startDate.isBefore(weekStart) && endDate.isAfter(weekEnd);
    return isMiddleWeek;
  }

  // 연속적인 드래그 오버레이
  Widget _buildContinuousDragOverlay(List<DateTime> week) {
    final List<DateRange> ranges = _getSelectedDateRanges(week);
    
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Stack(
        children: ranges.map((range) {
          final totalWidth = MediaQuery.of(context).size.width - 20.w;
          final cellWidth = totalWidth / 7;
          final startOffset = range.startIndex * cellWidth + 2.w;
          final width = (range.endIndex - range.startIndex + 1) * cellWidth - 4.w;
          
          return Positioned(
            left: startOffset,
            width: width,
            top: 2.h,
            bottom: 2.h,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.accent.withAlpha((0.2 * 255).toInt()),
                border: Border.all(
                  color: AppColors.accent,
                  width: 2.w,
                ),
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 선택된 날짜들의 연속 구간들 찾기
  List<DateRange> _getSelectedDateRanges(List<DateTime> week) {
    final List<DateRange> ranges = [];
    final selectedIndices = <int>[];
    
    for (int i = 0; i < week.length; i++) {
      if (_selectedDates.any((date) => _isSameDay(date, week[i]))) {
        selectedIndices.add(i);
      }
    }
    
    if (selectedIndices.isEmpty) return ranges;
    
    int rangeStart = selectedIndices.first;
    int rangeEnd = selectedIndices.first;
    
    for (int i = 1; i < selectedIndices.length; i++) {
      if (selectedIndices[i] == rangeEnd + 1) {
        rangeEnd = selectedIndices[i];
      } else {
        ranges.add(DateRange(rangeStart, rangeEnd));
        rangeStart = selectedIndices[i];
        rangeEnd = selectedIndices[i];
      }
    }
    
    ranges.add(DateRange(rangeStart, rangeEnd));
    return ranges;
  }

  // 터치 감지 레이어
  Widget _buildTouchLayer(List<DateTime> week) {
    return Row(
      children: week.map((day) {
        return Expanded(
          child: GestureDetector(
            onTap: () {
              if (!_isDragging && !_isLongPressActive) {
                if (_isSameDay(widget.selectedDay, day)) {
                  showDialog(
                    context: context,
                    builder: (_) => CalendarTaskList(selectedDate: day),
                  );
                } else {
                  widget.onDaySelected(day);
                }
              }
            },
            onLongPressStart: (details) => _onLongPressStart(day),
            child: Container(
              color: Colors.transparent,
              child: const SizedBox.expand(),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 일반 일정 위젯
  Widget _buildRegularTaskWidget(TaskItem task) {
    return Container(
      width: double.infinity,
      height: 12.h,
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: task.color,
        borderRadius: BorderRadius.circular(3.r),
      ),
      child: Center(
      child: task.isSecret
          ? Icon(
              Icons.lock,
              size: 9.sp,
              color: AppColors.subText.withAlpha((0.3 * 255).toInt()),
            )
          : Row(
              children: [
                if (task.isImportant)
                  Padding(
                    padding: EdgeInsets.only(right: 1.w),
                    child: Icon(
                      LucideIcons.alertTriangle,
                      size: 7.sp,
                      color: Colors.red,
                    ),
                  ),
                Flexible(
                  child: Text(
                    task.name,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 8.sp,
                      color: task.isHoliday ? Colors.red : AppColors.text,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ],
            ),
      ),
    );
  }

  // 데이터 처리 메서드
  ProcessedTaskData _processTaskData(List<dynamic> allTasks, dynamic taskProvider) {
    final Map<String, List<TaskItem>> regularTasks = {};
    final List<PeriodTaskGroup> periodTaskGroups = [];
    
    // 공휴일 추가
    for (final day in _paddedDays) {
      final dateKey = DateFormat('yyyy-MM-dd').format(day);
      final holidayNames = koreanHolidays[dateKey];
      if (holidayNames != null && holidayNames.isNotEmpty) {
        regularTasks.putIfAbsent(dateKey, () => []);
        for (final holiday in holidayNames) {
          regularTasks[dateKey]!.add(TaskItem(
            name: holiday,
            color: AppColors.warning.withAlpha((0.2 * 255).toInt()),
            isHoliday: true,
            isSecret: false,
            isImportant: false,
          ));
        }
      }
    }
    
    // 일정 분류
    final List<PeriodTaskSegment> allPeriodSegments = [];
    
    for (final task in allTasks) {
      if (task.isPeriodTask) {
        // 기간 일정 처리
        final startDay = DateTime(task.date.year, task.date.month, task.date.day);
        final endDay = DateTime(task.endDate!.year, task.endDate!.month, task.endDate!.day);
        
        final datesInPeriod = <DateTime>[];
        DateTime currentDay = startDay;
        
        while (currentDay.isBefore(endDay) || currentDay.isAtSameMomentAs(endDay)) {
          datesInPeriod.add(currentDay);
          currentDay = currentDay.add(const Duration(days: 1));
        }
        
        allPeriodSegments.add(PeriodTaskSegment(
          dates: datesInPeriod,
          name: task.memo,
          color: task.color,
          isSecret: task.secret == true,
          isImportant: task.priority == '중요',
        ));
      } else {
        // 일반 일정 처리 (기간 일정이 아닌 모든 일정)
        final dateKey = DateFormat('yyyy-MM-dd').format(task.date);
        regularTasks.putIfAbsent(dateKey, () => []);
        regularTasks[dateKey]!.add(TaskItem(
          name: task.secret == true ? '' : task.memo,
          color: task.color,
          isHoliday: false,
          isSecret: task.secret == true,
          isImportant: task.priority == '중요',
          isPeriod: false, // 단일 일정
        ));
      }
    }
    
    // 기간 일정을 레이어별로 그룹화
    if (allPeriodSegments.isNotEmpty) {
      periodTaskGroups.add(PeriodTaskGroup(periods: allPeriodSegments));
    }
    
    return ProcessedTaskData(
      regularTasks: regularTasks,
      periodTasks: periodTaskGroups,
    );
  }

  // 헬퍼 메서드들
  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return now.year == day.year && now.month == day.month && now.day == day.day;
  }

  bool _isSelected(DateTime day) {
    return widget.selectedDay.year == day.year && 
           widget.selectedDay.month == day.month && 
           widget.selectedDay.day == day.day;
  }

  bool _isHoliday(DateTime day) {
    final dateKey = DateFormat('yyyy-MM-dd').format(day);
    final holidayNames = koreanHolidays[dateKey];
    return holidayNames != null && holidayNames.isNotEmpty;
  }

  Color _getDayTextColor(DateTime day, bool isCurrentMonth, bool isHoliday) {
    if (isHoliday) return Colors.red;
    if (!isCurrentMonth) return AppColors.subText;
    if (day.weekday == DateTime.sunday) return Colors.red;
    if (day.weekday == DateTime.saturday) return Colors.blue;
    return AppColors.text;
  }

  // 터치 이벤트 핸들러들
  void _onLongPressStart(DateTime day) {
    setState(() {
      _isLongPressActive = true;
      _isDragging = true;
      _dragStartDate = day;
      _dragEndDate = day;
      _selectedDates = {day};
    });
    
    widget.onDragStateChanged?.call(true);
    HapticFeedback.mediumImpact();
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_isDragging && _isLongPressActive && _dragStartDate != null) {
      final dayAtPosition = _getDayAtPosition(event.position);
      if (dayAtPosition != null && !_isSameDay(_dragEndDate!, dayAtPosition)) {
        setState(() {
          _dragEndDate = dayAtPosition;
          _selectedDates = _getDateRange(_dragStartDate!, dayAtPosition);
        });
      }
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_isDragging && _isLongPressActive && _dragStartDate != null && _dragEndDate != null) {
      final startDate = _dragStartDate!.isBefore(_dragEndDate!) ? _dragStartDate! : _dragEndDate!;
      final endDate = _dragStartDate!.isBefore(_dragEndDate!) ? _dragEndDate! : _dragStartDate!;
      
      if (!_isSameDay(startDate, endDate)) {
        showDialog(
          context: context,
          builder: (_) => CalendarTaskDialog(
            selectedDate: startDate,
            initialEndDate: endDate,
            initialTaskType: TaskTypeModel.period,
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (_) => CalendarTaskDialog(selectedDate: startDate),
        );
      }
    }

    setState(() {
      _isDragging = false;
      _isLongPressActive = false;
      _dragStartDate = null;
      _dragEndDate = null;
      _selectedDates.clear();
    });
    
    widget.onDragStateChanged?.call(false);
  }

  DateTime? _getDayAtPosition(Offset globalPosition) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;
    
    final localPosition = renderBox.globalToLocal(globalPosition);
    
    final calendarStartX = 8.w;
    final calendarWidth = MediaQuery.of(context).size.width - 16.w;
    final cellWidth = calendarWidth / 7;
    
    final relativeX = localPosition.dx - calendarStartX;
    if (relativeX < 0 || relativeX > calendarWidth) return null;
    
    final cellIndex = (relativeX / cellWidth).floor();
    if (cellIndex < 0 || cellIndex >= 7) return null;
    
    final relativeY = localPosition.dy;
    final weekHeight = 125.h;
    final weekIndex = (relativeY / weekHeight).floor();
    
    final dayIndex = weekIndex * 7 + cellIndex;
    
    if (dayIndex >= 0 && dayIndex < _paddedDays.length) {
      return _paddedDays[dayIndex];
    }
    
    return null;
  }

  Set<DateTime> _getDateRange(DateTime start, DateTime end) {
    final startDate = start.isBefore(end) ? start : end;
    final endDate = start.isBefore(end) ? end : start;
    
    final Set<DateTime> dates = {};
    DateTime current = startDate;
    
    while (current.isBefore(endDate) || _isSameDay(current, endDate)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    return dates;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

// 데이터 클래스들
class ProcessedTaskData {
  final Map<String, List<TaskItem>> regularTasks;
  final List<PeriodTaskGroup> periodTasks;

  ProcessedTaskData({
    required this.regularTasks,
    required this.periodTasks,
  });
}

class TaskItem {
  final String name;
  final Color color;
  final bool isHoliday;
  final bool isSecret;
  final bool isImportant;
  final bool isPeriod;

  TaskItem({
    required this.name,
    required this.color,
    required this.isHoliday,
    required this.isSecret,
    required this.isImportant,
    this.isPeriod = false,
  });
}

class PeriodTaskGroup {
  final List<PeriodTaskSegment> periods;

  PeriodTaskGroup({required this.periods});
}

class PeriodTaskSegment {
  final List<DateTime> dates;
  final String name;
  final Color color;
  final bool isSecret;
  final bool isImportant;

  PeriodTaskSegment({
    required this.dates,
    required this.name,
    required this.color,
    required this.isSecret,
    required this.isImportant,
  });

  String get displayText => isSecret ? '' : name;
  bool get isEmpty => dates.isEmpty;

  factory PeriodTaskSegment.empty() => PeriodTaskSegment(
    dates: [],
    name: '',
    color: Colors.transparent,
    isSecret: false,
    isImportant: false,
  );
}

class DateRange {
  final int startIndex;
  final int endIndex;

  DateRange(this.startIndex, this.endIndex);
}