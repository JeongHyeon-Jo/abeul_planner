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
            Phoenix.rebirth(context);
          }
        });
      }
    });
  }

  static Future<void> _showMidnightDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const MidnightDialog(),
    );
  }

  static void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
