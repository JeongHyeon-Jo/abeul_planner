// lib/core/widget/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:abeul_planner/core/color.dart';
import 'package:abeul_planner/core/text_styles.dart';

/// 앱 전체에서 재사용 가능한 커스텀 앱바
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title; // 앱바 타이틀을 위젯으로 변경
  final Widget? leading; // 왼쪽 위젯 (필요할 경우 직접 지정)
  final List<Widget>? actions; // 오른쪽 위젯들
  final bool isTransparent; // 배경 투명 여부

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.isTransparent = false, // 기본은 일반 스타일
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      backgroundColor:
          isTransparent ? Colors.transparent : AppColors.primary, // 배경 색상
      elevation: isTransparent ? 0 : 1, // 투명 시 그림자 제거
      centerTitle: true,
      automaticallyImplyLeading: false, // 자동 뒤로가기 제거
      leading: leading, // 기본 뒤로가기 제공 안 함
      title: title, // 텍스트 대신 위젯 전체를 타이틀로 사용
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}