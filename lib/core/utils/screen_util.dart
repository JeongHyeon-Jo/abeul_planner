import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 앱 전체에서 사용할 ScreenUtil 초기화 위젯
class ResponsiveInitializer extends StatelessWidget {
  final Widget Function(BuildContext) builder;

  const ResponsiveInitializer({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;

        // 태블릿 기준 너비: 600 이상
        final isTablet = screenWidth >= 600;

        // 태블릿용 디자인 사이즈 예: 600x960
        final targetDesignSize = isTablet
            ? const Size(600, 960)
            : const Size(390, 844);

        return ScreenUtilInit(
          designSize: targetDesignSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, _) => builder(context),
        );
      },
    );
  }
}
