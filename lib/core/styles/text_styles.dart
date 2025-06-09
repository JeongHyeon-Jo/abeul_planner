// text_styles.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/styles/color.dart';

// 앱 전체에서 사용할 텍스트 스타일 모음
class AppTextStyles {
  // 가장 큰 제목 (예: 인트로 화면, 로고 옆 등)
  static TextStyle get displayLarge => TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.text,
      );

  // 큰 제목 (예: 화면 타이틀)
  static TextStyle get headline => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.text,
      );

  // 중간 제목 (예: 카드 제목)
  static TextStyle get headlineSmall => TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      );

  // 일반 타이틀 (예: 섹션 타이틀)
  static TextStyle get title => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      );

  // 본문 텍스트
  static TextStyle get body => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.text,
  );

  // 작은 본문 텍스트
  static TextStyle get bodySmall => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.text,
  );

  // 설명 텍스트 (보조 정보)
  static TextStyle get caption => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.subText,
  );

  // 아주 작은 설명용 텍스트
  static TextStyle get captionSmall => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.subText,
  );

  // 라벨, 태그 텍스트
  static TextStyle get overline => TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.subText,
  );

  // 버튼 텍스트
  static TextStyle get button => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
