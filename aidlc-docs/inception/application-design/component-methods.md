# Component Methods — Expense Tracker

**Note**: These are high-level method signatures for interface contracts. Detailed business rules (validation specifics, exact recalculation algorithms) are defined in per-unit Functional Design (CONSTRUCTION phase).

## Data Layer

### ExpenseRepository
| Method | Input | Output | Purpose |
|---|---|---|---|
| `create(Expense expense)` | Expense | `Future<Expense>` | Persist a new expense |
| `update(Expense expense)` | Expense | `Future<Expense>` | Persist changes to an existing expense |
| `delete(int id)` | int | `Future<void>` | Remove an expense by id |
| `getById(int id)` | int | `Future<Expense?>` | Fetch a single expense |
| `query(ExpenseQueryParams params)` | ExpenseQueryParams (date range, category, type, payment method, amount range, sort) | `Future<List<Expense>>` | Basic filtered/sorted fetch |
| `watchAll()` | — | `Stream<List<Expense>>` | Reactive stream for list/dashboard UIs |

### BudgetRepository
| Method | Input | Output | Purpose |
|---|---|---|---|
| `getBudget(int month, int year, LedgerScope scope)` | month, year, scope (Personal/Home/Combined) | `Future<Budget?>` | Fetch a budget record |
| `upsertBudget(Budget budget)` | Budget | `Future<Budget>` | Create or update a budget record |
| `getBudgetHistory(LedgerScope scope)` | scope | `Future<List<Budget>>` | Fetch historical budgets |

### CategoryRepository
| Method | Input | Output | Purpose |
|---|---|---|---|
| `getAll()` | — | `Future<List<Category>>` | Fetch all categories |
| `create(Category category)` | Category | `Future<Category>` | Persist a new (custom) category |
| `update(Category category)` | Category | `Future<Category>` | Update a category |
| `delete(int id)` | int | `Future<void>` | Remove a category |
| `seedDefaults()` | — | `Future<void>` | Insert the 13 default categories (first launch) |

### SettingsRepository
| Method | Input | Output | Purpose |
|---|---|---|---|
| `getSettings()` | — | `Future<Settings>` | Fetch current settings |
| `updateSettings(Settings settings)` | Settings | `Future<Settings>` | Persist settings changes |

## Domain Layer

### ExpenseService
| Method | Input | Output | Purpose |
|---|---|---|---|
| `addExpense(ExpenseInput input)` | ExpenseInput (amount, category, type, date, description?, paymentMethod?, tags?) | `Future<Expense>` | Validate and create an expense (US-02) |
| `editExpense(int id, ExpenseInput input)` | id, ExpenseInput | `Future<Expense>` | Validate and update an expense (US-03) |
| `deleteExpense(int id)` | int | `Future<void>` | Delete an expense (US-04) |
| `searchExpenses(String query)` | String | `Future<List<Expense>>` | Search by description/category/tags/payment method (US-07) |
| `filterAndSort(ExpenseFilter filter, ExpenseSort sort)` | ExpenseFilter, ExpenseSort | `Future<List<Expense>>` | Combined filter+sort (US-08, US-09) |

### CategoryService
| Method | Input | Output | Purpose |
|---|---|---|---|
| `ensureDefaultsSeeded()` | — | `Future<void>` | Called on first launch (US-06) |
| `createCustomCategory(CategoryInput input)` | CategoryInput (name, icon, color) | `Future<Category>` | Validate uniqueness, create custom category |
| `deleteCategory(int id)` | int | `Future<void>` | Delete with reassignment/orphan policy (finalized in Functional Design) |

### BudgetService
| Method | Input | Output | Purpose |
|---|---|---|---|
| `getBudgetStatus(int month, int year, LedgerScope scope)` | month, year, scope | `Future<BudgetStatus>` (amount, spent, remaining, percentage) | Compute current budget status (US-11, US-13) |
| `setBudgetAmount(int month, int year, LedgerScope scope, double amount)` | month, year, scope, amount | `Future<void>` | Configure a budget amount |
| `evaluateThresholds(int month, int year, LedgerScope scope)` | month, year, scope | `Future<List<ThresholdCrossing>>` | Determine which (if any) thresholds are newly crossed this call, applying the "fire at most once per month" rule (US-12) |
| `recalculate(int month, int year, LedgerScope scope)` | month, year, scope | `Future<BudgetStatus>` | Recompute status after an expense add/edit/delete |

### ReportService
| Method | Input | Output | Purpose |
|---|---|---|---|
| `monthlySpending(DateRange range, LedgerScope scope)` | range, scope | `Future<List<MonthlyTotal>>` | US-14 |
| `categoryAnalysis(int month, int year, LedgerScope scope)` | month, year, scope | `Future<List<CategoryTotal>>` | US-15 |
| `personalVsHome(int month, int year)` | month, year | `Future<LedgerComparison>` | US-16 |
| `topCategories(int month, int year, LedgerScope scope, int limit)` | month, year, scope, limit | `Future<List<CategoryTotal>>` | US-17 |
| `monthlyComparison(int month, int year, int monthsBack)` | month, year, monthsBack | `Future<MonthlyComparisonResult>` | US-18 |
| `budgetUtilization(int month, int year, LedgerScope scope)` | month, year, scope | `Future<double>` | US-19 (delegates to BudgetService internally) |

### NotificationService
| Method | Input | Output | Purpose |
|---|---|---|---|
| `notifyThresholdCrossed(ThresholdCrossing crossing)` | ThresholdCrossing | `Future<void>` | Fire a local notification for a threshold event (US-12) |
| `notifyEndOfMonthSummary(MonthlySummary summary)` | MonthlySummary | `Future<void>` | Fire optional end-of-month notification (FR-7.1) |

### BackupService
| Method | Input | Output | Purpose |
|---|---|---|---|
| `runScheduledBackup()` | — | `Future<void>` | Nightly automatic backup (US-20.1) |
| `createManualBackup(String? destinationPath)` | destinationPath? | `Future<File>` | On-demand ZIP backup (US-20.2) |
| `restoreFromBackup(File backupFile)` | File | `Future<void>` | Validate and restore; fails safely on corrupt input (US-20.3, US-20.4) |
| `pruneOldBackups()` | — | `Future<void>` | Apply retention policy (US-20.5, policy finalized in Functional Design) |

### ExportService
| Method | Input | Output | Purpose |
|---|---|---|---|
| `exportToCsv(ExpenseFilter? filter)` | filter? | `Future<File>` | US-21 |
| `exportToExcel(ExpenseFilter? filter)` | filter? | `Future<File>` | US-21 |
| `exportToJson(ExpenseFilter? filter)` | filter? | `Future<File>` | US-21 |

### SettingsService
| Method | Input | Output | Purpose |
|---|---|---|---|
| `completeOnboarding(String currency, double initialBudget)` | currency, initialBudget | `Future<void>` | US-01: seed categories, save currency, create initial budget |
| `isOnboardingComplete()` | — | `Future<bool>` | Determines first-launch routing |
| `updateTheme(ThemeMode mode)` | ThemeMode | `Future<void>` | US-22 |
| `updateCurrency(String currency)` | String | `Future<void>` | US-22 |
| `updateNotificationPreferences(NotificationPrefs prefs)` | NotificationPrefs | `Future<void>` | US-22 |

## Presentation Layer

Riverpod controller method signatures are intentionally deferred to per-unit Functional Design, since they are thin orchestration wrappers over the domain methods above (per Q4/Q5 decisions) and their exact shape depends on Flutter widget-tree needs determined during Units Generation/Functional Design.
