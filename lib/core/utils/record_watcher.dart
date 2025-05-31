// record_watcher.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abeul_planner/core/utils/record_saver.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordWatcher {
  static Timer? _midnightSaveTimer;

  static void start(ProviderContainer container) async {
    _midnightSaveTimer?.cancel();

    final now = DateTime.now();
    final tonight = DateTime(now.year, now.month, now.day, 23, 59);

    final durationUntilMidnight = tonight.difference(now);
    if (durationUntilMidnight.isNegative) return; // 이미 자정 지남

    _midnightSaveTimer = Timer(durationUntilMidnight, () async {
      final prefs = await SharedPreferences.getInstance();
      final yesterday = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
      final lastSaved = prefs.getString('last_record_date');

      if (lastSaved != DateFormat('yyyy-MM-dd').format(yesterday)) {
        await RecordSaver.saveAllIfNeeded(container);
      }
    });
  }

  static void stop() {
    _midnightSaveTimer?.cancel();
    _midnightSaveTimer = null;
  }
}
