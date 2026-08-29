import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core_data/domain/budget_status.dart';
import '../../core_data/domain/core_data_domain_providers.dart';
import '../../core_data/domain/models/enums.dart';

class BudgetScreenState {
  const BudgetScreenState({
    this.status,
    this.isLoading = true,
    this.errorMessage,
  });

  final BudgetStatus? status;
  final bool isLoading;
  final String? errorMessage;

  BudgetScreenState copyWith({BudgetStatus? status, bool? isLoading, String? errorMessage}) {
    return BudgetScreenState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Drives the Budget screen (US-13 core portion). Defaults to combined
/// scope for the current month; scope switching is exposed for the
/// Dashboard/Reports units to reuse the same status shape.
class BudgetController extends Notifier<BudgetScreenState> {
  @override
  BudgetScreenState build() {
    Future.microtask(() => loadFor(LedgerScope.combined));
    return const BudgetScreenState();
  }

  Future<void> loadFor(LedgerScope scope) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final service = await ref.read(budgetServiceProvider.future);
      final now = DateTime.now();
      final status = await service.getBudgetStatus(now.month, now.year, scope);
      state = state.copyWith(status: status, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Couldn't load your budget.");
    }
  }

  Future<void> setBudgetAmount(double amount) async {
    final status = state.status;
    if (status == null) return;
    try {
      final service = await ref.read(budgetServiceProvider.future);
      await service.setBudgetAmount(month: status.month, year: status.year, scope: status.ledgerScope, amount: amount);
      await loadFor(status.ledgerScope);
    } catch (e) {
      state = state.copyWith(errorMessage: "Couldn't save the budget amount.");
    }
  }

  Future<void> updateThreshold(int threshold, bool enabled) async {
    final status = state.status;
    if (status == null) return;
    try {
      final service = await ref.read(budgetServiceProvider.future);
      await service.updateNotificationThresholds(
        month: status.month,
        year: status.year,
        scope: status.ledgerScope,
        thresholdFlags: {threshold: enabled},
      );
    } catch (e) {
      state = state.copyWith(errorMessage: "Couldn't update notification settings.");
    }
  }
}

final NotifierProvider<BudgetController, BudgetScreenState> budgetControllerProvider =
    NotifierProvider<BudgetController, BudgetScreenState>(BudgetController.new);
