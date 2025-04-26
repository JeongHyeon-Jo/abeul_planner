// calendar_task_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/calendar_task_model.dart';
import 'package:abeul_planner/features/calendar_planner/data/datasource/calendar_task_box.dart';

/// 선택된 날짜에 해당하는 캘린더 일정(Task)을 관리하는 Riverpod Provider
final calendarTaskProvider = StateNotifierProvider<CalendarTaskNotifier, List<CalendarTaskModel>>((ref) {
  return CalendarTaskNotifier();
});

/// CalendarTask 리스트를 상태로 관리하는 StateNotifier
class CalendarTaskNotifier extends StateNotifier<List<CalendarTaskModel>> {
  late Box<CalendarTaskModel> _box; // Hive Box 객체

  CalendarTaskNotifier() : super([]) {
    _init(); // 초기화
  }

  /// Hive 박스를 열고 데이터를 로드함
  Future<void> _init() async {
    _box = Hive.box<CalendarTaskModel>(CalendarTaskBox.boxName);
    state = _box.values.toList();
  }

  /// 특정 날짜에 해당하는 일정 필터링
  List<CalendarTaskModel> getTasksForDate(DateTime date) {
    return state.where((task) {
      return task.date.year == date.year &&
             task.date.month == date.month &&
             task.date.day == date.day;
    }).toList();
  }

  /// 새로운 일정 추가
  void addTask(CalendarTaskModel task) {
    _box.add(task);
    state = _box.values.toList();
  }

  /// 일정 삭제 (기본은 하나만 삭제, 반복 삭제는 이후 추가)
  void deleteTask(int index) {
    _box.deleteAt(index);
    state = _box.values.toList();
  }

  /// 특정 task를 직접 삭제 (index 대신 task 기반)
  void deleteSpecificTask(CalendarTaskModel task) {
    final index = state.indexOf(task);
    if (index != -1) {
      deleteTask(index);
    }
  }

  /// 메모 내용 기준으로 반복되는 전체 일정 삭제 (반복 삭제용, 추후 구현할 거야)
  void deleteAllTasksWithMemo(String memo) {
    final tasksToDelete = state.where((task) => task.memo == memo).toList();
    for (var task in tasksToDelete) {
      final index = state.indexOf(task);
      if (index != -1) {
        _box.deleteAt(index);
      }
    }
    state = _box.values.toList();
  }
}
