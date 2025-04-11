// lib/core/widget/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:abeul_planner/core/color.dart';
import 'package:abeul_planner/core/text_styles.dart';

/// 앱 전체에서 재사용 가능한 커스텀 앱바
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // 앱바 타이틀
  final Widget? leading; // 왼쪽 위젯 (뒤로가기 또는 커스텀)
  final List<Widget>? actions; // 오른쪽 위젯들
  final bool isTransparent; // 배경 투명 여부

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.isTransparent = false, // 기본은 일반 앱바 스타일
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:
          isTransparent ? Colors.transparent : AppColors.primary, // 배경 색상
      elevation: isTransparent ? 0 : 1, // 투명 시 그림자 제거

      centerTitle: true,
      automaticallyImplyLeading: false, // 기본 뒤로가기 제거

      leading: leading ?? // leading 지정 없을 경우 기본 뒤로가기 제공
          IconButton(
            icon: Icon(Icons.arrow_back,
                color: isTransparent ? AppColors.text : Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),

      title: Text(
        title,
        style: AppTextStyles.title.copyWith(
          color: isTransparent ? AppColors.text : Colors.white,
        ),
      ),

      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
