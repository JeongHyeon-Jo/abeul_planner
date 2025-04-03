import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: const [
          // 알림 설정
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('알림 설정'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),

          // 테마 설정
          ListTile(
            leading: Icon(Icons.color_lens),
            title: Text('테마 설정'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),

          // 앱 정보
          ListTile(
            leading: Icon(Icons.info),
            title: Text('앱 정보'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ],
      ),
    );
  }
}
