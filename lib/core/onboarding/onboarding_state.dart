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

  bool _isLoaded = false;

  Future<void> _loadOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = {
        'home': prefs.getBool(_homeOnboardingKey) ?? false,
        'daily': prefs.getBool(_dailyOnboardingKey) ?? false,
        'weekly': prefs.getBool(_weeklyOnboardingKey) ?? false,
        'calendar': prefs.getBool(_calendarOnboardingKey) ?? false,
      };
      _isLoaded = true;
    } catch (e) {
      // 에러 발생 시 기본값으로 설정
      state = {
        'home': false,
        'daily': false,
        'weekly': false,
        'calendar': false,
      };
      _isLoaded = true;
    }
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
    // 로딩이 완료되지 않았으면 false 반환 (온보딩 표시 안함)
    if (!_isLoaded) return true;
    
    return state[screen] ?? false;
  }

  // 로딩 상태 확인용 getter
  bool get isLoaded => _isLoaded;
}

final onboardingProvider = StateNotifierProvider<OnboardingState, Map<String, bool>>((ref) {
  return OnboardingState();
});