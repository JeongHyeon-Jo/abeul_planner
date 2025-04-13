// weekly_task_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/datasource/weekly_task_box.dart';
import '../../data/model/weekly_task_model.dart';

// 상태 관리를 위한 Provider
final weeklyTaskProvider =
    StateNotifierProvider<WeeklyTaskNotifier, List<WeeklyTaskModel>>(
  (ref) => WeeklyTaskNotifier(),
);

// 요일 플래너 상태 관리 클래스
class WeeklyTaskNotifier extends StateNotifier<List<WeeklyTaskModel>> {
  WeeklyTaskNotifier() : super([]) {
    _loadTasks();
  }

  // 초기 데이터 로드
  void _loadTasks() {
    final box = WeeklyTaskBox.box;
    state = box.values.toList();
  }

  // 할 일 추가
  void addTask(String day, WeeklyTask task) {
    final box = WeeklyTaskBox.box;
    final index = state.indexWhere((element) => element.day == day);
    if (index != -1) {
      final updated = state[index];
      updated.task.add(task);
      updated.save();
      state = [...state];
    } else {
      final newTask = WeeklyTaskModel(day: day, theme: '', task: [task]);
      box.add(newTask);
      state = [...box.values];
    }
  }

  // 할 일 삭제
  void removeTask(String day, int taskIndex) {
    final index = state.indexWhere((element) => element.day == day);
    if (index != -1) {
      final updated = state[index];
      updated.task.removeAt(taskIndex);
      updated.save();
      state = [...state];
    }
  }

  // 수행 여부 토글
  void toggleTask(String day, int taskIndex) {
    final index = state.indexWhere((element) => element.day == day);
    if (index != -1) {
      final updated = state[index];
      final old = updated.task[taskIndex];
      updated.task[taskIndex] = WeeklyTask(
        content: old.content,
        priority: old.priority,
        isCompleted: !old.isCompleted,
      );
      updated.save();
      state = [...state];
    }
  }

  // 테마 설정
  void setTheme(String day, String theme) {
    final index = state.indexWhere((element) => element.day == day);
    if (index != -1) {
      final updated = state[index];
      updated.theme = theme;
      updated.save();
      state = [...state];
    }
  }

  // 전체 삭제 (디버깅 용도 등)
  void clearAll() {
    WeeklyTaskBox.box.clear();
    state = [];
  }
}
