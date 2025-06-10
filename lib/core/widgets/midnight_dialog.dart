// midnight_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MidnightDialog extends StatefulWidget {
  const MidnightDialog({super.key});

  @override
  State<MidnightDialog> createState() => _MidnightDialogState();
}

class _MidnightDialogState extends State<MidnightDialog> {
  @override
  void initState() {
    super.initState();

    // 2초 후 다이얼로그 닫기
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.nightlight_round, color: Colors.indigo, size: 36.sp),
            SizedBox(height: 16.h),
            Text(
              "자정이 지나 앱이 새로고침됩니다",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}
