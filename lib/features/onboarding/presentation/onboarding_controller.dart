import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/onboarding_input.dart';
import '../domain/onboarding_providers.dart';

/// UI state for the onboarding wizard. Holds only simple orchestration —
/// business rules (BR-9, currency defaulting) live in SettingsService, per
/// Application Design's Q4 decision.
class OnboardingState {
  const OnboardingState({
    this.currency = 'INR',
    this.budgetAmountText = '',
    this.isSubmitting = false,
    this.errorMessage,
  });

  final String currency;
  final String budgetAmountText;
  final bool isSubmitting;
  final String? errorMessage;

  OnboardingState copyWith({
    String? currency,
    String? budgetAmountText,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return OnboardingState(
      currency: currency ?? this.currency,
      budgetAmountText: budgetAmountText ?? this.budgetAmountText,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void setCurrency(String value) {
    state = state.copyWith(currency: value, errorMessage: null);
  }

  void setBudgetAmountText(String value) {
    state = state.copyWith(budgetAmountText: value, errorMessage: null);
  }

  /// Returns true on success (caller should navigate to Dashboard/home).
  Future<bool> submit({required bool skipBudget}) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    double? budgetAmount;
    if (!skipBudget && state.budgetAmountText.trim().isNotEmpty) {
      final parsed = double.tryParse(state.budgetAmountText.trim());
      if (parsed == null || parsed <= 0) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Enter a valid budget amount, or tap Skip.',
        );
        return false;
      }
      budgetAmount = parsed;
    }

    try {
      final settingsService = await ref.read(settingsServiceProvider.future);
      await settingsService.completeOnboarding(
        OnboardingInput(currency: state.currency, initialBudgetAmount: budgetAmount),
      );
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: "Couldn't finish setup. Please try again.",
      );
      return false;
    }
  }
}

final NotifierProvider<OnboardingController, OnboardingState> onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(OnboardingController.new);
