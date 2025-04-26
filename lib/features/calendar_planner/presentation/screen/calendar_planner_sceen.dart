// calendar_planner_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/provider/calendar_task_provider.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/widget/calendar_task_dialog.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/widget/calendar_widget.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/widget/calendar_task_list.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';

/// 캘린더 플래너 메인 화면
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

  /// 날짜 선택 시 상태 갱신
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  /// 일정 추가 다이얼로그 표시
  void _openAddTaskDialog() {
    showDialog(
      context: context,
      builder: (_) => CalendarTaskDialog(selectedDate: _selectedDay!),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 선택된 날짜에 해당하는 일정 가져오기
    final tasksForSelectedDay = ref.watch(calendarTaskProvider.notifier)
        .getTasksForDate(_selectedDay!);
    final currentYear = _focusedDay.year;

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          '${_focusedDay.year}년',
          style: AppTextStyles.title.copyWith(color: AppColors.text),
        ),
        isTransparent: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppColors.text, size: 27.sp),
            onPressed: () {
              // 검색 기능은 나중에
            },
          ),
        ],
      ),
      floatingActionButton: Transform.translate(
        offset: Offset(-6.w, -6.h),
        child: FloatingActionButton(
          onPressed: _openAddTaskDialog, // 일정 추가 버튼
          backgroundColor: AppColors.accent,
          child: const Icon(Icons.add),
        ),
      ),
      body: Column(
        children: [
          // 달력 위젯
          CalendarWidget(
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            onDaySelected: _onDaySelected,
          ),
          // 선택된 날짜의 일정 리스트
          CalendarTaskList(tasks: tasksForSelectedDay),
        ],
      ),
    );
  }
}
