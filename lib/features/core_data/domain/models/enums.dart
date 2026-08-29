/// Ledger an expense belongs to. Always personal or home — never combined
/// (combined is a Budget-only aggregation concept, see [LedgerScope]).
enum ExpenseType {
  personal,
  home,
}

/// Ledger scope a Budget row applies to. [LedgerScope.combined] means the
/// budget covers both personal and home spending together (the default
/// mode per requirements.md FR-3.2); [LedgerScope.personal] /
/// [LedgerScope.home] are used only when the user opts into per-ledger
/// budgets.
enum LedgerScope {
  personal,
  home,
  combined,
}

/// Payment method used for an expense. Optional on [Expense].
enum PaymentMethod {
  cash,
  upi,
  debitCard,
  creditCard,
  bankTransfer,
}

/// User-selectable app theme preference.
enum AppThemeMode {
  dark,
  light,
  system,
}

/// Converts an [ExpenseType] to the equivalent [LedgerScope] for querying
/// budgets/reports that operate on [LedgerScope] (Combined/Personal/Home).
extension ExpenseTypeToLedgerScope on ExpenseType {
  LedgerScope toLedgerScope() {
    switch (this) {
      case ExpenseType.personal:
        return LedgerScope.personal;
      case ExpenseType.home:
        return LedgerScope.home;
    }
  }
}
