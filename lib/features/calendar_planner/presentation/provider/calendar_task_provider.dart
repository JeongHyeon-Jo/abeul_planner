// calendar_task_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/calendar_task_model.dart';
import 'package:abeul_planner/features/calendar_planner/data/datasource/calendar_task_box.dart';
import 'package:abeul_planner/features/settings/data/datasource/record/calendar_record_box.dart';
import 'package:abeul_planner/features/settings/data/model/record/calendar_record_group.dart';

// 선택된 날짜에 해당하는 캘린더 일정(Task)을 관리하는 Riverpod Provider
final calendarTaskProvider = StateNotifierProvider<CalendarTaskNotifier, List<CalendarTaskModel>>((ref) {
  return CalendarTaskNotifier();
});

class CalendarTaskNotifier extends StateNotifier<List<CalendarTaskModel>> {
  late Box<CalendarTaskModel> _box;

  CalendarTaskNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    _box = Hive.box<CalendarTaskModel>(CalendarTaskBox.boxName);
    final today = DateTime.now();
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    await _saveCalendarRecord(yesterday);
    state = _box.values.toList();
  }

  // 하루가 지났을 때 기록 저장
  Future<void> _saveCalendarRecord(DateTime date) async {
    final key = DateFormat('yyyy-MM-dd').format(date);
    final filtered = _box.values.where((task) => DateFormat('yyyy-MM-dd').format(task.date) == key).toList();

    if (filtered.isEmpty) return;

    final exists = CalendarRecordBox.box.values.any(
      (record) => DateFormat('yyyy-MM-dd').format(record.date) == key,
    );

    if (!exists) {
      final record = CalendarRecordGroup(date: date, tasks: filtered);
      await CalendarRecordBox.box.add(record);
    }
  }

  List<CalendarTaskModel> getTasksForDate(DateTime date) {
    return state.where((task) {
      return task.date.year == date.year &&
             task.date.month == date.month &&
             task.date.day == date.day;
    }).toList();
  }

  // 일정 추가 (반복 시 repeatId 부여)
  void addTask(CalendarTaskModel task) {
    if (task.repeat == '매년' || task.repeat == '매월' || task.repeat == '매주') {
      final uuid = const Uuid();
      final repeatId = uuid.v4();

      int repeatCount;
      if (task.repeat == '매년') {
        repeatCount = 10;
      } else if (task.repeat == '매월') {
        repeatCount = 12;
      } else {
        repeatCount = 52;
      }

      for (int i = 0; i < repeatCount; i++) {
        late DateTime repeatedDate;

        if (task.repeat == '매년') {
          repeatedDate = DateTime(task.date.year + i, task.date.month, task.date.day);
        } else if (task.repeat == '매월') {
          repeatedDate = DateTime(task.date.year, task.date.month + i, task.date.day);
        } else {
          repeatedDate = task.date.add(Duration(days: 7 * i));
        }

        if (task.endDate != null && repeatedDate.isAfter(task.endDate!)) {
          break;
        }

        _box.add(CalendarTaskModel(
          memo: task.memo,
          date: repeatedDate,
          repeat: task.repeat,
          isCompleted: task.isCompleted,
          priority: task.priority,
          repeatId: repeatId,
          endDate: task.endDate,
          secret: task.secret,
          colorValue: task.colorValue,
        ));
      }
    } else {
      _box.add(task);
    }

    state = _box.values.toList();
  }

  void deleteTask(int index) {
    _box.deleteAt(index);
    state = _box.values.toList();
  }

  void deleteSpecificTask(CalendarTaskModel task) {
    final index = _box.values.toList().indexWhere((t) =>
      t.memo == task.memo &&
      t.date == task.date &&
      t.repeat == task.repeat &&
      t.priority == task.priority &&
      t.endDate == task.endDate &&
      t.secret == task.secret &&
      t.colorValue == task.colorValue
    );

    if (index != -1) {
      _box.deleteAt(index);
      state = _box.values.toList();
    }
  }

  void deleteAllTasksWithRepeatId(String repeatId) {
    final tasksToDelete = _box.values.where((task) => task.repeatId == repeatId).toList();

    for (var task in tasksToDelete) {
      final index = _box.values.toList().indexOf(task);
      if (index != -1) {
        _box.deleteAt(index);
      }
    }

    state = _box.values.toList();
  }

  void deleteAll() {
    _box.clear();
    state = [];
  }

  void toggleTask(CalendarTaskModel task) {
    final index = state.indexOf(task);
    if (index != -1) {
      task.isCompleted = !task.isCompleted;
      _box.putAt(index, task);
      state = List.from(state);
    }
  }
}
