import 'dart:async';
import 'package:dio/dio.dart';

/// Default implementation of retry evaluation logic.
class DefaultRetryEvaluator {
  /// Creates a [DefaultRetryEvaluator] with specific retryable HTTP statuses.
  DefaultRetryEvaluator(this._retryableStatuses);

  final Set<int> _retryableStatuses;

  /// Current retry attempt number.
  int currentAttempt = 0;

  /// Returns true only if the response hasn't been cancelled
  ///   or got a bad status code.
  // ignore: avoid-unused-parameters
  FutureOr<bool> evaluate(DioException error, int attempt) {
    bool shouldRetry;
    if (error.type == DioExceptionType.badResponse) {
      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        shouldRetry = isRetryable(statusCode);
      } else {
        shouldRetry = true;
      }
    } else {
      shouldRetry = error.type != DioExceptionType.cancel &&
          error.error is! FormatException;
    }
    currentAttempt = attempt;
    return shouldRetry;
  }

  /// Checks if a given [statusCode] is in the retryable list.
  bool isRetryable(int statusCode) => _retryableStatuses.contains(statusCode);
}
