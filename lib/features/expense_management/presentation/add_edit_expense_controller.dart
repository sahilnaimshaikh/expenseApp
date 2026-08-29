import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core_data/domain/core_data_domain_providers.dart';
import '../../core_data/domain/models/enums.dart';
import '../../core_data/domain/models/expense.dart';
import '../../notifications/domain/notification_providers.dart';
import '../domain/expense_input.dart';
import '../domain/expense_providers.dart';

class AddEditExpenseState {
  const AddEditExpenseState({
    this.amountText = '',
    this.categoryId,
    this.expenseType = ExpenseType.personal,
    this.date,
    this.description,
    this.paymentMethod,
    this.tags = const [],
    this.isSaving = false,
    this.errorMessage,
  });

  final String amountText;
  final int? categoryId;
  final ExpenseType expenseType;
  final DateTime? date;
  final String? description;
  final PaymentMethod? paymentMethod;
  final List<String> tags;
  final bool isSaving;
  final String? errorMessage;

  /// Mirrors BR-10's server-side validation so Save can be disabled
  /// proactively in the UI (defense-in-depth, not the sole check).
  bool get isValid {
    final amount = double.tryParse(amountText);
    return amount != null && amount > 0 && categoryId != null;
  }

  AddEditExpenseState copyWith({
    String? amountText,
    int? categoryId,
    ExpenseType? expenseType,
    DateTime? date,
    String? description,
    PaymentMethod? paymentMethod,
    List<String>? tags,
    bool? isSaving,
    String? errorMessage,
  }) {
    return AddEditExpenseState(
      amountText: amountText ?? this.amountText,
      categoryId: categoryId ?? this.categoryId,
      expenseType: expenseType ?? this.expenseType,
      date: date ?? this.date,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      tags: tags ?? this.tags,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}

/// Orchestrates the Add/Edit Expense flow: ExpenseService, then (per
/// Application Design's Q5 call-site-orchestration decision, extended
/// here in Unit 3) BudgetService.recalculate/evaluateThresholds and
/// NotificationService — see services.md's orchestration pattern.
class AddEditExpenseController extends Notifier<AddEditExpenseState> {
  @override
  AddEditExpenseState build() => const AddEditExpenseState();

  void setAmountText(String value) => state = state.copyWith(amountText: value, errorMessage: null);
  void setCategoryId(int value) => state = state.copyWith(categoryId: value, errorMessage: null);
  void setExpenseType(ExpenseType value) => state = state.copyWith(expenseType: value);
  void setDate(DateTime value) => state = state.copyWith(date: value);
  void setDescription(String value) => state = state.copyWith(description: value);
  void setPaymentMethod(PaymentMethod? value) => state = state.copyWith(paymentMethod: value);
  void setTags(List<String> value) => state = state.copyWith(tags: value);

  void loadForEdit(Expense expense) {
    state = AddEditExpenseState(
      amountText: expense.amount.toString(),
      categoryId: expense.categoryId,
      expenseType: expense.expenseType,
      date: expense.date,
      description: expense.description,
      paymentMethod: expense.paymentMethod,
      tags: expense.tags,
    );
  }

  /// Returns true on success. [editingId] null means "add new".
  Future<bool> save({int? editingId}) async {
    if (!state.isValid) {
      state = state.copyWith(errorMessage: 'Enter an amount and select a category.');
      return false;
    }

    state = state.copyWith(isSaving: true, errorMessage: null);

    final input = ExpenseInput(
      amount: double.parse(state.amountText),
      categoryId: state.categoryId!,
      expenseType: state.expenseType,
      date: state.date,
      description: state.description,
      paymentMethod: state.paymentMethod,
      tags: state.tags,
    );

    try {
      final service = await ref.read(expenseServiceProvider.future);
      final expense = editingId == null
          ? await service.addExpense(input)
          : await service.editExpense(editingId, input);

      await _recalculateAndNotify(expense.date, expense.expenseType);

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: "Couldn't save this expense. Please try again.");
      return false;
    }
  }

  /// The Unit 3 extension of the call-site orchestration seam: recompute
  /// both the ledger-specific and combined budgets, evaluate thresholds
  /// for each, and fire a notification per newly-crossed threshold.
  /// Failures here are caught so a budget/notification hiccup never
  /// undoes an already-successful expense save (BR-16's separation of
  /// concerns extends to this orchestration layer too).
  Future<void> _recalculateAndNotify(DateTime date, ExpenseType expenseType) async {
    try {
      final budgetService = await ref.read(budgetServiceProvider.future);
      final notificationService = ref.read(notificationServiceProvider);
      final scope = expenseType.toLedgerScope();

      for (final ledgerScope in {scope, LedgerScope.combined}) {
        await budgetService.recalculate(date.month, date.year, ledgerScope);
        final crossings = await budgetService.evaluateThresholds(date.month, date.year, ledgerScope);
        for (final crossing in crossings) {
          await notificationService.notifyThresholdCrossed(crossing);
        }
      }
    } catch (_) {
      // Fail-safe: the expense itself already saved successfully; a
      // budget/notification failure must not be surfaced as a save error.
    }
  }
}

final NotifierProvider<AddEditExpenseController, AddEditExpenseState> addEditExpenseControllerProvider =
    NotifierProvider<AddEditExpenseController, AddEditExpenseState>(AddEditExpenseController.new);
