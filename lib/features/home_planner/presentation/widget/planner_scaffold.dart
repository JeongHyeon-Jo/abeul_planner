// features/home_planner/presentation/widget/planner_scaffold.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/onboarding/global_onboarding_provider.dart';
import 'package:abeul_planner/core/onboarding/onboarding_overlay.dart';
import 'package:abeul_planner/core/onboarding/onboarding_state.dart';

class PlannerScaffold extends ConsumerStatefulWidget {
  final Widget child;

  const PlannerScaffold({super.key, required this.child});

  @override
  ConsumerState<PlannerScaffold> createState() => _PlannerScaffoldState();
}

class _PlannerScaffoldState extends ConsumerState<PlannerScaffold> {
  int _tabIndex = 2;
  final GlobalKey _bottomNavKey = GlobalKey();

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

  void _handleOnboardingNext() {
    ref.read(globalOnboardingProvider.notifier).nextStep();
  }

  void _handleOnboardingPrevious() {
    ref.read(globalOnboardingProvider.notifier).previousStep();
  }

  void _handleOnboardingSkip() {
    final onboardingState = ref.read(globalOnboardingProvider);
    ref.read(onboardingProvider.notifier).completeOnboarding(onboardingState.screenKey);
    ref.read(globalOnboardingProvider.notifier).skipOnboarding();
  }

  void _handleOnboardingComplete() {
    final onboardingState = ref.read(globalOnboardingProvider);
    ref.read(onboardingProvider.notifier).completeOnboarding(onboardingState.screenKey);
    ref.read(globalOnboardingProvider.notifier).completeOnboarding();
  }

  // 바텀 네비게이션 키를 제공하는 메서드
  void provideBottomNavKey() {
    final currentState = ref.read(globalOnboardingProvider);
    if (currentState.isActive && currentState.bottomNavKey == null) {
      ref.read(globalOnboardingProvider.notifier).startOnboarding(
        steps: currentState.steps,
        screenKey: currentState.screenKey,
        scrollController: currentState.scrollController,
        bottomNavKey: _bottomNavKey,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final onboardingState = ref.watch(globalOnboardingProvider);

    // 온보딩이 활성화되어 있고 bottomNavKey가 필요한 경우 제공
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provideBottomNavKey();
    });

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
      child: Stack(
        children: [
          Scaffold(
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
            bottomNavigationBar: Material(
              key: _bottomNavKey, // GlobalKey 추가
              elevation: 8,
              child: SafeArea(
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
                      BottomNavigationBarItem(icon: Icon(Icons.today), label: '일상'),
                      BottomNavigationBarItem(icon: Icon(Icons.calendar_view_week), label: '주간'),
                      BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '종합'),
                      BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: '달력'),
                      BottomNavigationBarItem(icon: Icon(Icons.settings), label: '메뉴'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 글로벌 온보딩 오버레이
          if (onboardingState.isActive)
            OnboardingOverlay(
              steps: onboardingState.steps,
              currentStep: onboardingState.currentStep,
              onNext: _handleOnboardingNext,
              onPrevious: _handleOnboardingPrevious,
              onSkip: _handleOnboardingSkip,
              onComplete: _handleOnboardingComplete,
              scrollController: onboardingState.scrollController,
            ),
        ],
      ),
    );
  }
}