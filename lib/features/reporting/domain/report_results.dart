/// Transient report result types. See
/// aidlc-docs/construction/search-filter-reporting/functional-design/
/// domain-entities.md for field definitions.
class MonthlyTotal {
  const MonthlyTotal({required this.month, required this.year, required this.total});

  final int month;
  final int year;
  final double total;
}

class CategoryTotal {
  const CategoryTotal({required this.categoryId, required this.categoryName, required this.total});

  final int categoryId;
  final String categoryName;
  final double total;
}

class LedgerComparison {
  const LedgerComparison({required this.personalTotal, required this.homeTotal});

  final double personalTotal;
  final double homeTotal;
}

class MonthlyComparisonResult {
  const MonthlyComparisonResult({required this.currentMonthTotal, required this.priorMonths});

  final double currentMonthTotal;
  final List<MonthlyTotal> priorMonths;
}
