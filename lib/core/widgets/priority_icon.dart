// lib/core/widgets/priority_icon.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/color.dart';

/// 중요도에 따라 아이콘을 반환하는 위젯 함수
Widget getPriorityIcon(String priority) {
  switch (priority) {
    case '중요':
      return Icon(Icons.priority_high, color: Colors.red, size: 20.sp);
    case '보통':
      return Icon(Icons.adjust, color: Colors.orange, size: 20.sp);
    case '낮음':
    default:
      return Icon(Icons.arrow_downward, color: AppColors.lowPriority, size: 20.sp);
  }
}
