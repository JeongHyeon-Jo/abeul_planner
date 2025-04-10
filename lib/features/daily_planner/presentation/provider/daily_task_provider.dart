// daily_task_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:abeul_planner/features/daily_planner/data/model/daily_task_model.dart';
import 'package:abeul_planner/features/daily_planner/data/datasource/daily_task_box.dart';

/// 일일 할 일(DailyTask)을 관리하는 Riverpod Provider
/// 상태는 List<DailyTaskModel> 타입
final dailyTaskProvider = StateNotifierProvider<DailyTaskNotifier, List<DailyTaskModel>>((ref) {
  return DailyTaskNotifier();
});

/// DailyTask 리스트를 상태로 관리하는 StateNotifier
class DailyTaskNotifier extends StateNotifier<List<DailyTaskModel>> {
  late Box<DailyTaskModel> _box; // Hive 박스 객체

  DailyTaskNotifier() : super([]) {
    _init(); // 초기화 함수 호출 (박스 열고 상태 동기화)
  }

  /// Hive 박스에서 데이터를 불러와 상태를 초기화
  Future<void> _init() async {
    _box = Hive.box<DailyTaskModel>(DailyTaskBox.boxName); // 이미 열린 박스를 가져옴
    state = _box.values.toList(); // Hive 박스에 저장된 값들을 상태로 설정
  }

  /// 새로운 할 일을 추가
  void addTask(DailyTaskModel task) {
    _box.add(task); // Hive에 추가
    state = _box.values.toList(); // 상태 업데이트
  }

  /// 할 일의 완료 여부를 토글 (완료 ↔ 미완료)
  void toggleTask(int index) {
    final task = _box.getAt(index); // 인덱스로 할 일 가져오기
    if (task != null) {
      // 완료 상태를 반전시켜 업데이트
      final updatedTask = DailyTaskModel(
        situation: task.situation,
        action: task.action,
        isCompleted: !task.isCompleted,
      );
      _box.putAt(index, updatedTask);
      state = _box.values.toList(); // 상태 다시 동기화
    }
  }
}
