// planner_home_screen.dart
import 'package:flutter/material.dart';

/// 종합 플래너 화면 (홈 플래너)
class PlannerHomeScreen extends StatelessWidget {
  const PlannerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('아블 플래너'),
      ),
      body: const Center(
        child: Text('여기에 종합 플래너 화면이 들어갈 예정입니다.'),
      ),
    );
  }
}
