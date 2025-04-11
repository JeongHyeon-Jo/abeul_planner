// weekly_planner_screen.dart
import 'package:flutter/material.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/core/text_styles.dart';
import 'package:abeul_planner/core/color.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 48.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomAppBar(
              title: '주간 플래너',
              isTransparent: true,
            ),
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                tabs: days.map((day) => Tab(text: day)).toList(),
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.subText,
                indicatorColor: AppColors.primary,
              ),
            ),
          ],
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