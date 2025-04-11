// test/test_helper.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:abeul_planner/features/daily_planner/data/model/daily_task_model.dart';

/// 테스트 시작 전 호출할 초기화 함수
Future<void> setUpHiveForTest() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  Hive.init(Directory.systemTemp.path); // 임시 경로 사용 (테스트 전용)
  Hive.registerAdapter(DailyTaskModelAdapter());

  await Hive.openBox<DailyTaskModel>('daily_tasks');
}
