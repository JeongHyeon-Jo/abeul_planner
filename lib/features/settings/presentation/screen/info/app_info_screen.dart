// app_info_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/features/settings/presentation/screen/info/icon_credits_screen.dart';
import 'package:abeul_planner/features/settings/presentation/screen/info/privacy_policy_screen.dart';

class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({super.key});

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  String version = '';
  String buildNumber = '';

  @override
  void initState() {
    super.initState();
    _fetchAppInfo();
  }

  Future<void> _fetchAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      version = info.version;
      buildNumber = info.buildNumber;
    });
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: AppTextStyles.body)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('앱 정보', style: AppTextStyles.title.copyWith(color: AppColors.text)),
        isTransparent: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.primary, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('앱 이름', '아블 플래너 (Abeul Planner)'),
              _buildInfoRow('버전', '$version ($buildNumber)'),
              _buildInfoRow('제작자', '조아블'),
              _buildInfoRow('이메일', 'abeul_dv@example.com'),
              _buildInfoRow('기술 스택', 'Flutter, Hive, Riverpod'),
              _buildInfoRow('라이센스', 'CC BY-NC-ND 4.0 (비영리, 변경금지, 저작자 표시)'),
              SizedBox(height: 12.h),
              Text('앱 설명', style: AppTextStyles.title.copyWith(fontSize: 18.sp)),
              SizedBox(height: 6.h),
              Text(
                '아블 플래너는 일상 / 주간 / 달력 기반의 일정 관리를 통합한 스마트 플래너 앱입니다.\n'
                '공식 유튜브를 통해 기능 설명을 확인하실 수 있습니다.',
                style: TextStyle(
                  color: AppColors.actionText,
                  fontSize: 13.5.sp,
                ),
              ),
              const Spacer(),
              SizedBox(height: 16.h),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const IconCreditsScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  margin: EdgeInsets.only(top: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      '리소스 및 저작권 안내 보기',
                      style: AppTextStyles.button,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      '개인정보 처리방침 보기',
                      style: AppTextStyles.button,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
