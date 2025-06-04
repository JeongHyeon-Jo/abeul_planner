// user_model.dart
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 100)
class UserModel extends HiveObject {
  @HiveField(0)
  final String selectedTheme; // 예: 'light', 'dark', 'system'

  @HiveField(1)
  final bool autoSortCompleted; // 완료된 일정 아래로 정렬 여부

  UserModel({
    this.selectedTheme = 'light',
    this.autoSortCompleted = true,
  });
}