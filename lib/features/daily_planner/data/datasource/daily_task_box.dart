// daily_task_box.dart
import 'package:hive/hive.dart';
import 'package:abeul_planner/features/daily_planner/data/model/daily_task_model.dart';

/// Hive에서 사용할 박스(Box)를 관리하는 클래스
class DailyTaskBox {
  /// Hive에 등록할 박스 이름 (고유 식별자처럼 사용됨)
  static const String boxName = 'daily_tasks';

  /// Hive 어댑터 등록 함수
  /// 앱 실행 시 반드시 1번만 등록해야 하며, 보통 main 함수에서 호출
  static Future<void> registerAdapters() async {
    Hive.registerAdapter(DailyTaskModelAdapter());
  }

  /// 박스를 열어주는 함수 (읽기/쓰기 용도로 사용)
  /// 이 함수를 호출해야 박스에 접근 가능
  static Future<Box<DailyTaskModel>> openBox() async {
    return await Hive.openBox<DailyTaskModel>(boxName);
  }
}
