// color.dart
import 'package:flutter/material.dart';

/// 앱 전반에서 사용하는 시그니처 색상 정의
/// 메인 컬러는 따뜻하고 친근한 느낌의 코랄 핑크 계열입니다.
class AppColors {
  /// 🌸 시그니처 메인 색상 (코랄 핑크)
  static const Color primary = Color(0xFFFF7F7F);

  /// 배경 색상 (연한 크림 톤)
  static const Color background = Color(0xFFFFFFFF);

  /// 일반 텍스트 색상
  static const Color text = Color(0xFF2D2D2D);

  /// 보조 텍스트 (설명, 비활성 텍스트 등)
  static const Color subText = Color(0xFF8D8D8D);

  /// 포인트 색상 (진한 코랄톤)
  static const Color accent = Color(0xFFFF6F61);

  /// 오늘 날짜 배경에 사용할 강조 색상 (연한 코랄 오렌지)
  static const Color highlight = Color(0xFFFF9F84);

  /// 테두리, 분리선 등에 사용하는 중립색
  static const Color divider = Color(0xFFE0E0E0);

  /// 강조용 노란색 (주의나 강조 요소에 사용 가능)
  static const Color warning = Color(0xFFFFD166);

  /// 성공/완료 상태를 나타내는 색상
  static const Color success = Color(0xFF6FCF97);

  /// 중요도 낮음 표시용 하늘색
  static const Color lowPriority = Color(0xFF81D4FA);

  /// 행동 텍스트용 강조 색상 (부드러운 검정 회색)
  static const Color actionText = Color.fromARGB(255, 54, 54, 54);
}
