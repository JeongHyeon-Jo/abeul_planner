// core/onboarding/onboarding_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingState extends StateNotifier<Map<String, bool>> {
  OnboardingState() : super({}) {
    _loadOnboardingStatus();
  }

  static const String _homeOnboardingKey = 'home_onboarding_completed';
  static const String _dailyOnboardingKey = 'daily_onboarding_completed';
  static const String _weeklyOnboardingKey = 'weekly_onboarding_completed';
  static const String _calendarOnboardingKey = 'calendar_onboarding_completed';

  Future<void> _loadOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    state = {
      'home': prefs.getBool(_homeOnboardingKey) ?? false,
      'daily': prefs.getBool(_dailyOnboardingKey) ?? false,
      'weekly': prefs.getBool(_weeklyOnboardingKey) ?? false,
      'calendar': prefs.getBool(_calendarOnboardingKey) ?? false,
    };
  }

  Future<void> completeOnboarding(String screen) async {
    final prefs = await SharedPreferences.getInstance();
    
    String key;
    switch (screen) {
      case 'home':
        key = _homeOnboardingKey;
        break;
      case 'daily':
        key = _dailyOnboardingKey;
        break;
      case 'weekly':
        key = _weeklyOnboardingKey;
        break;
      case 'calendar':
        key = _calendarOnboardingKey;
        break;
      default:
        return;
    }

    await prefs.setBool(key, true);
    state = {...state, screen: true};
  }

  bool isOnboardingCompleted(String screen) {
    return state[screen] ?? false;
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingState, Map<String, bool>>((ref) {
  return OnboardingState();
});