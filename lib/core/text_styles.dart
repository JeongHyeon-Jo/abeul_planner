// text_styles.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/color.dart';

/// 앱 전체에서 사용할 텍스트 스타일 모음
class AppTextStyles {
  /// 큰 제목 (예: 화면 타이틀)
  static TextStyle get headline => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.text,
      );

  /// 중간 제목 (예: 섹션 타이틀)
  static TextStyle get title => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      );

  /// 일반 텍스트 (예: 본문)
  static TextStyle get body => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.text,
      );

  /// 보조 텍스트 (예: 설명, 회색 텍스트 등)
  static TextStyle get caption => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.subText,
      );

  /// 버튼 텍스트 스타일
  static TextStyle get button => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );
}
