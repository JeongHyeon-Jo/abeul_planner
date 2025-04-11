import 'package:flutter/material.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/core/text_styles.dart';
import 'package:abeul_planner/core/color.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: '설정',
        isTransparent: true,
      ),
      body: ListView(
        children: [
          // 알림 설정
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('알림 설정', style: AppTextStyles.body),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),

          // 테마 설정
          ListTile(
            leading: Icon(Icons.color_lens),
            title: Text('테마 설정', style: AppTextStyles.body),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),

          // 앱 정보
          ListTile(
            leading: Icon(Icons.info),
            title: Text('앱 정보', style: AppTextStyles.body),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ],
      ),
    );
  }
}
