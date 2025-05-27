// theme.dart
import 'package:flutter/material.dart';
import 'package:abeul_planner/core/styles/color.dart';

/// 앱 전역에서 사용하는 라이트 테마 정의
final ThemeData appLightTheme = ThemeData(
  useMaterial3: true,

  // 색상 체계 정의 (ColorScheme)
  colorScheme: ColorScheme(
    brightness: Brightness.light, // 밝은 테마 기준
    primary: AppColors.primary, // 주요 색상 (버튼, 앱바 등)
    onPrimary: Colors.white, // 주요 색상 위에 올 텍스트 색상
    secondary: AppColors.accent, // 보조 색상 (포인트 요소)
    onSecondary: Colors.white, // 보조 색상 위 텍스트
    surface: AppColors.background, // 카드, 다이얼로그 등 표면 배경색
    onSurface: AppColors.text, // 표면 위 텍스트 색상
    error: Colors.red, // 오류 시 색상
    onError: Colors.white, // 오류 배경 위 텍스트 색상
  ),

  // Scaffold 전체 배경색
  scaffoldBackgroundColor: AppColors.background,

  // 텍스트 테마
  textTheme: ThemeData.light().textTheme.apply(
        bodyColor: AppColors.text, // 일반 텍스트
        displayColor: AppColors.text, // 제목 등 디스플레이 텍스트
      ),

  // 앱바 테마
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.primary, // 앱바 배경색
    foregroundColor: Colors.white, // 앱바 텍스트/아이콘 색상
    elevation: 0,
  ),

  // 플로팅 액션 버튼 테마
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
  ),

  // 엘리베이티드 버튼 테마
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary, // 버튼 배경
      foregroundColor: Colors.white, // 버튼 텍스트
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // 버튼 모서리 둥글기
      ),
    ),
  ),
);
