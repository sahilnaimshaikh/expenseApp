# Logical Components — Unit 1: Core Data & Categories

## Isar Database Provider
**Type**: Riverpod `Provider<Isar>` (singleton scope)
**Responsibility**: Opens the Isar instance once at app startup (registering all 4 schemas: Expense, Budget, Category, Settings), disposed only on app termination.
**Consumed by**: All 4 repositories in this unit; injected transitively into every later unit's repositories/services via Riverpod's dependency graph.

## Repository Components
ExpenseRepository, BudgetRepository, CategoryRepository, SettingsRepository — each a plain Dart class taking the Isar provider as a constructor dependency, exposed via its own Riverpod `Provider`.

## CategoryService Component
Plain Dart class depending on CategoryRepository and ExpenseRepository (for the BR-3 reassignment query), exposed via a Riverpod `Provider`.

## No Additional Infrastructure Components
Given this is an offline, single-process mobile app with no network, no distributed state, and no multi-user concurrency, the following infrastructure patterns are explicitly **not applicable** to this unit (and, per the project-wide Resiliency Baseline determination, to the app as a whole): message queues, caches (beyond Isar's own internal caching), circuit breakers, load balancers, service discovery.
