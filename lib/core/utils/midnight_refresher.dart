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

  // 자정 알림 다이얼로그 표시 (디자인 개선)
  static Future<void> _showMidnightDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.nightlight_round, color: Colors.indigo, size: 36),
              const SizedBox(height: 16),
              Text(
                "자정이 지나 앱이 새로고침됩니다",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ],
          ),
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
