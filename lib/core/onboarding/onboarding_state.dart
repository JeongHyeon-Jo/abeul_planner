// onboarding_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, Map<String, bool>>(
  (ref) => OnboardingNotifier(),
);

class OnboardingNotifier extends StateNotifier<Map<String, bool>> {
  OnboardingNotifier()
      : super({
          'home': true,
          'daily': true,
          'weekly': true,
          'calendar': true,
        });

  bool isFirst(String key) => state[key] ?? true;

  void complete(String key) {
    state = {...state, key: false};
  }
}
