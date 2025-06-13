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
  
  // 스크롤 컨트롤러 getter 추가
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

  void _checkAndShowOnboarding() {
    final isCompleted = ref.read(onboardingProvider.notifier).isOnboardingCompleted(onboardingKey);
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
    // 온보딩은 PlannerScaffold에서 처리하므로 child만 반환
    return child;
  }
}