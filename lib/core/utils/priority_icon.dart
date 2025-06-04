// lib/core/widgets/utils/priority_icon.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:abeul_planner/core/styles/color.dart';

// 중요도에 따라 아이콘을 반환하는 위젯 함수
Widget getPriorityIcon(String priority) {
  switch (priority) {
    case '중요':
      return Icon(LucideIcons.alertTriangle, color: Colors.red, size: 21.sp);
    case '보통':
      return Icon(LucideIcons.minusCircle, color: Colors.orange, size: 20.sp);
    case '낮음':
    default:
      return Icon(LucideIcons.square, color: AppColors.lowPriority, size: 20.sp);
  }
}
