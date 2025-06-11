// onboarding_overlay.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';

class OnboardingOverlay extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onNext;

  const OnboardingOverlay({
    super.key,
    required this.title,
    required this.description,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ModalBarrier(color: Colors.black.withAlpha((0.6 * 255).toInt()), dismissible: false),
        Center(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: AppTextStyles.title),
                  SizedBox(height: 12.h),
                  Text(description, style: AppTextStyles.body),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    onPressed: onNext,
                    child: Text('다음', style: AppTextStyles.button),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
