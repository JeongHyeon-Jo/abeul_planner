// lib/core/widgets/utils/priority_icon.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';

// 중요도에 따라 아이콘을 반환하는 위젯 함수
Widget? getPriorityIcon(String? priority) {
  if (priority == '중요') {
    return Icon(LucideIcons.alertTriangle, color: Colors.red, size: 20.sp);
  }
  return null; // 나머지는 표시 안 함
}