// weekly_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:abeul_planner/features/weekly_planner/data/datasource/weekly_task_box.dart';
import 'package:abeul_planner/features/weekly_planner/data/model/weekly_task_model.dart';
import 'package:abeul_planner/features/record/data/datasource/record/weekly_record_box.dart';
import 'package:abeul_planner/features/record/data/model/record/weekly_record_group.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // 초기화: 기록 먼저 저장한 뒤 완료 여부 초기화
  Future<void> _init() async {
    final box = WeeklyTaskBox.box;
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    final prefs = await SharedPreferences.getInstance();
    final lastSavedStr = prefs.getString('weekly_last_record_date');
    final lastSavedDate = lastSavedStr == null
        ? yesterday.subtract(const Duration(days: 1))
        : DateFormat('yyyy-MM-dd').parse(lastSavedStr);

    final hasSundaySection =
        WeeklyTaskBox.box.values.any((e) => e.day == '일');

    bool sundayRecorded = false;

    DateTime current = lastSavedDate.add(const Duration(days: 1));
    while (!current.isAfter(yesterday)) {
      final addedDays = await _saveWeeklyRecord(current);
      if (addedDays.contains('일')) {
        sundayRecorded = true;
      }
      current = current.add(const Duration(days: 1));
    }

    final shouldInit =
        !hasSundaySection || (hasSundaySection && sundayRecorded);

    if (shouldInit) {
      await prefs.setString(
        'weekly_last_record_date',
        DateFormat('yyyy-MM-dd').format(yesterday),
      );

      final currentWeekStart =
          now.subtract(Duration(days: now.weekday - 1));

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
    }

    state = box.values.toList();
  }

  // 주간 플래너 기록 저장
  Future<Set<String>> _saveWeeklyRecord(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    Set<String> addedDays = {};

    for (final model in WeeklyTaskBox.box.values) {
      if (model.tasks.isEmpty) continue;

      final alreadyExists = WeeklyRecordBox.box.values.any((record) =>
          DateFormat('yyyy-MM-dd').format(record.date) == formattedDate &&
          record.day == model.day);

      if (!alreadyExists) {
        final tasksCopy = model.tasks.map((task) => task.copyWith()).toList();

        final record = WeeklyRecordGroup(
          date: date,
          day: model.day,
          tasks: tasksCopy,
        );
        await WeeklyRecordBox.box.add(record);
        addedDays.add(model.day);
      }
    }

    return addedDays;
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
        ),
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

  // 특정 요일의 인덱스 삭제
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
