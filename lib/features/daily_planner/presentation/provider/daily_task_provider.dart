// daily_task_provider.dart
import 'package:abeul_planner/features/settings/data/datasource/record/daily_record_box.dart';
import 'package:abeul_planner/features/settings/data/model/record/daily_record_group.dart';
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

  // Hive 박스에서 데이터를 불러오고, 하루가 지났다면 완료 여부 초기화
  Future<void> _init() async {
  _box = Hive.box<DailyTaskModel>(DailyTaskBox.boxName);
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    final prefs = await SharedPreferences.getInstance();
    final lastSaved = prefs.getString('last_record_date');
    final formattedYesterday = DateFormat('yyyy-MM-dd').format(yesterday);

    // 어제 기록 저장
    if (lastSaved != formattedYesterday) {
      final oldTasks = _box.values.toList();
      if (oldTasks.isNotEmpty) {
        final record = DailyRecordGroup(date: yesterday, tasks: oldTasks);
        await DailyRecordBox.box.add(record);
        await prefs.setString('last_record_date', formattedYesterday);
      }
    }

    // 오늘 날짜 기준으로 isCompleted 초기화
    final updatedTasks = _box.values.map((task) {
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

    if (updatedTasks.isNotEmpty) {
      await _box.clear();
      await _box.addAll(updatedTasks);
    }

    state = updatedTasks;
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
