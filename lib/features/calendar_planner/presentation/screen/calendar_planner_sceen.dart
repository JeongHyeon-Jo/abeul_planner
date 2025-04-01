import 'package:flutter/material.dart';

class CalendarPlannerScreen extends StatelessWidget {
  const CalendarPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('캘린더 플래너'),
      ),
      body: const Center(
        child: Text('여기는 메모 기반의 캘린더 플래너입니다.\n날짜에 맞춰 메모를 추가할 수 있어요.'),
      ),
    );
  }
}
