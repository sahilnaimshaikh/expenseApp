import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/haptics.dart';
import '../../core_data/domain/models/expense.dart';
import '../domain/expense_filter.dart';
import 'expense_list_controller.dart';
import 'expense_filter_sheet.dart';

/// Expense List screen (stories.md US-05, extended in Unit 5 with
/// US-07/US-08/US-09, and Unit 7 with infinite scroll for NFR-2 scale).
/// Grouped by date, swipe-left to delete, swipe-right to edit, long-press
/// to enter multi-select, plus search/filter/sort.
class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Infinite-scroll trigger (performance-test-instructions.md): fetch
    // the next page once the user nears the bottom of the list.
    _scrollController.addListener(() {
      final threshold = _scrollController.position.maxScrollExtent - 300;
      if (_scrollController.position.pixels >= threshold) {
        ref.read(expenseListControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expenseListControllerProvider);
    final controller = ref.read(expenseListControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: state.isMultiSelectMode
            ? Text('${state.selectedIds.length} selected')
            : const Text('Expenses'),
        actions: state.isMultiSelectMode
            ? [
                Semantics(
                  label: 'Delete selected expenses',
                  child: IconButton(
                    key: const Key('expense-list-multiselect-delete-button'),
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      triggerDestructiveHaptic();
                      controller.deleteSelected();
                    },
                  ),
                ),
                Semantics(
                  label: 'Exit selection mode',
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: controller.exitMultiSelect,
                  ),
                ),
              ]
            : [
                Semantics(
                  label: 'Filter expenses',
                  child: IconButton(
                    key: const Key('expense-list-filter-button'),
                    icon: const Icon(Icons.filter_list),
                    onPressed: () => showExpenseFilterSheet(context, ref),
                  ),
                ),
                Semantics(
                  label: 'Sort expenses',
                  child: PopupMenuButton<ExpenseSort>(
                    key: const Key('expense-list-sort-dropdown'),
                    icon: const Icon(Icons.sort),
                    onSelected: controller.setSort,
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: ExpenseSort.newestFirst, child: Text('Newest First')),
                      PopupMenuItem(value: ExpenseSort.oldestFirst, child: Text('Oldest First')),
                      PopupMenuItem(value: ExpenseSort.highestAmount, child: Text('Highest Amount')),
                      PopupMenuItem(value: ExpenseSort.lowestAmount, child: Text('Lowest Amount')),
                    ],
                  ),
                ),
              ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('expense-list-add-button'),
        onPressed: () => context.push('/expenses/add'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              key: const Key('expense-list-search-bar'),
              decoration: const InputDecoration(
                hintText: 'Search expenses...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: controller.setSearchQuery,
            ),
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.expenses.isEmpty
                    ? const Center(
                        key: Key('expense-list-empty-state'),
                        child: Text('No expenses yet. Tap + to add your first one.'),
                      )
                    : ListView(
                        controller: _scrollController,
                        children: [
                          ...state.groupedByDate.entries.map((entry) {
                            return _DateGroup(date: entry.key, expenses: entry.value);
                          }),
                          if (state.isLoadingMore)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class _DateGroup extends StatelessWidget {
  const _DateGroup({required this.date, required this.expenses});

  final DateTime date;
  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            DateFormat.yMMMd().format(date),
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        ...expenses.map((e) => _ExpenseCard(expense: e)),
      ],
    );
  }
}

class _ExpenseCard extends ConsumerWidget {
  const _ExpenseCard({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expenseListControllerProvider);
    final controller = ref.read(expenseListControllerProvider.notifier);
    final isSelected = state.selectedIds.contains(expense.id);

    return Dismissible(
      key: Key('expense-list-card-${expense.id}'),
      background: Container(color: Colors.blue, alignment: Alignment.centerLeft, child: const Icon(Icons.edit)),
      secondaryBackground: Container(color: Colors.red, alignment: Alignment.centerRight, child: const Icon(Icons.delete)),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          triggerDestructiveHaptic();
          await controller.deleteOne(expense.id);
          return true;
        } else {
          context.pushEditRoute(expense.id);
          return false;
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          selected: isSelected,
          leading: state.isMultiSelectMode
              ? Checkbox(value: isSelected, onChanged: (_) => controller.toggleSelection(expense.id))
              : null,
          title: Text('₹${expense.amount.toStringAsFixed(2)}'),
          subtitle: Text(expense.description ?? expense.expenseType.name),
          onTap: () {
            if (state.isMultiSelectMode) {
              controller.toggleSelection(expense.id);
            } else {
              context.pushEditRoute(expense.id);
            }
          },
          onLongPress: () => controller.enterMultiSelect(expense.id),
        ),
      ),
    );
  }
}

extension _EditNavigation on BuildContext {
  void pushEditRoute(int id) => push('/expenses/edit/$id');
}
