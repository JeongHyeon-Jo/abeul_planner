// settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/features/settings/presentation/widget/settings_tile.dart';
import 'package:abeul_planner/features/auth/presentation/provider/user_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final userNotifier = ref.read(userProvider.notifier);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          '설정',
          style: AppTextStyles.title.copyWith(color: AppColors.text),
        ),
        isTransparent: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.primary, width: 1.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: AppColors.accent, size: 24.sp),
                    SizedBox(width: 8.w),
                    Text('완료된 일정 아래로 정렬', style: AppTextStyles.body),
                  ],
                ),
                value: user.autoSortCompleted,
                onChanged: userNotifier.toggleAutoSortCompleted,
                activeColor: AppColors.accent,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
              ),
              Divider(height: 1.h, color: AppColors.primary),
              SettingsTile(
                icon: Icons.today,
                title: '일상 플래너 기록',
                onTap: () => context.push('/records/daily'),
              ),
              Divider(height: 1.h, color: AppColors.primary),
              SettingsTile(
                icon: Icons.view_week,
                title: '주간 플래너 기록',
                onTap: () => context.push('/records/weekly'),
              ),
              Divider(height: 1.h, color: AppColors.primary),
              SettingsTile(
                icon: Icons.calendar_month,
                title: '달력 플래너 기록',
                onTap: () => context.push('/records/calendar'),
              ),
              Divider(height: 1.h, color: AppColors.primary),
              SettingsTile(
                icon: Icons.info,
                title: '앱 정보',
                onTap: () => context.push('/settings/app-info'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
