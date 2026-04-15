/// Base class for all API exceptions.
class ApiException implements Exception {
  /// Creates a new [ApiException].
  ApiException({required this.message, this.statusCode, this.data});

  /// A human-readable error message.
  final String message;

  /// The HTTP status code, if available.
  final int? statusCode;

  /// The raw response data, if available.
  final dynamic data;

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Thrown when there is no internet connection.
class NoInternetException extends ApiException {
  /// Creates a new [NoInternetException].
  NoInternetException()
      : super(message: "No internet connection", statusCode: 0);
}

/// Thrown when the request times out.
class ServerTimeoutException extends ApiException {
  /// Creates a new [ServerTimeoutException].
  ServerTimeoutException(String message)
      : super(message: message, statusCode: 408);
}

/// Thrown when the server returns a 4xx or 5xx error.
class ServerResponseException extends ApiException {
  /// Creates a new [ServerResponseException].
  ServerResponseException({
    required super.message,
    super.statusCode,
    super.data,
  });
}
