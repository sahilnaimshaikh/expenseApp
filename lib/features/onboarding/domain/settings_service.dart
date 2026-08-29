import '../../categories/domain/category_service.dart';
import '../../core_data/data/settings_repository.dart';
import '../../core_data/domain/budget_service.dart';
import '../../core_data/domain/models/enums.dart';
import '../../core_data/domain/models/settings.dart';
import 'onboarding_input.dart';

/// Business logic for app-wide settings and first-launch onboarding.
///
/// Onboarding portion ([completeOnboarding], [isOnboardingComplete])
/// shipped in Unit 2. Ongoing-settings portion ([updateTheme],
/// [updateCurrency], [updateNotificationPreferences]) added here in
/// Unit 6, per unit-of-work.md — extending this class rather than
/// duplicating it.
class SettingsService {
  SettingsService(
    this._settingsRepository,
    this._categoryService,
    this._budgetService,
  );

  final SettingsRepository _settingsRepository;
  final CategoryService _categoryService;
  final BudgetService _budgetService;

  Future<bool> isOnboardingComplete() async {
    final settings = await _settingsRepository.getSettings();
    return settings.onboardingComplete;
  }

  /// BR-9: [OnboardingInput.initialBudgetAmount] is optional. Seeds default
  /// categories, saves the chosen currency, optionally creates the user's
  /// first combined-mode monthly budget, and marks onboarding complete.
  Future<void> completeOnboarding(OnboardingInput input) async {
    await _categoryService.ensureDefaultsSeeded();

    final settings = await _settingsRepository.getSettings();
    settings.currency = input.currency.trim().isEmpty ? 'INR' : input.currency.trim();
    settings.onboardingComplete = true;
    await _settingsRepository.updateSettings(settings);

    if (input.initialBudgetAmount != null) {
      final now = DateTime.now();
      await _budgetService.setBudgetAmount(
        month: now.month,
        year: now.year,
        scope: LedgerScope.combined,
        amount: input.initialBudgetAmount!,
      );
    }
  }

  Future<Settings> getSettings() => _settingsRepository.getSettings();

  Future<void> updateTheme(AppThemeMode mode) async {
    final settings = await _settingsRepository.getSettings();
    settings.theme = mode;
    await _settingsRepository.updateSettings(settings);
  }

  Future<void> updateCurrency(String currency) async {
    final settings = await _settingsRepository.getSettings();
    settings.currency = currency.trim().isEmpty ? 'INR' : currency.trim();
    await _settingsRepository.updateSettings(settings);
  }

  Future<void> updateNotificationPreferences({required bool enabled}) async {
    final settings = await _settingsRepository.getSettings();
    settings.notificationsEnabled = enabled;
    await _settingsRepository.updateSettings(settings);
  }
}
