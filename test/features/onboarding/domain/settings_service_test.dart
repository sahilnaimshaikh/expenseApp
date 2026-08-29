import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:expense_tracker/features/categories/domain/category_service.dart';
import 'package:expense_tracker/features/core_data/data/budget_repository.dart';
import 'package:expense_tracker/features/core_data/data/category_repository.dart';
import 'package:expense_tracker/features/core_data/data/expense_repository.dart';
import 'package:expense_tracker/features/core_data/data/settings_repository.dart';
import 'package:expense_tracker/features/core_data/domain/budget_service.dart';
import 'package:expense_tracker/features/core_data/domain/models/enums.dart';
import 'package:expense_tracker/features/onboarding/domain/onboarding_input.dart';
import 'package:expense_tracker/features/onboarding/domain/settings_service.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  group('SettingsService.completeOnboarding', () {
    late Isar isar;
    late SettingsService service;
    late SettingsRepository settingsRepository;
    late CategoryRepository categoryRepository;
    late BudgetRepository budgetRepository;

    setUp(() async {
      isar = await openTestIsar();
      settingsRepository = SettingsRepository(isar);
      categoryRepository = CategoryRepository(isar);
      budgetRepository = BudgetRepository(isar);
      service = SettingsService(
        settingsRepository,
        CategoryService(categoryRepository, ExpenseRepository(isar)),
        BudgetService(budgetRepository, ExpenseRepository(isar)),
      );
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('seeds default categories, saves currency, and marks onboarding complete', () async {
      await service.completeOnboarding(const OnboardingInput(currency: 'USD'));

      final settings = await settingsRepository.getSettings();
      expect(settings.currency, 'USD');
      expect(settings.onboardingComplete, isTrue);

      final categories = await categoryRepository.getAll();
      expect(categories, hasLength(13));
    });

    // BR-9: budget is skippable.
    test('does not create a budget when initialBudgetAmount is omitted', () async {
      await service.completeOnboarding(const OnboardingInput());

      final history = await budgetRepository.getBudgetHistory(LedgerScope.combined);
      expect(history, isEmpty);
    });

    test('creates a combined-mode budget when initialBudgetAmount is provided', () async {
      await service.completeOnboarding(const OnboardingInput(initialBudgetAmount: 15000));

      final now = DateTime.now();
      final budget = await budgetRepository.getBudget(now.month, now.year, LedgerScope.combined);
      expect(budget, isNotNull);
      expect(budget!.budgetAmount, 15000);
    });

    test('defaults an empty/blank currency to INR', () async {
      await service.completeOnboarding(const OnboardingInput(currency: '   '));
      final settings = await settingsRepository.getSettings();
      expect(settings.currency, 'INR');
    });

    test('isOnboardingComplete reflects the current state', () async {
      expect(await service.isOnboardingComplete(), isFalse);
      await service.completeOnboarding(const OnboardingInput());
      expect(await service.isOnboardingComplete(), isTrue);
    });
  });
}
