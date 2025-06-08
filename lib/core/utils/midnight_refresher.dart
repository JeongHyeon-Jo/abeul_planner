// midnight_refresher.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

class MidnightRefresher {
  static Timer? _timer;

  // 자정 감지 시작
  static void start(BuildContext context) {
    // 중복 실행 방지
    if (_timer != null && _timer!.isActive) return;

    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = nextMidnight.difference(now);

    _timer = Timer(durationUntilMidnight, () async {
      if (!context.mounted) return;

      await _showMidnightDialog(context);

      if (context.mounted) {
        Phoenix.rebirth(context); // 앱 재시작
      }
    });
  }

  // 자정 알림 다이얼로그 표시
  static Future<void> _showMidnightDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text("자정이 지나 앱이 새로고침됩니다"),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  // 타이머 수동 취소 (필요한 경우)
  static void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
