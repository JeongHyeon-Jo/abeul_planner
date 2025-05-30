// planner_scaffold.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:abeul_planner/core/styles/color.dart';

class PlannerScaffold extends StatefulWidget {
  final Widget child;

  const PlannerScaffold({super.key, required this.child});

  @override
  State<PlannerScaffold> createState() => _PlannerScaffoldState();
}

class _PlannerScaffoldState extends State<PlannerScaffold> {
  int _tabIndex = 2;

  // 각 탭에 대응되는 라우트 경로
  final List<String> _routes = [
    '/daily',
    '/weekly',
    '/home',
    '/calendar',
    '/settings',
  ];

  // 탭 선택 시 호출
  void _onItemTapped(int tabIndex) {
    setState(() {
      _tabIndex = tabIndex;
    });
    context.go(_routes[tabIndex]);
  }

  @override
  Widget build(BuildContext context) {
    // 태블릿 기준: shortestSide ≥ 600
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    // 디바이스 종류에 따라 크기 조정
    final bottomNavHeight = isTablet ? 90.0 : 70.h;
    final fabOffsetY = isTablet ? 45.0 : 32.h;
    final fabIconSize = isTablet ? 50.0 : 32.sp;
    final fabSize = isTablet ? 70.0 : 56.0;
    final navIconSize = isTablet ? 32.0 : 24.sp;
    final navFontSize = isTablet ? 16.0 : 12.sp;

    return Scaffold(
      body: widget.child,

      // 가운데 플로팅 홈 버튼
      floatingActionButton: Transform.translate(
        offset: Offset(0, fabOffsetY),
        child: SizedBox(
          width: fabSize,
          height: fabSize,
          child: FloatingActionButton(
            onPressed: () => _onItemTapped(2),
            backgroundColor: AppColors.primary,
            shape: const CircleBorder(),
            child: Icon(Icons.home, size: fabIconSize),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 하단 네비게이션 바
      bottomNavigationBar: SizedBox(
        height: bottomNavHeight,
        child: BottomNavigationBar(
          currentIndex: _tabIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.subText,
          showUnselectedLabels: true,
          selectedLabelStyle: TextStyle(fontSize: navFontSize, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: navFontSize),
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.check_circle, size: navIconSize), label: '일상'),
            BottomNavigationBarItem(icon: Icon(Icons.view_week, size: navIconSize), label: '주간'),
            BottomNavigationBarItem(icon: Icon(Icons.dashboard, size: navIconSize), label: '종합'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today, size: navIconSize), label: '달력'),
            BottomNavigationBarItem(icon: Icon(Icons.settings, size: navIconSize), label: '설정'),
          ],
        ),
      ),
    );
  }
}
