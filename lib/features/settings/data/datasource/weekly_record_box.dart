// weekly_record_box.dart
import 'package:hive/hive.dart';
import 'package:abeul_planner/features/settings/data/model/weekly_record_group.dart';

class WeeklyRecordBox {
  static const String boxName = 'weeklyRecordBox';

  // 어댑터 등록
  static Future<void> registerAdapters() async {
    if (!Hive.isAdapterRegistered(22)) {
      Hive.registerAdapter(WeeklyRecordGroupAdapter());
    }
  }

  // 박스 열기
  static Future<void> openBox() async {
    await Hive.openBox<WeeklyRecordGroup>(boxName);
  }

  // 박스 참조
  static Box<WeeklyRecordGroup> get box => Hive.box<WeeklyRecordGroup>(boxName);
}
