// test/features/daily_planner/provider/daily_task_provider_test.dart

// Flutter의 테스트 도구 임포트
import 'package:flutter_test/flutter_test.dart';

// DailyTaskModel 클래스 (할 일 모델)
import 'package:abeul_planner/features/daily_planner/data/model/daily_task_model.dart';

// 할 일을 관리하는 상태관리 클래스 (StateNotifier)
import 'package:abeul_planner/features/daily_planner/presentation/provider/daily_task_provider.dart';

// hive
import 'package:hive/hive.dart';

// Hive 테스트용 초기화 함수
import '../../../test_helper.dart';

void main() {
  // 테스트 실행 전 호출되는 초기화 코드 (Hive 설정)
  setUp(() async {
    await setUpHiveForTest(); // Hive 박스 열기 및 어댑터 등록

    final box = Hive.box<DailyTaskModel>('daily_tasks');
    await box.clear();
  });

  // ✅ 테스트 1: 할 일을 추가하는 기능 확인
  test('addTask는 새로운 할 일을 상태에 추가해야 한다', () async {
    final notifier = DailyTaskNotifier(); // 상태관리 객체 생성
    final task = DailyTaskModel(situation: '출근하면', action: '커피 마시기'); // 할 일 생성

    await Future.delayed(Duration(milliseconds: 100)); // 초기화 비동기 작업 대기

    notifier.addTask(task); // 할 일 추가

    // 상태에 하나의 항목이 존재하는지 확인
    expect(notifier.state.length, 1);
    // 해당 항목의 상황(situation) 값이 일치하는지 확인
    expect(notifier.state.first.situation, '출근하면');
    // 완료 여부는 기본값인 false여야 함
    expect(notifier.state.first.isCompleted, false);
  });

  // ✅ 테스트 2: 할 일의 완료 상태를 토글하는 기능 확인
  test('toggleTask는 할 일 완료 상태를 반전시켜야 한다', () async {
    final notifier = DailyTaskNotifier(); // 상태관리 객체 생성
    final task = DailyTaskModel(situation: '앉으면', action: '자세 바르게'); // 할 일 생성

    await Future.delayed(Duration(milliseconds: 100)); // 초기화 비동기 작업 대기

    notifier.addTask(task); // 할 일 추가

    // 초기 상태는 미완료여야 함
    expect(notifier.state.first.isCompleted, false);

    notifier.toggleTask(0); // 완료 상태 토글 (false → true)

    // 상태가 반전되었는지 확인
    expect(notifier.state.first.isCompleted, true);
  });
}
