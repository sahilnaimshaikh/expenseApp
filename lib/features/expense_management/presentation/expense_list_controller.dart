import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core_data/domain/core_data_domain_providers.dart';
import '../../core_data/domain/models/enums.dart';
import '../../core_data/domain/models/expense.dart';
import '../domain/expense_filter.dart';
import '../domain/expense_providers.dart';

class ExpenseListState {
  const ExpenseListState({
    this.expenses = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.selectedIds = const {},
    this.searchQuery = '',
    this.activeFilter = const ExpenseFilter(),
    this.activeSort = ExpenseSort.newestFirst,
    this.errorMessage,
  });

  static const int pageSize = 50;

  final List<Expense> expenses;
  final bool isLoading;

  /// True while fetching an additional page (distinct from [isLoading]'s
  /// full-reload spinner) — NFR-2/performance-test-instructions.md's
  /// infinite-scroll pattern for the unfiltered, unsearched case.
  final bool isLoadingMore;

  /// False once a page returns fewer than [pageSize] rows — no further
  /// pages exist. Reset to true on any reload (search/filter/sort change).
  final bool hasMore;

  final Set<int> selectedIds;

  /// US-07/US-08/US-09 state, added in Unit 5.
  final String searchQuery;
  final ExpenseFilter activeFilter;
  final ExpenseSort activeSort;

  final String? errorMessage;

  bool get isMultiSelectMode => selectedIds.isNotEmpty;

  /// Groups expenses by calendar date (stories.md US-05 AC1), newest date
  /// group first. Pure presentation-layer derivation — no new domain
  /// method needed, per business-logic-model.md Process 5.
  Map<DateTime, List<Expense>> get groupedByDate {
    final grouped = <DateTime, List<Expense>>{};
    for (final expense in expenses) {
      final day = DateTime(expense.date.year, expense.date.month, expense.date.day);
      grouped.putIfAbsent(day, () => []).add(expense);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final k in sortedKeys) k: grouped[k]!};
  }

  ExpenseListState copyWith({
    List<Expense>? expenses,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    Set<int>? selectedIds,
    String? searchQuery,
    ExpenseFilter? activeFilter,
    ExpenseSort? activeSort,
    String? errorMessage,
  }) {
    return ExpenseListState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      selectedIds: selectedIds ?? this.selectedIds,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: activeFilter ?? this.activeFilter,
      activeSort: activeSort ?? this.activeSort,
      errorMessage: errorMessage,
    );
  }
}

class ExpenseListController extends Notifier<ExpenseListState> {
  @override
  ExpenseListState build() {
    Future.microtask(load);
    return const ExpenseListState();
  }

