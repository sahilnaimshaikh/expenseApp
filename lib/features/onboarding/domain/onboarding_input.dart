/// Transient DTO carrying user input from the onboarding wizard into
/// [SettingsService.completeOnboarding]. See BR-9: [initialBudgetAmount]
/// is optional/skippable.
class OnboardingInput {
  const OnboardingInput({
    this.currency = 'INR',
    this.initialBudgetAmount,
  });

  final String currency;
  final double? initialBudgetAmount;
}
