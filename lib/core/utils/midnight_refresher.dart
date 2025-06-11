// midnight_refresher.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:abeul_planner/core/widgets/midnight_dialog.dart';

class MidnightRefresher {
  static Timer? _timer;

  static void start(BuildContext context) {
    if (_timer != null && _timer!.isActive) return;

    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = nextMidnight.difference(now);

    _timer = Timer(durationUntilMidnight, () async {
      if (!context.mounted) return;

      await _showMidnightDialog(context);

      if (context.mounted) {
        await Future.delayed(const Duration(milliseconds: 300));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            debugPrint('[midnight_refresher.dart] 앱이 새로고침되었습니다');
            Phoenix.rebirth(context);
          }
        });
      }
    });
  }

  static Future<void> _showMidnightDialog(BuildContext context) async {
    final completer = Completer<void>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const MidnightDialog(),
        );
      }
      completer.complete();
    });

    return completer.future;
  }

  static void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
