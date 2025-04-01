import 'package:flutter/material.dart';

class DailyPlannerScreen extends StatelessWidget {
  const DailyPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일상 플래너'),
      ),
      body: const Center(
        child: Text('여기는 상황 기반 플래너입니다.\n예: 출근하면 스트레칭하기, 방 들어오면 책상 닦기 등'),
      ),
    );
  }
}
