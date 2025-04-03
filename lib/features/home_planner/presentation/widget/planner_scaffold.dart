import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlannerScaffold extends StatefulWidget {
  final Widget child;

  const PlannerScaffold({super.key, required this.child});

  @override
  State<PlannerScaffold> createState() => _PlannerScaffoldState();
}

class _PlannerScaffoldState extends State<PlannerScaffold> {
  int _currentIndex = 2;

  final List<String> _routes = [
    '/daily',
    '/weekly',
    '/home',
    '/calendar',
    '/settings',
  ];

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 12), // 아래로 12px 이동
        child: FloatingActionButton(
          onPressed: () => _onItemTapped(2),
          backgroundColor: Colors.blue,
          shape: const CircleBorder(),
          child: const Icon(Icons.dashboard),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // BottomAppBar + BottomNavigationBar 구조 분리
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: SizedBox(
          height: 60,
          child: SafeArea(
            top: false,
            child: BottomNavigationBar(
              currentIndex:
                  _currentIndex > 2 ? _currentIndex - 1 : _currentIndex,
              onTap: (index) {
                final actualIndex = index >= 2 ? index + 1 : index;
                _onItemTapped(actualIndex);
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: '데일리'),
                BottomNavigationBarItem(icon: Icon(Icons.view_week), label: '위클리'),
                BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '캘린더'),
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
