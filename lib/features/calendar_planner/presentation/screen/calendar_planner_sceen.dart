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
        title: '',
        isTransparent: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTaskDialog,
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // 캘린더 박스를 둥근 모서리와 그림자로 감쌈
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(color: AppColors.primary),
              ),
              child: Column(
                children: [
                  TableCalendar(
                    locale: 'ko_KR',
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    availableCalendarFormats: const {
                      CalendarFormat.month: '월간',
                    },
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: _onDaySelected,
                    daysOfWeekHeight: 35.h,
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false, // 포맷 전환 버튼 숨김
                      titleCentered: true,
                      titleTextStyle: AppTextStyles.title,
                      leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.text),
                      rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.text),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.primary), // 헤더 아래 선
                        ),
                      ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: AppTextStyles.body.copyWith(fontSize: 14.sp),
                      weekendStyle: AppTextStyles.body.copyWith(fontSize: 14.sp),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.primary), // 요일 아래 선
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
                ],
              ),
            ),
          ),

          // 일정 목록 박스도 동일한 스타일로 감쌈
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(color: AppColors.primary),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: SizedBox(
                  height: 260.h, // 높이 고정 또는 필요시 Flexible 대체 가능
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
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}