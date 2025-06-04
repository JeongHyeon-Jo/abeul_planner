// calendar_record_box.dart
import 'package:hive/hive.dart';
import 'package:abeul_planner/features/record/data/model/record/calendar_record_group.dart';

class CalendarRecordBox {
  static const String boxName = 'calendarRecordBox';

  // 어댑터 등록
  static Future<void> registerAdapters() async {
    if (!Hive.isAdapterRegistered(21)) {
      Hive.registerAdapter(CalendarRecordGroupAdapter());
    }
  }

  // 박스 열기
  static Future<void> openBox() async {
    await Hive.openBox<CalendarRecordGroup>(boxName);
  }

  // 박스 참조
  static Box<CalendarRecordGroup> get box => Hive.box<CalendarRecordGroup>(boxName);
}
