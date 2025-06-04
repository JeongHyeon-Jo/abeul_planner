// record_select_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';

class RecordSelectScreen extends StatelessWidget {
  const RecordSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '기록 보기',
          style: AppTextStyles.title.copyWith(color: AppColors.text),
        ),
        isTransparent: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildRecordCard(
              context,
              icon: Icons.today,
              title: '일상 플래너 기록',
              route: '/records/daily',
            ),
            SizedBox(height: 12.h),
            _buildRecordCard(
              context,
              icon: Icons.view_week,
              title: '주간 플래너 기록',
              route: '/records/weekly',
            ),
            SizedBox(height: 12.h),
            _buildRecordCard(
              context,
              icon: Icons.calendar_month,
              title: '달력 플래너 기록',
              route: '/records/calendar',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.primary),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 28.sp, color: AppColors.primary),
            SizedBox(width: 16.w),
            Text(title, style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}
