import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// 앱의 루트 위젯
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Abeul Planner',
      debugShowCheckedModeBanner: false, // 우측 상단 디버그 배너 제거
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true, // 머티리얼3 사용 (선택 사항)
      ),
      home: const PlannerHomeScreen(), // 홈 화면 설정
    );
  }
}

/// 플래너 홈 화면 (첫 진입 화면)
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
