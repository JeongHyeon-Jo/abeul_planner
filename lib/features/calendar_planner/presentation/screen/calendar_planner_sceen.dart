// calendar_planner_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/widget/calendar_widget.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/widget/calendar_task_list.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/widget/calendar_task_dialog.dart';

/// 캘린더 플래너 메인 화면
class CalendarPlannerScreen extends ConsumerStatefulWidget {
  const CalendarPlannerScreen({super.key});

  @override
  ConsumerState<CalendarPlannerScreen> createState() => _CalendarPlannerScreenState();
}

class _CalendarPlannerScreenState extends ConsumerState<CalendarPlannerScreen> {
  DateTime _focusedDay = DateTime.now(); // 현재 포커스된 날짜
  DateTime _selectedDay = DateTime.now(); // 선택된 날짜

  /// 날짜 선택 시 다이얼로그 열기
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    showDialog(
      context: context,
      builder: (_) => CalendarTaskList(selectedDate: selectedDay),
    );
  }

  /// 일정 추가 다이얼로그 열기
  void _openAddTaskDialog() {
    showDialog(
      context: context,
      builder: (_) => CalendarTaskDialog(selectedDate: _selectedDay),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        // 앱바 타이틀 (년도 표시)
        title: Text(
          '${_focusedDay.year}년',
          style: AppTextStyles.title.copyWith(color: AppColors.text),
        ),
        isTransparent: true,
        leading: IconButton(
          icon: const Icon(Icons.add, color: AppColors.text),
          onPressed: _openAddTaskDialog,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppColors.text, size: 27.sp),
            onPressed: () {
              // 추후 검색 기능
            },
          ),
        ],
      ),
      body: CalendarWidget(
        focusedDay: _focusedDay,
        selectedDay: _selectedDay,
        onDaySelected: _onDaySelected,
      ),
    );
  }
}
