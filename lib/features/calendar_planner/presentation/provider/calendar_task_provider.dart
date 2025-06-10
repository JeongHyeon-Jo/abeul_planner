// calendar_task_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:klc/klc.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/calendar_task_model.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/task_type_model.dart'; // 추가
import 'package:abeul_planner/features/calendar_planner/data/datasource/calendar_task_box.dart';
import 'package:abeul_planner/features/record/data/datasource/record/calendar_record_box.dart';
import 'package:abeul_planner/features/record/data/model/record/calendar_record_group.dart';

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

  // 특정 날짜의 일정들 가져오기
  List<CalendarTaskModel> getTasksForDate(DateTime date) {
    return state.where((task) {
      // 기간 일정인 경우 날짜 범위 체크
      if (task.isPeriodTask) {
        return task.containsDate(date);
      }
      // 일반 일정인 경우 정확한 날짜 매칭
      return task.date.year == date.year &&
             task.date.month == date.month &&
             task.date.day == date.day;
    }).toList();
  }

  // 일정 추가 (반복 시 repeatId 부여, 기간 일정 지원)
  void addTask(CalendarTaskModel task) {
    // 기간 일정인 경우 반복 설정 무시
    if ((task.taskType ?? TaskTypeModel.single) == TaskTypeModel.period) {
      _box.add(task);
    } else if (task.repeat == '매년' || task.repeat == '매월' || task.repeat == '매주') {
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

        _box.add(task.copyWith(
          date: repeatedDate,
          repeatId: repeatId,
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
      t.colorValue == task.colorValue &&
      (t.taskType ?? TaskTypeModel.single) == (task.taskType ?? TaskTypeModel.single)
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

  // 양력을 받아 음력 문자열 반환 (예: '음력 1월 1일')
  String getLunarDateText(DateTime solarDate) {
    try {
      setSolarDate(solarDate.year, solarDate.month, solarDate.day);
      final lunar = getLunarIsoFormat(); // 예: 2025-01-29
      final lunarDate = DateTime.parse(lunar);
      return '음력 ${lunarDate.month}월 ${lunarDate.day}일';
    } catch (e) {
      return ''; // 변환 실패 시 빈 문자열 반환
    }
  }

  // 특정 날짜의 일정 순서 변경
  void reorderTask(DateTime date, int oldIndex, int newIndex) {
    final tasksForDate = getTasksForDate(date);

    if (oldIndex < 0 || oldIndex >= tasksForDate.length || newIndex < 0) return;
    if (oldIndex < newIndex) newIndex -= 1;

    final movedTask = tasksForDate.removeAt(oldIndex);
    tasksForDate.insert(newIndex, movedTask);

    // 기존 state에서 해당 날짜의 task들 제거
    final otherTasks = state.where((task) => !_isTaskForDate(task, date)).toList();

    final updatedState = [...otherTasks, ...tasksForDate];

    // box clear 후 순서 반영하여 다시 추가 (단순화된 방식)
    _box.clear();
    _box.addAll(updatedState);
    state = updatedState;
  }

  // 특정 날짜에 해당하는 태스크인지 확인하는 헬퍼 메서드
  bool _isTaskForDate(CalendarTaskModel task, DateTime date) {
    if (task.isPeriodTask) {
      return task.containsDate(date);
    }
    return task.date.year == date.year &&
           task.date.month == date.month &&
           task.date.day == date.day;
  }

  // 기간 일정의 특정 날짜에서의 표시 유형 반환
  PeriodTaskDisplayType getPeriodTaskDisplayType(CalendarTaskModel task, DateTime date) {
    if (!task.isPeriodTask || task.endDate == null) {
      return PeriodTaskDisplayType.single;
    }

    final startDay = DateTime(task.date.year, task.date.month, task.date.day);
    final endDay = DateTime(task.endDate!.year, task.endDate!.month, task.endDate!.day);
    final checkDay = DateTime(date.year, date.month, date.day);

    if (checkDay.isAtSameMomentAs(startDay) && checkDay.isAtSameMomentAs(endDay)) {
      return PeriodTaskDisplayType.single; // 시작일과 종료일이 같은 날
    } else if (checkDay.isAtSameMomentAs(startDay)) {
      return PeriodTaskDisplayType.start; // 시작일
    } else if (checkDay.isAtSameMomentAs(endDay)) {
      return PeriodTaskDisplayType.end; // 종료일
    } else {
      return PeriodTaskDisplayType.middle; // 중간일
    }
  }
}

// 기간 일정의 표시 유형
enum PeriodTaskDisplayType {
  single,  // 단일 일정 또는 하루짜리 기간 일정
  start,   // 기간 일정 시작일
  middle,  // 기간 일정 중간일
  end,     // 기간 일정 종료일
}