  /// Full (re)load — resets pagination state. Used on first load and
  /// whenever search/filter/sort criteria change.
  Future<void> load() async {
    state = state.copyWith(isLoading: true, hasMore: true, errorMessage: null);
    try {
      final service = await ref.read(expenseServiceProvider.future);
      final hasActiveFilterOrSearch = state.searchQuery.isNotEmpty || _hasActiveFilter(state.activeFilter);

      List<Expense> expenses;
      bool hasMore;
      if (state.searchQuery.isNotEmpty) {
        // Search/filter results are bounded by the query itself, not by
        // page — infinite scroll only applies to the plain unfiltered list
        // (performance-test-instructions.md's scroll-performance scenario).
        expenses = await service.searchExpenses(state.searchQuery);
        hasMore = false;
      } else if (hasActiveFilterOrSearch) {
        expenses = await service.filterAndSort(state.activeFilter, state.activeSort);
        hasMore = false;
      } else {
        expenses = await service.listExpenses(limit: ExpenseListState.pageSize, offset: 0);
        hasMore = expenses.length == ExpenseListState.pageSize;
      }

      state = state.copyWith(expenses: expenses, isLoading: false, hasMore: hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Couldn't load your expenses.");
    }
  }

  /// Fetches the next page and appends it, for the plain unfiltered list
  /// only (NFR-2: 500,000+ record scale). Called from the Expense List
  /// screen's [ScrollController] when the user nears the list's end.
  Future<void> loadMore() async {
    final hasActiveFilterOrSearch = state.searchQuery.isNotEmpty || _hasActiveFilter(state.activeFilter);
    if (hasActiveFilterOrSearch || !state.hasMore || state.isLoadingMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final service = await ref.read(expenseServiceProvider.future);
      final nextPage = await service.listExpenses(
        limit: ExpenseListState.pageSize,
        offset: state.expenses.length,
      );

      state = state.copyWith(
        expenses: [...state.expenses, ...nextPage],
        isLoadingMore: false,
        hasMore: nextPage.length == ExpenseListState.pageSize,
      );
    } catch (e) {
      // Fail-safe: a failed page fetch just stops pagination silently;
      // the user still has everything loaded so far and can pull-to-refresh.
      state = state.copyWith(isLoadingMore: false);
    }
  }

  bool _hasActiveFilter(ExpenseFilter filter) {
    return filter.startDate != null ||
        filter.endDate != null ||
        filter.categoryId != null ||
        filter.expenseType != null ||
        filter.paymentMethod != null ||
        filter.minAmount != null ||
        filter.maxAmount != null;
  }

  /// US-07: instant search — updates the query and reloads.
  Future<void> setSearchQuery(String query) async {
    state = state.copyWith(searchQuery: query);
    await load();
  }

  /// US-08: applies a new filter and reloads.
  Future<void> applyFilter(ExpenseFilter filter) async {
    state = state.copyWith(activeFilter: filter);
    await load();
  }

  Future<void> clearFilter() async {
    state = state.copyWith(activeFilter: const ExpenseFilter());
    await load();
  }

  /// US-09: applies a new sort and reloads.
  Future<void> setSort(ExpenseSort sort) async {
    state = state.copyWith(activeSort: sort);
    await load();
  }

  Future<void> deleteOne(int id) async {
    final service = await ref.read(expenseServiceProvider.future);
    final target = state.expenses.where((e) => e.id == id).firstOrNull;

    await service.deleteExpense(id);

    if (target != null) await _recalculateAfterRemoval(target.date, target.expenseType);
    await load();
  }

  void toggleSelection(int id) {
    final updated = {...state.selectedIds};
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    state = state.copyWith(selectedIds: updated);
  }

  void enterMultiSelect(int initialId) {
    state = state.copyWith(selectedIds: {initialId});
  }

  void exitMultiSelect() {
    state = state.copyWith(selectedIds: {});
  }

  /// BR-13: transactional bulk delete for the multi-select action bar.
  Future<void> deleteSelected() async {
    final service = await ref.read(expenseServiceProvider.future);
    final targets = state.expenses.where((e) => state.selectedIds.contains(e.id)).toList();

    await service.deleteMany(state.selectedIds.toList());

    final affectedScopes = <(int, int, LedgerScope)>{};
    for (final e in targets) {
      affectedScopes.add((e.date.month, e.date.year, e.expenseType.toLedgerScope()));
      affectedScopes.add((e.date.month, e.date.year, LedgerScope.combined));
    }
    final budgetService = await ref.read(budgetServiceProvider.future);
    for (final (month, year, scope) in affectedScopes) {
      await budgetService.recalculate(month, year, scope);
    }

    state = state.copyWith(selectedIds: {});
    await load();
  }

  /// BR-16: recalculation only, never a notification, on removal — a
  /// deletion can only decrease spend, so evaluateThresholds would never
  /// find a new upward crossing here anyway, but recalculation still keeps
  /// firedThresholds/percentage state consistent for display purposes.
  Future<void> _recalculateAfterRemoval(DateTime date, ExpenseType expenseType) async {
    try {
      final budgetService = await ref.read(budgetServiceProvider.future);
      final scope = expenseType.toLedgerScope();
      await budgetService.recalculate(date.month, date.year, scope);
      await budgetService.recalculate(date.month, date.year, LedgerScope.combined);
    } catch (_) {
      // Fail-safe: deletion already succeeded; recalculation failure is
      // non-critical (display will just show stale figures until reload).
    }
  }
}

final NotifierProvider<ExpenseListController, ExpenseListState> expenseListControllerProvider =
    NotifierProvider<ExpenseListController, ExpenseListState>(ExpenseListController.new);
