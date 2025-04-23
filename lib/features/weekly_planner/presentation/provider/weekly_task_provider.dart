import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:abeul_planner/features/weekly_planner/data/datasource/weekly_task_box.dart';
import 'package:abeul_planner/features/weekly_planner/data/model/weekly_task_model.dart';

// 상태 관리를 위한 Provider
final weeklyTaskProvider =
    StateNotifierProvider<WeeklyTaskNotifier, List<WeeklyTaskModel>>(
  (ref) => WeeklyTaskNotifier(),
);

// 요일 플래너 상태 관리 클래스
class WeeklyTaskNotifier extends StateNotifier<List<WeeklyTaskModel>> {
  WeeklyTaskNotifier() : super([]) {
    _init();
  }

  /// 초기화: 박스를 불러오고, 매주 월요일마다 완료 여부 초기화
  void _init() {
    final box = WeeklyTaskBox.box;
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1)); // 이번 주 월요일

    for (final model in box.values) {
      for (final task in model.tasks) {
        final lastChecked = task.lastCheckedWeek;

        final isNewWeek = lastChecked == null ||
            lastChecked.year != currentWeekStart.year ||
            lastChecked.month != currentWeekStart.month ||
            lastChecked.day != currentWeekStart.day;

        if (isNewWeek) {
          task.isCompleted = false;
          task.lastCheckedWeek = currentWeekStart;
        }
      }
      model.save();
    }

    state = box.values.toList();
  }

  // 일정 추가
  void addTask(String day, WeeklyTask task) {
    final box = WeeklyTaskBox.box;
    final index = state.indexWhere((element) => element.day == day);
    if (index != -1) {
      final updated = state[index];
      updated.tasks.add(task);
      updated.save();
      state = [...state];
    } else {
      final newTask = WeeklyTaskModel(day: day, tasks: [task]);
      box.add(newTask);
      state = [...box.values];
    }
  }

  // 일정 삭제
  void removeTask(String day, int taskIndex) {
    final index = state.indexWhere((element) => element.day == day);
    if (index != -1) {
      final updated = state[index];
      updated.tasks.removeAt(taskIndex);
      updated.save();
      state = [...state];
    }
  }

  // 일정 수정 기능 추가
  void editTask(String day, int taskIndex, WeeklyTask updatedTask) {
    final index = state.indexWhere((element) => element.day == day);
    if (index != -1) {
      final updated = state[index];
      updated.tasks[taskIndex] = updatedTask;
      updated.save();
      state = [...state];
    }
  }

  // 수행 여부 토글
  void toggleTask(String day, int taskIndex) {
    final index = state.indexWhere((element) => element.day == day);
    if (index != -1) {
      final updated = state[index];
      final old = updated.tasks[taskIndex];
      updated.tasks[taskIndex] = WeeklyTask(
        content: old.content,
        priority: old.priority,
        isCompleted: !old.isCompleted,
        lastCheckedWeek: DateTime.now().subtract(
          Duration(days: DateTime.now().weekday - 1),
        ), // 현재 주 월요일로 기록
      );
      updated.save();
      state = [...state];
    }
  }

  // 순서 변경 함수
  void reorderTask(String day, int oldIndex, int newIndex) {
    final index = state.indexWhere((element) => element.day == day);
    if (index == -1) return;

    final updated = state[index];
    final currentTasks = [...updated.tasks];

    if (oldIndex < newIndex) newIndex -= 1;

    final item = currentTasks.removeAt(oldIndex);
    currentTasks.insert(newIndex, item);

    updated.tasks = currentTasks;
    updated.save();
    state = [...state];
  }

  // 요일 변경 포함한 수정
  void moveAndEditTask({
    required String fromDay,
    required String toDay,
    required int taskIndex,
    required WeeklyTask newTask,
  }) {
    if (fromDay == toDay) {
      editTask(toDay, taskIndex, newTask);
      return;
    }

    // 기존 요일에서 제거
    final fromIndex = state.indexWhere((element) => element.day == fromDay);
    if (fromIndex != -1) {
      final fromTaskModel = state[fromIndex];
      fromTaskModel.tasks.removeAt(taskIndex);
      fromTaskModel.save();
    }

    // 새 요일에 추가
    addTask(toDay, newTask);
  }

  // 전체 삭제 (디버깅 용도 등)
  void clearAll() {
    WeeklyTaskBox.box.clear();
    state = [];
  }
}
