// core/onboarding/onboarding_mixin.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abeul_planner/core/onboarding/onboarding_overlay.dart';
import 'package:abeul_planner/core/onboarding/onboarding_state.dart';
import 'package:abeul_planner/core/onboarding/global_onboarding_provider.dart';

mixin OnboardingMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  final ScrollController _scrollController = ScrollController();
  
  List<OnboardingStep> get onboardingSteps;
  String get onboardingKey;
  
  ScrollController get scrollController => _scrollController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowOnboarding();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _checkAndShowOnboarding() async {
    // 온보딩 상태가 로드될 때까지 대기
    final onboardingNotifier = ref.read(onboardingProvider.notifier);
    
    // 최대 3초까지 대기
    int attempts = 0;
    while (!onboardingNotifier.isLoaded && attempts < 30) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
    
    final isCompleted = onboardingNotifier.isOnboardingCompleted(onboardingKey);
    if (!isCompleted) {
      // 글로벌 온보딩 시작
      ref.read(globalOnboardingProvider.notifier).startOnboarding(
        steps: onboardingSteps,
        screenKey: onboardingKey,
        scrollController: _scrollController,
      );
    }
  }

  Widget buildWithOnboarding(Widget child) {
    return child;
  }
}