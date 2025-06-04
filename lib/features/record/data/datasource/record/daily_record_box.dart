// daily_record_box.dart
import 'package:hive/hive.dart';
import 'package:abeul_planner/features/record/data/model/record/daily_record_group.dart';

class DailyRecordBox {
  static const String boxName = 'dailyRecordBox';

  static Future<void> registerAdapters() async {
    if (!Hive.isAdapterRegistered(20)) {
      Hive.registerAdapter(DailyRecordGroupAdapter());
    }
  }

  static Future<void> openBox() async {
    await Hive.openBox<DailyRecordGroup>(boxName);
  }

  static Box<DailyRecordGroup> get box => Hive.box<DailyRecordGroup>(boxName);
}
