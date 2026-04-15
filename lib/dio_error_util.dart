import 'package:dio/dio.dart';

/// Utility class for handling [DioException] and converting them to human-readable messages.
class DioErrorUtil {
  /// Converts a [DioException] into a user-friendly error string.
  static String handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.cancel:
        return "Request to the server was cancelled.";
      case DioExceptionType.connectionTimeout:
        return "Connection timed out. Please check your internet.";
      case DioExceptionType.connectionError:
        return "Failed to connect to the server. Check your internet connection.";
      case DioExceptionType.receiveTimeout:
        return "Server did not respond in time (Receive timeout).";
      case DioExceptionType.sendTimeout:
        return "Request took too long to send (Send timeout).";
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode != null) {
          switch (statusCode) {
            case 400:
              return "Bad request. Please check your data.";
            case 401:
              return "Unauthorized access. Please login again.";
            case 403:
              return "Forbidden. You don't have permission.";
            case 404:
              return "Resource not found on the server.";
            case 500:
              return "Internal server error. Please try again later.";
            case 502:
              return "Bad gateway. Server is currently unavailable.";
            case 503:
              return "Service unavailable. Server might be down.";
            default:
              return "Received invalid status code: $statusCode";
          }
        }
        return "Received an invalid response from the server.";
      case DioExceptionType.badCertificate:
        return "SSL certificate validation failed. Connection is not secure.";
      case DioExceptionType.unknown:
        if (error.message != null && error.message!.contains("SocketException")) {
          return "No internet connection or server unreachable.";
        }
        return "An unexpected error occurred.";
    }
  }
}
