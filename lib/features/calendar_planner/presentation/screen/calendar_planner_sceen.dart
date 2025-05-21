// calendar_planner_screen.dart
// calendar_planner_screen.dart 리팩토링 버전 (삼성 캘린더 스타일 참고)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/widget/calendar_widget.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/widget/calendar_task_list.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/widget/calendar_task_dialog.dart';

/// 캘린더 플래너 메인 화면 (삼성 스타일처럼 공간을 효율적으로 구성)
class CalendarPlannerScreen extends ConsumerStatefulWidget {
  const CalendarPlannerScreen({super.key});

  @override
  ConsumerState<CalendarPlannerScreen> createState() => _CalendarPlannerScreenState();
}

class _CalendarPlannerScreenState extends ConsumerState<CalendarPlannerScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  /// 날짜 선택 시 일정 리스트 다이얼로그 열기
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
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 캘린더
            CalendarWidget(
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              onDaySelected: _onDaySelected,
            ),
          ],
        ),
      ),
    );
  }
}
