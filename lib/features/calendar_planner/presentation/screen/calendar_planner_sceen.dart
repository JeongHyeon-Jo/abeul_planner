// calendar_planner_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/core/color.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/provider/calendar_task_provider.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/widget/calendar_task_dialog.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/widget/calendar_widget.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/widget/calendar_task_list.dart';

class CalendarPlannerScreen extends ConsumerStatefulWidget {
  const CalendarPlannerScreen({super.key});

  @override
  ConsumerState<CalendarPlannerScreen> createState() => _CalendarPlannerScreenState();
}

class _CalendarPlannerScreenState extends ConsumerState<CalendarPlannerScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _openAddTaskDialog() {
    showDialog(
      context: context,
      builder: (_) => CalendarTaskDialog(selectedDate: _selectedDay!),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          CalendarWidget(
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            onDaySelected: _onDaySelected,
          ),
          CalendarTaskList(tasks: tasksForSelectedDay),
        ],
      ),
    );
  }
}