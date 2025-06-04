// user_box.dart
import 'package:hive/hive.dart';
import 'package:abeul_planner/features/auth/data/model/user_model.dart';

class UserBox {
  static const String boxName = 'user';
  static late Box<UserModel> box;

  /// 어댑터 등록 함수
  static Future<void> registerAdapters() async {
    Hive.registerAdapter(UserModelAdapter());
  }

  /// 박스 열기 함수
  static Future<void> openBox() async {
    box = await Hive.openBox<UserModel>(boxName);
  }
}