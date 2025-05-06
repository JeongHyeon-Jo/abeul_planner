// calendar_task_box.dart
import 'package:hive/hive.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/calendar_task_model.dart';

// 캘린더 일정(Task)을 저장할 Hive Box를 관리하는 클래스
class CalendarTaskBox {
  // Box의 고유 이름 (이 이름으로 Box를 열거나 접근함)
  static const String boxName = 'calendar_tasks';

  // Hive 어댑터 등록 함수
  // 앱 시작 시 1번만 호출되어야 하며, 보통 main 함수나 초기화 단계에서 사용
  static Future<void> registerAdapters() async {
    Hive.registerAdapter(CalendarTaskModelAdapter());
  }

  // Box 열기 함수 (읽기/쓰기 위해 반드시 필요)
  static Future<Box<CalendarTaskModel>> openBox() async {
    return await Hive.openBox<CalendarTaskModel>(boxName);
  }
}