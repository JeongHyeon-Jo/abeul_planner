// core/onboarding/global_onboarding_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abeul_planner/core/onboarding/onboarding_overlay.dart';

class GlobalOnboardingState {
  final bool isActive;
  final List<OnboardingStep> steps;
  final int currentStep;
  final String screenKey;
  final ScrollController? scrollController;
  final GlobalKey? bottomNavKey;

  const GlobalOnboardingState({
    this.isActive = false,
    this.steps = const [],
    this.currentStep = 0,
    this.screenKey = '',
    this.scrollController,
    this.bottomNavKey,
  });

  GlobalOnboardingState copyWith({
    bool? isActive,
    List<OnboardingStep>? steps,
    int? currentStep,
    String? screenKey,
    ScrollController? scrollController,
    GlobalKey? bottomNavKey,
  }) {
    return GlobalOnboardingState(
      isActive: isActive ?? this.isActive,
      steps: steps ?? this.steps,
      currentStep: currentStep ?? this.currentStep,
      screenKey: screenKey ?? this.screenKey,
      scrollController: scrollController ?? this.scrollController,
      bottomNavKey: bottomNavKey ?? this.bottomNavKey,
    );
  }
}

class GlobalOnboardingNotifier extends StateNotifier<GlobalOnboardingState> {
  GlobalOnboardingNotifier() : super(const GlobalOnboardingState());

  void startOnboarding({
    required List<OnboardingStep> steps,
    required String screenKey,
    ScrollController? scrollController,
    GlobalKey? bottomNavKey,
  }) {
    final updatedSteps = steps.map((step) {
      if (step.title == '네비게이션 바' && step.targetKey == null) {
        return OnboardingStep(
          title: step.title,
          description: step.description,
          targetKey: bottomNavKey,
        );
      }
      return step;
    }).toList();

    state = state.copyWith(
      isActive: true,
      steps: updatedSteps,
      currentStep: 0,
      screenKey: screenKey,
      scrollController: scrollController,
      bottomNavKey: bottomNavKey,
    );
  }

  void nextStep() {
    if (state.currentStep < state.steps.length - 1) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void completeOnboarding() {
    state = const GlobalOnboardingState();
  }

  void skipOnboarding() {
    state = const GlobalOnboardingState();
  }
}

final globalOnboardingProvider = StateNotifierProvider<GlobalOnboardingNotifier, GlobalOnboardingState>((ref) {
  return GlobalOnboardingNotifier();
});