import 'package:flutter/material.dart';

class WeeklyPlannerScreen extends StatelessWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('요일 플래너'),
      ),
      body: const Center(
        child: Text('여기는 요일별 컨셉 플래너입니다.\n예: 월요일은 배움의 날 - 영상 시청, 독서, 영어 말하기 등'),
      ),
    );
  }
}
