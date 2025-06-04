// user_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abeul_planner/features/auth/data/model/user_model.dart';
import 'package:abeul_planner/features/auth/data/datasource/user_box.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserModel>((ref) {
  final box = UserBox.box;
  final user = box.get('current') ?? UserModel();
  return UserNotifier(user);
});

class UserNotifier extends StateNotifier<UserModel> {
  UserNotifier(super.state);

  void toggleAutoSortCompleted(bool value) {
    final updated = UserModel(
      selectedTheme: state.selectedTheme,
      autoSortCompleted: value,
    );
    UserBox.box.put('current', updated);
    state = updated;
  }

  void updateTheme(String theme) {
    final updated = UserModel(
      selectedTheme: theme,
      autoSortCompleted: state.autoSortCompleted,
    );
    UserBox.box.put('current', updated);
    state = updated;
  }
}
