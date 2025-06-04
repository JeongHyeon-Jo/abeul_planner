// planner_scaffold.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  final List<String> _routes = [
    '/daily',
    '/weekly',
    '/home',
    '/calendar',
    '/settings',
  ];

  void _onItemTapped(int tabIndex) {
    setState(() {
      _tabIndex = tabIndex;
    });
    context.go(_routes[tabIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_tabIndex != 2) {
          _onItemTapped(2);
        } else {
          final shouldExit = await showDialog<bool>(
                context: context,
                builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.exit_to_app, color: AppColors.primary, size: 70.sp),
                        SizedBox(height: 16.h),
                        Text('앱을 종료할까요?', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        SizedBox(height: 12.h),
                        Text(
                          '정말로 앱을 종료하시겠습니까?',
                          style: TextStyle(fontSize: 14.sp, color: AppColors.subText),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightPrimary,
                                foregroundColor: AppColors.text,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                child: Text('취소', style: TextStyle(fontSize: 14.sp)),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                SystemNavigator.pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                child: Text('종료', style: TextStyle(fontSize: 14.sp)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ) ??
              false;

          if (shouldExit && context.mounted) {
            Navigator.of(context).maybePop();
          }
        }
      },
      child: Scaffold(
        body: widget.child,
        floatingActionButton: SafeArea(
          child: Transform.translate(
            offset: Offset(0, isTablet ? 45.0 : 32.h),
            child: SizedBox(
              width: isTablet ? 70.0 : 56.0,
              height: isTablet ? 70.0 : 56.0,
              child: FloatingActionButton(
                onPressed: () => _onItemTapped(2),
                backgroundColor: AppColors.primary,
                shape: const CircleBorder(),
                child: Icon(Icons.home, size: isTablet ? 50.0 : 32.sp),
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: SafeArea(
          child: SizedBox(
            height: isTablet ? 90.0 : 70.h,
            child: BottomNavigationBar(
              currentIndex: _tabIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.subText,
              showUnselectedLabels: true,
              selectedLabelStyle: TextStyle(fontSize: isTablet ? 16.0 : 12.sp, fontWeight: FontWeight.bold),
              unselectedLabelStyle: TextStyle(fontSize: isTablet ? 16.0 : 12.sp),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: '일상'),
                BottomNavigationBarItem(icon: Icon(Icons.view_week), label: '주간'),
                BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '종합'),
                BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '달력'),
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: '메뉴'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
