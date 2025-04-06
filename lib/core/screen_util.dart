import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 앱 전체에서 사용할 ScreenUtil 초기화 위젯
class ResponsiveInitializer extends StatelessWidget {
  final Widget child;

  const ResponsiveInitializer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // 기준 디바이스 사이즈 (ex. iPhone 13 Pro)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => child!,
      child: child,
    );
  }
}
