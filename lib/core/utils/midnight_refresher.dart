// midnight_refresher.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:abeul_planner/core/widgets/midnight_dialog.dart';
import 'package:abeul_planner/core/utils/global_navigator_key.dart';

class MidnightRefresher {
  static Timer? _timer;

  static void start() {
    if (_timer != null && _timer!.isActive) return;

    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = nextMidnight.difference(now);

    debugPrint('[MidnightRefresher] 자정까지 남은 시간: $durationUntilMidnight');

    _timer = Timer(durationUntilMidnight, () async {
      final context = globalNavigatorKey.currentContext;
      if (context == null) {
        debugPrint('[MidnightRefresher] context 없음');
        return;
      }

      debugPrint('[MidnightRefresher] 자정 도달 - 다이얼로그 호출');
      await _showMidnightDialog(context);

      await Future.delayed(const Duration(milliseconds: 300));
      debugPrint('[MidnightRefresher] 앱 새로고침 시작');
      Phoenix.rebirth(globalNavigatorKey.currentContext!);
    });
  }

  static Future<void> _showMidnightDialog(BuildContext context) async {
    debugPrint('[MidnightRefresher] showDialog 시작');
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const MidnightDialog(),
    );
    debugPrint('[MidnightRefresher] showDialog 종료');
  }

  static void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
