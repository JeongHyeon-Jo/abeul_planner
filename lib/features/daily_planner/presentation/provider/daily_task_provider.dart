// daily_task_provider.dart
import 'package:abeul_planner/features/record/data/datasource/record/daily_record_box.dart';
import 'package:abeul_planner/features/record/data/model/record/daily_record_group.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:abeul_planner/features/daily_planner/data/model/daily_task_model.dart';
import 'package:abeul_planner/features/daily_planner/data/datasource/daily_task_box.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 일일 일정(DailyTask)을 관리하는 Riverpod Provider
final dailyTaskProvider = StateNotifierProvider<DailyTaskNotifier, List<DailyTaskModel>>((ref) {
  return DailyTaskNotifier();
});

class DailyTaskNotifier extends StateNotifier<List<DailyTaskModel>> {
  late Box<DailyTaskModel> _box;

  DailyTaskNotifier() : super([]) {
    _init();
  }

  // 하루가 지났다면 완료 여부 초기화(어제 기록이 없으면 초기화를 미룸)
  Future<void> _init() async {
    _box = Hive.box<DailyTaskModel>(DailyTaskBox.boxName);
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    final prefs = await SharedPreferences.getInstance();
    final lastSavedStr = prefs.getString('last_record_date');
    final lastSavedDate = lastSavedStr == null
        ? yesterday.subtract(const Duration(days: 1))
        : DateFormat('yyyy-MM-dd').parse(lastSavedStr);

    DateTime current = lastSavedDate.add(const Duration(days: 1));
    final originalTasks = _box.values.toList();
    bool anyRecordAdded = false;

    while (!current.isAfter(yesterday)) {
      final added = await _saveDailyRecord(current, originalTasks);
      if (added) anyRecordAdded = true;
      current = current.add(const Duration(days: 1));
    }

    if (anyRecordAdded) {
      await prefs.setString('last_record_date', DateFormat('yyyy-MM-dd').format(yesterday));

      final updatedTasks = originalTasks.map((task) {
        final lastChecked = task.lastCheckedDate;
        final isNewDay = lastChecked == null ||
            lastChecked.year != today.year ||
            lastChecked.month != today.month ||
            lastChecked.day != today.day;

        return isNewDay
            ? DailyTaskModel(
                situation: task.situation,
                action: task.action,
                isCompleted: false,
                priority: task.priority,
                lastCheckedDate: null,
              )
            : task;
      }).toList();

      await _box.clear();
      await _box.addAll(updatedTasks);
      state = updatedTasks;
    } else {
      // 기록이 없으면 그대로 유지
      state = _box.values.toList();
    }
  }

  // 하루가 지났을 때 기록 저장
  Future<bool> _saveDailyRecord(DateTime date, List<DailyTaskModel> originalTasks) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final alreadySaved = DailyRecordBox.box.values.any(
      (record) => DateFormat('yyyy-MM-dd').format(record.date) == dateStr,
    );

    if (!alreadySaved && originalTasks.isNotEmpty) {
      final backupTasks = originalTasks.map((task) {
        return DailyTaskModel(
          situation: task.situation,
          action: task.action,
          isCompleted: task.isCompleted,
          priority: task.priority,
          lastCheckedDate: task.lastCheckedDate,
        );
      }).toList();

      final record = DailyRecordGroup(date: date, tasks: backupTasks);
      await DailyRecordBox.box.add(record);
      return true;
    }

    return false;
  }

  // 새로운 일정 추가
  void addTask(DailyTaskModel task) {
    _box.add(task);
    state = _box.values.toList();
  }

  // 완료 여부 토글 시, 오늘 날짜로 lastCheckedDate 기록
  void toggleTask(int index) {
    final task = _box.getAt(index);
    if (task != null) {
      final updatedTask = DailyTaskModel(
        situation: task.situation,
        action: task.action,
        isCompleted: !task.isCompleted,
        priority: task.priority,
        lastCheckedDate: DateTime.now(),
      );
      _box.putAt(index, updatedTask);
      state = _box.values.toList();
    }
  }

  // 기존 일정 수정
  void editTask(int index, DailyTaskModel updatedTask) {
    _box.putAt(index, updatedTask);
    state = _box.values.toList();
  }

  // 기존 일정 제거
  void removeTask(int index) {
    _box.deleteAt(index);
    state = _box.values.toList();
  }

  // 순서 변경 함수 (드래그로 이동 시)
  void reorderTask(int oldIndex, int newIndex) {
    final currentTasks = [...state];

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item = currentTasks.removeAt(oldIndex);
    currentTasks.insert(newIndex, item);

    // Hive에 순서 반영
    for (int i = 0; i < currentTasks.length; i++) {
      _box.putAt(i, currentTasks[i]);
    }

    state = [...currentTasks];
  }

  // 전체 삭제
  void deleteAll() {
    _box.clear();
    state = [];
  }

  // 특정 인덱스 삭제
  void deleteAt(int index) {
    if (index >= 0 && index < _box.length) {
      _box.deleteAt(index);
      state = _box.values.toList();
    }
  }
}