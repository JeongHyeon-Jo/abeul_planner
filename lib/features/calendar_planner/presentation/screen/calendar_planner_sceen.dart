import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPlannerScreen extends StatefulWidget {
  const CalendarPlannerScreen({super.key});

  @override
  State<CalendarPlannerScreen> createState() => _CalendarPlannerScreenState();
}

class _CalendarPlannerScreenState extends State<CalendarPlannerScreen> {
  DateTime _focusedDay = DateTime.now();        // 현재 보여지는 날짜
  DateTime? _selectedDay;                       // 선택한 날짜

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('캘린더 플래너'),
      ),
      body: Center(
        child: TableCalendar(
          locale: 'ko_KR',                     // 한국어 설정
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,         // 포맷 버튼 제거 (월간/주간 전환)
            titleCentered: true,                // 달 제목 가운데 정렬
          ),
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
