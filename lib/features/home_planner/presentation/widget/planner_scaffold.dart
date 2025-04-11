import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:abeul_planner/core/color.dart';

/// 🧭 아블 플래너의 공통 레이아웃 (하단 네비 + 플로팅 버튼)
class PlannerScaffold extends StatefulWidget {
  final Widget child; // 각 페이지의 화면

  const PlannerScaffold({super.key, required this.child});

  @override
  State<PlannerScaffold> createState() => _PlannerScaffoldState();
}

class _PlannerScaffoldState extends State<PlannerScaffold> {
  int _tabIndex = 2; // 시작은 홈 플래너

  /// 탭 index에 따른 라우트 경로 리스트
  final List<String> _routes = [
    '/daily',     // 0: 일상 플래너
    '/weekly',    // 1: 주간 플래너
    '/home',      // 2: 종합 플래너
    '/calendar',  // 3: 달력 플래너
    '/settings',  // 4: 설정
  ];

  /// 탭 클릭 시 호출되는 함수
  void _onItemTapped(int tabIndex) {
    setState(() {
      _tabIndex = tabIndex;
    });
    context.go(_routes[tabIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,

      /// 🔘 가운데 플로팅 버튼 (종합 플래너)
      floatingActionButton: Transform.translate(
        offset: Offset(0, 32.h),
        child: FloatingActionButton(
          onPressed: () => _onItemTapped(2),
          backgroundColor: AppColors.primary,
          shape: const CircleBorder(),
          child: Icon(Icons.home, size: 32.sp),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      /// 하단 네비게이션 바
      bottomNavigationBar: SizedBox(
        height: 70.h,
        child: BottomNavigationBar(
          currentIndex: _tabIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.subText,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: '일상'),
            BottomNavigationBarItem(icon: Icon(Icons.view_week), label: '주간'),
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '종합'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '달력'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
          ],
        ),
      ),
    );
  }
}