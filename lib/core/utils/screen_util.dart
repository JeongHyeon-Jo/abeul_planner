// screen_util.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 앱 전체에서 사용할 ScreenUtil 초기화 위젯
class ResponsiveInitializer extends StatelessWidget {
  final Widget Function(BuildContext) builder;

  const ResponsiveInitializer({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) => builder(context),
    );
  }
}