/// Thrown by repository methods on any underlying storage failure.
///
/// Per business-rules.md BR-8: repositories never return null or swallow
/// errors on failure paths — they always throw this typed exception so
/// callers (services, and ultimately Riverpod's AsyncValue.error) get an
/// explicit, catchable failure. The [message] shown to end users must stay
/// generic (SECURITY-09/15); [cause] carries the underlying detail for
/// internal logging only — never surface [cause] directly in UI.
class RepositoryException implements Exception {
  const RepositoryException({
    required this.operation,
    required this.message,
    this.cause,
  });

  /// The repository operation that failed, e.g. "Expense.create".
  final String operation;

  /// A generic, user-safe description of the failure.
  final String message;

  /// The underlying error (e.g. an IsarError), for internal logging only.
  final Object? cause;

  @override
  String toString() => 'RepositoryException($operation): $message';
}
