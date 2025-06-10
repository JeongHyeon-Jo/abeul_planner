// weekly_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:abeul_planner/features/weekly_planner/data/datasource/weekly_task_box.dart';
import 'package:abeul_planner/features/weekly_planner/data/model/weekly_task_model.dart';
import 'package:abeul_planner/features/record/data/datasource/record/weekly_record_box.dart';
import 'package:abeul_planner/features/record/data/model/record/weekly_record_group.dart';
import 'package:shared_preferences/shared_preferences.dart';

final weeklyTaskProvider = StateNotifierProvider<WeeklyTaskNotifier, List<WeeklyTaskModel>>(
  (ref) => WeeklyTaskNotifier(),
);

class WeeklyTaskNotifier extends StateNotifier<List<WeeklyTaskModel>> {
  WeeklyTaskNotifier() : super([]) {
    _init();
  }

  // 초기화 함수
  Future<void> _init() async {
    final box = WeeklyTaskBox.box;
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final prefs = await SharedPreferences.getInstance();
    final lastSavedStr = prefs.getString('weekly_last_record_date');
    final lastSavedDate = lastSavedStr == null
        ? yesterday.subtract(const Duration(days: 1))
        : DateFormat('yyyy-MM-dd').parse(lastSavedStr);

    bool initialized = false;
    DateTime current = lastSavedDate.add(const Duration(days: 1));
    while (!current.isAfter(yesterday)) {
      final recorded = await _saveRecordForDate(current);
      if (!initialized && current.weekday == DateTime.sunday && recorded) {
        await _resetTasksForNewWeek(now);
        initialized = true;
      }
      current = current.add(const Duration(days: 1));
    }

    await prefs.setString(
      'weekly_last_record_date',
      DateFormat('yyyy-MM-dd').format(yesterday),
    );

    state = box.values.toList();
  }

  // 주 단위 초기화 로직 (일요일 기록 시 실행)
  Future<void> _resetTasksForNewWeek(DateTime now) async {
    final prefs = await SharedPreferences.getInstance();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));

    for (final model in WeeklyTaskBox.box.values) {
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

    await prefs.setString(
      'weekly_last_record_date',
      DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1))),
    );
  }

  // 날짜 기준 기록 저장 함수
  Future<bool> _saveRecordForDate(DateTime date) async {
    final weekdayStr = DateFormat.E('ko_KR').format(date);
    final targetDateStr = DateFormat('yyyy-MM-dd').format(date);

    final alreadyExists = WeeklyRecordBox.box.values.any((record) =>
        DateFormat('yyyy-MM-dd').format(record.date) == targetDateStr &&
        record.day == weekdayStr);

    if (!alreadyExists) {
      for (final model in WeeklyTaskBox.box.values) {
        if (model.day != weekdayStr || model.tasks.isEmpty) continue;

        final tasksCopy = model.tasks.map((task) => task.copyWith()).toList();
        final record = WeeklyRecordGroup(
          date: date,
          day: model.day,
          tasks: tasksCopy,
        );

        await WeeklyRecordBox.box.add(record);
        return true;
      }
    }

    return false;
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

  // 일정 수정
  void editTask(String day, int taskIndex, WeeklyTask updatedTask) {
    final index = state.indexWhere((element) => element.day == day);
    if (index != -1) {
      final updated = state[index];
      updated.tasks[taskIndex] = updatedTask;
      updated.save();
      state = [...state];
    }
  }

  // 완료 여부 토글
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
        ),
      );
      updated.save();
      state = [...state];
    }
  }

  // 순서 변경
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

  // 요일 이동 + 수정
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

    final fromIndex = state.indexWhere((element) => element.day == fromDay);
    if (fromIndex != -1) {
      final fromTaskModel = state[fromIndex];
      fromTaskModel.tasks.removeAt(taskIndex);
      fromTaskModel.save();
    }

    addTask(toDay, newTask);
  }

  // 전체 삭제
  void deleteAll() {
    WeeklyTaskBox.box.clear();
    state = [];
  }

  // 특정 인덱스 삭제
  void deleteTask(String day, int index) {
    final dayIndex = state.indexWhere((e) => e.day == day);
    if (dayIndex != -1 && index >= 0 && index < state[dayIndex].tasks.length) {
      final updated = state[dayIndex];
      updated.tasks.removeAt(index);
      updated.save();
      state = [...state];
    }
  }
}
