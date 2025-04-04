import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlannerScaffold extends StatefulWidget {
  final Widget child;

  const PlannerScaffold({super.key, required this.child});

  @override
  State<PlannerScaffold> createState() => _PlannerScaffoldState();
}

class _PlannerScaffoldState extends State<PlannerScaffold> {
  int _tabIndex = 2;  // BottomNavigationBar 기준 index

  final List<String> _routes = [
    '/daily',     // 0
    '/weekly',    // 1
    '/home',      // 2 (플로팅 버튼용)
    '/calendar',  // 3
    '/settings',  // 4
  ];

  /// 바텀 네비 index → 페이지 index로 변환
  int _tabToPage(int tabIndex) {
    if (tabIndex < 2) return tabIndex;
    if (tabIndex == 3) return 3;
    if (tabIndex == 4) return 4;
    throw Exception('Invalid tab index');
  }

  void _onItemTapped(int tabIndex) {
    if (tabIndex == 2) return; // 가운데 버튼은 무시

    final pageIndex = _tabToPage(tabIndex);
    setState(() {
      _tabIndex = tabIndex;
    });
    context.go(_routes[pageIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,

      /// 가운데 떠 있는 플로팅 버튼 (종합 플래너)
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 30),
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              _tabIndex = 2;
            });
            context.go(_routes[2]);
          },
          backgroundColor: Colors.blue,
          shape: const CircleBorder(),
          child: const Icon(Icons.dashboard),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      /// 바텀 네비게이션바
      bottomNavigationBar: SizedBox(
        height: 70,
        child: BottomNavigationBar(
          currentIndex: _tabIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: '데일리'),
            BottomNavigationBarItem(icon: Icon(Icons.view_week), label: '위클리'),
            BottomNavigationBarItem(icon: SizedBox.shrink(), label: ''), // 가운데 버튼 자리
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '캘린더'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
          ],
        ),
      ),
    );
  }
}
