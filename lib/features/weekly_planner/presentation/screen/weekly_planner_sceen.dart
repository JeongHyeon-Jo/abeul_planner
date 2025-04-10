// weekly_planner_sceen.dart
import 'package:flutter/material.dart';
// widget
import 'package:abeul_planner/features/weekly_planner/presentation/widget/weekly_tab_content.dart';

class WeeklyPlannerScreen extends StatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  State<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final List<String> days = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: days.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('요일 플래너'),
        bottom: TabBar(
          controller: _tabController,
          tabs: days.map((day) => Tab(text: day)).toList(),
          isScrollable: false,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: days.map((day) {
          return WeeklyTabContent(day: day); // 요일별 컨텐츠 위젯
        }).toList(),
      ),
    );
  }
}
