import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../categories/domain/category_providers.dart';
import '../../core_data/domain/models/enums.dart';
import 'add_edit_expense_controller.dart';

/// Add/Edit Expense screen (stories.md US-02/US-03). Designed to satisfy
/// the "lightning fast" definition from application-design-plan.md Q7:
/// amount + category + type + Save = 4 interactions, date defaults to
/// today, all other fields optional and visually de-emphasized.
class AddEditExpenseScreen extends ConsumerWidget {
  const AddEditExpenseScreen({super.key, this.editingId});

  final int? editingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addEditExpenseControllerProvider);
    final controller = ref.read(addEditExpenseControllerProvider.notifier);
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(editingId == null ? 'Add Expense' : 'Edit Expense')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('expense-amount-input'),
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹ '),
                onChanged: controller.setAmountText,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ExpenseTypeButton(
                      keyName: 'expense-type-personal-button',
                      label: 'Personal',
                      selected: state.expenseType == ExpenseType.personal,
                      onTap: () => controller.setExpenseType(ExpenseType.personal),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ExpenseTypeButton(
                      keyName: 'expense-type-home-button',
                      label: 'Home',
                      selected: state.expenseType == ExpenseType.home,
                      onTap: () => controller.setExpenseType(ExpenseType.home),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              categoriesAsync.when(
                data: (categories) => DropdownButtonFormField<int>(
                  key: const Key('expense-category-picker'),
                  decoration: const InputDecoration(labelText: 'Category'),
                  value: state.categoryId,
                  items: categories
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) controller.setCategoryId(value);
                  },
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, st) => Text('Could not load categories: $e'),
              ),
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text('More details (optional)'),
                children: [
                  TextField(
                    key: const Key('expense-description-input'),
                    decoration: const InputDecoration(labelText: 'Description'),
                    onChanged: controller.setDescription,
                  ),
                  DropdownButtonFormField<PaymentMethod?>(
                    key: const Key('expense-payment-method-picker'),
                    decoration: const InputDecoration(labelText: 'Payment Method'),
                    value: state.paymentMethod,
                    items: PaymentMethod.values
                        .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
                        .toList(),
                    onChanged: controller.setPaymentMethod,
                  ),
                  ListTile(
                    key: const Key('expense-date-picker'),
                    title: Text('Date: ${(state.date ?? DateTime.now()).toLocal()}'.split(' ').first),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: state.date ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) controller.setDate(picked);
                    },
                  ),
                  TextField(
                    key: const Key('expense-tags-input'),
                    decoration: const InputDecoration(labelText: 'Tags (comma-separated)'),
                    onChanged: (value) => controller.setTags(
                      value.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
                    ),
                  ),
                ],
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(state.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('expense-save-button'),
                onPressed: state.isSaving
                    ? null
                    : () async {
                        final success = await controller.save(editingId: editingId);
                        if (success && context.mounted) context.pop();
                      },
                child: state.isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseTypeButton extends StatelessWidget {
  const _ExpenseTypeButton({
    required this.keyName,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String keyName;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return selected
        ? FilledButton(key: Key(keyName), onPressed: onTap, child: Text(label))
        : OutlinedButton(key: Key(keyName), onPressed: onTap, child: Text(label));
  }
}
