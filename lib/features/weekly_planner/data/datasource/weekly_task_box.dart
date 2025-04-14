// weekly_task_box.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../model/weekly_task_model.dart';

class WeeklyTaskBox {
  // 박스 이름 상수
  static const String boxName = 'weeklyTaskBox';

  // 어댑터가 등록되어 있지 않으면 등록
  static Future<void> registerAdapters() async {
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(WeeklyTaskModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(WeeklyTaskAdapter());
    }
  }

  // 박스 열기
  static Future<void> openBox() async {
    await Hive.openBox<WeeklyTaskModel>(boxName);
  }

  // 박스 인스턴스 가져오기
  static Box<WeeklyTaskModel> getBox() => Hive.box<WeeklyTaskModel>(boxName);

  // box라는 이름의 getter 추가 (편의용)
  static Box<WeeklyTaskModel> get box => getBox();
}
