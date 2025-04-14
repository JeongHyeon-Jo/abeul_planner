// calendar_planner_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/core/color.dart';
import 'package:abeul_planner/core/text_styles.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/provider/calendar_task_provider.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/widget/calendar_task_form.dart';

class CalendarPlannerScreen extends ConsumerStatefulWidget {
  const CalendarPlannerScreen({super.key});

  @override
  ConsumerState<CalendarPlannerScreen> createState() => _CalendarPlannerScreenState();
}

class _CalendarPlannerScreenState extends ConsumerState<CalendarPlannerScreen> {
  DateTime _focusedDay = DateTime.now(); // 현재 포커스된 날짜
  DateTime? _selectedDay; // 선택된 날짜

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay; // 초기 선택 날짜 설정
  }

  /// 날짜 선택 시 호출되는 함수
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  /// 일정 추가 다이얼로그 열기
  void _openAddTaskDialog() {
    showDialog(
      context: context,
      builder: (_) => CalendarTaskForm(selectedDate: _selectedDay!),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 선택된 날짜에 해당하는 일정 불러오기
    final tasksForSelectedDay = ref.watch(calendarTaskProvider.notifier)
        .getTasksForDate(_selectedDay!);

    return Scaffold(
      appBar: CustomAppBar(
        title: '달력 플래너',
        isTransparent: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTaskDialog,
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // 테이블 캘린더 위젯
          TableCalendar(
            locale: 'ko_KR',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            daysOfWeekHeight: 35.h,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              defaultTextStyle: AppTextStyles.body,
              weekendTextStyle: AppTextStyles.body,
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: AppTextStyles.body.copyWith(fontSize: 14.sp),
              weekendStyle: AppTextStyles.body.copyWith(fontSize: 14.sp),
            ),
          ),
          SizedBox(height: 10.h),

          // 일정 목록
          Expanded(
            child: tasksForSelectedDay.isEmpty
                ? Center(child: Text('해당 날짜에 등록된 일정이 없어요.', style: AppTextStyles.body))
                : ListView.builder(
                    itemCount: tasksForSelectedDay.length,
                    itemBuilder: (context, index) {
                      final task = tasksForSelectedDay[index];
                      return ListTile(
                        leading: const Icon(Icons.event_note),
                        title: Text('${task.time} - ${task.memo}', style: AppTextStyles.body),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
