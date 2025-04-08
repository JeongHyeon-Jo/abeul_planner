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
    return state.where((task) =>
      task.date.year == date.year &&
      task.date.month == date.month &&
      task.date.day == date.day).toList();
  }

  /// 새로운 일정 추가
  void addTask(CalendarTaskModel task) {
    _box.add(task);
    state = _box.values.toList();
  }

  /// 일정 삭제
  void deleteTask(int index) {
    _box.deleteAt(index);
    state = _box.values.toList();
  }
}
