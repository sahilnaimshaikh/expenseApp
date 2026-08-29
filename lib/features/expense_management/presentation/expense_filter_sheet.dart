import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../categories/domain/category_providers.dart';
import '../../core_data/domain/models/enums.dart';
import '../domain/expense_filter.dart';
import 'expense_list_controller.dart';

/// Filter bottom sheet for the Expense List (stories.md US-08). Presents
/// category, expense type, payment method, date range, and amount range
/// fields; applies BR-21 (AND-combined) and surfaces BR-22's validation
/// error inline.
Future<void> showExpenseFilterSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _ExpenseFilterSheetContent(),
  );
}

class _ExpenseFilterSheetContent extends ConsumerStatefulWidget {
  const _ExpenseFilterSheetContent();

  @override
  ConsumerState<_ExpenseFilterSheetContent> createState() => _ExpenseFilterSheetContentState();
}

class _ExpenseFilterSheetContentState extends ConsumerState<_ExpenseFilterSheetContent> {
  int? _categoryId;
  ExpenseType? _expenseType;
  PaymentMethod? _paymentMethod;
  DateTime? _startDate;
  DateTime? _endDate;
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final current = ref.read(expenseListControllerProvider).activeFilter;
    _categoryId = current.categoryId;
    _expenseType = current.expenseType;
    _paymentMethod = current.paymentMethod;
    _startDate = current.startDate;
    _endDate = current.endDate;
    if (current.minAmount != null) _minAmountController.text = current.minAmount!.toString();
    if (current.maxAmount != null) _maxAmountController.text = current.maxAmount!.toString();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Filter Expenses', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            categoriesAsync.when(
              data: (categories) => DropdownButtonFormField<int?>(
                decoration: const InputDecoration(labelText: 'Category'),
                value: _categoryId,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Any')),
                  ...categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                ],
                onChanged: (value) => setState(() => _categoryId = value),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => const SizedBox.shrink(),
            ),
            DropdownButtonFormField<ExpenseType?>(
              decoration: const InputDecoration(labelText: 'Expense Type'),
              value: _expenseType,
              items: [
                const DropdownMenuItem(value: null, child: Text('Any')),
                ...ExpenseType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))),
              ],
              onChanged: (value) => setState(() => _expenseType = value),
            ),
            DropdownButtonFormField<PaymentMethod?>(
              decoration: const InputDecoration(labelText: 'Payment Method'),
              value: _paymentMethod,
              items: [
                const DropdownMenuItem(value: null, child: Text('Any')),
                ...PaymentMethod.values.map((m) => DropdownMenuItem(value: m, child: Text(m.name))),
              ],
              onChanged: (value) => setState(() => _paymentMethod = value),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minAmountController,
                    decoration: const InputDecoration(labelText: 'Min Amount'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _maxAmountController,
                    decoration: const InputDecoration(labelText: 'Max Amount'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const Key('expense-filter-sheet-clear-button'),
                    onPressed: () async {
                      await ref.read(expenseListControllerProvider.notifier).clearFilter();
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    key: const Key('expense-filter-sheet-apply-button'),
                    onPressed: _applyFilter,
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _applyFilter() async {
    final minAmount = _minAmountController.text.trim().isEmpty ? null : double.tryParse(_minAmountController.text.trim());
    final maxAmount = _maxAmountController.text.trim().isEmpty ? null : double.tryParse(_maxAmountController.text.trim());

    // BR-22: mirrors ExpenseService's server-side rejection so the user
    // sees a validation message inline rather than a silent empty result.
    if (minAmount != null && maxAmount != null && minAmount > maxAmount) {
      setState(() => _errorMessage = 'Minimum amount cannot be greater than maximum amount.');
      return;
    }

    final filter = ExpenseFilter(
      categoryId: _categoryId,
      expenseType: _expenseType,
      paymentMethod: _paymentMethod,
      startDate: _startDate,
      endDate: _endDate,
      minAmount: minAmount,
      maxAmount: maxAmount,
    );

    await ref.read(expenseListControllerProvider.notifier).applyFilter(filter);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }
}
