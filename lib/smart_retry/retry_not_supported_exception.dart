/// Exception thrown when a retry operation is not supported for the given request.
class RetryNotSupportedException implements Exception {
  /// Creates a [RetryNotSupportedException] with an optional [message].
  RetryNotSupportedException([this.message]);

  /// Error message explaining why the retry is not supported.
  final String? message;

  @override
  String toString() {
    if (message == null) return 'RetryNotSupportedException';
    return 'RetryNotSupportedException: $message';
  }
}
