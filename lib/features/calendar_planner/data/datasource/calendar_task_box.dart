// calendar_task_box.dart
import 'package:hive/hive.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/calendar_task_model.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/task_type_model.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/timeofday_model.dart';

class CalendarTaskBox {
  static const String boxName = 'calendar_tasks';
  static late Box<CalendarTaskModel> _box;

  // 어댑터 등록
  static Future<void> registerAdapters() async {
    // CalendarTaskModel 어댑터 등록
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CalendarTaskModelAdapter());
    }
    
    // TaskTypeModel 어댑터 등록
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(TaskTypeModelAdapter());
    }
    
    // TimeOfDayModel 어댑터 등록
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(TimeOfDayModelAdapter());
    }
  }

  // 박스 열기
  static Future<void> openBox() async {
    _box = await Hive.openBox<CalendarTaskModel>(boxName);
  }

  // 박스 가져오기
  static Box<CalendarTaskModel> get box => _box;

  // 박스 닫기
  static Future<void> closeBox() async {
    await _box.close();
  }

  // 박스 삭제
  static Future<void> deleteBox() async {
    await Hive.deleteBoxFromDisk(boxName);
  }
}