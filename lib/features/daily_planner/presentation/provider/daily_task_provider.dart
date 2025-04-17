// daily_task_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:abeul_planner/features/daily_planner/data/model/daily_task_model.dart';
import 'package:abeul_planner/features/daily_planner/data/datasource/daily_task_box.dart';

/// 일일 일정(DailyTask)을 관리하는 Riverpod Provider
final dailyTaskProvider = StateNotifierProvider<DailyTaskNotifier, List<DailyTaskModel>>((ref) {
  return DailyTaskNotifier();
});

class DailyTaskNotifier extends StateNotifier<List<DailyTaskModel>> {
  late Box<DailyTaskModel> _box;

  DailyTaskNotifier() : super([]) {
    _init();
  }

  /// Hive 박스에서 데이터를 불러오고, 하루가 지났다면 완료 여부 초기화
  Future<void> _init() async {
    _box = Hive.box<DailyTaskModel>(DailyTaskBox.boxName);
    final today = DateTime.now();

    final updatedTasks = _box.values.map((task) {
      final lastChecked = task.lastCheckedDate;

      final isNewDay = lastChecked == null ||
          lastChecked.year != today.year ||
          lastChecked.month != today.month ||
          lastChecked.day != today.day;

      // 날짜가 바뀐 경우 완료 여부 초기화
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
  }

  /// 새로운 일정 추가
  void addTask(DailyTaskModel task) {
    _box.add(task);
    state = _box.values.toList();
  }

  /// 완료 여부 토글 시, 오늘 날짜로 lastCheckedDate 기록
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

  /// 기존 일정 수정
  void editTask(int index, DailyTaskModel updatedTask) {
    _box.putAt(index, updatedTask);
    state = _box.values.toList();
  }

  /// 기존 일정 제거
  void removeTask(int index) {
    _box.deleteAt(index);
    state = _box.values.toList();
  }

  /// 순서 변경 함수
  void reorderTask(int oldIndex, int newIndex) async {
    final currentTasks = [...state];

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item = currentTasks.removeAt(oldIndex);
    currentTasks.insert(newIndex, item);

    await _box.clear();
    await _box.addAll(currentTasks);
    state = _box.values.toList();
  }
}
