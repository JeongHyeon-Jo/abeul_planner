// test/features/daily_planner/model/daily_task_model_test.dart

// Flutter의 기본 테스트 도구
import 'package:flutter_test/flutter_test.dart';

// 테스트 대상 모델: DailyTaskModel
import 'package:abeul_planner/features/daily_planner/data/model/daily_task_model.dart';

void main() {
  // DailyTaskModel에 대한 테스트 그룹
  group('DailyTaskModel', () {
    // ✅ 테스트 1: 모델 생성 시 필드 값이 정확하게 들어가는지 확인
    test('모델 생성 시 필드가 올바르게 설정되어야 한다', () {
      // given: 상황과 행동 문자열 준비
      const situation = '집에 오면';
      const action = '옷 갈아입기';

      // when: 모델 생성
      final task = DailyTaskModel(
        situation: situation,
        action: action,
      );

      // then: 각 필드가 올바르게 설정되었는지 확인
      expect(task.situation, equals(situation)); // situation 필드 확인
      expect(task.action, equals(action));       // action 필드 확인
      expect(task.isCompleted, isFalse);         // 기본값 isCompleted는 false여야 함
    });

    // ✅ 테스트 2: isCompleted를 true로 설정할 수 있어야 한다
    test('isCompleted를 true로 설정할 수 있어야 한다', () {
      // given & when: isCompleted가 true인 모델 생성
      final task = DailyTaskModel(
        situation: '자기 전',
        action: '명상하기',
        isCompleted: true,
      );

      // then: 완료 상태가 true로 잘 설정되었는지 확인
      expect(task.isCompleted, isTrue);
    });
  });
}
