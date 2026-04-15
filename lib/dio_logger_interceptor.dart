import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Levels of logging for the API services.
enum Level {
  /// Detailed debug information.
  debug,

  /// General information about the request/response.
  info,

  /// Warnings about potential issues.
  warning,

  /// Critical errors.
  error,

  /// Unexpected or "alien" errors.
  alien
}

/// A global function to log messages at specified specified [Level].
///
/// Only prints logs when [kDebugMode] is true.
void logDebug(String message, {Level level = Level.info}) {
  // Define ANSI escape codes for different colors
  const String resetColor = '\x1B[0m';
  const String redColor = '\x1B[31m'; // Red
  const String greenColor = '\x1B[32m'; // Green
  const String yellowColor = '\x1B[33m'; // Yellow
  const String cyanColor = '\x1B[36m'; // Cyan

  // Get the current time in hours, minutes, and seconds
  final now = DateTime.now();
  final timeString =
      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

  // Only log messages if the app is running in debug mode
  if (kDebugMode) {
    try {
      String logMessage;
      switch (level) {
        case Level.debug:
          logMessage = '$cyanColor[DEBUG][$timeString] $message$resetColor';
          break;
        case Level.info:
          logMessage = '$greenColor[INFO][$timeString] $message$resetColor';
          break;
        case Level.warning:
          logMessage = '$yellowColor[WARNING][$timeString] $message $resetColor';
          break;
        case Level.error:
          logMessage = '$redColor[ERROR][$timeString] $message $resetColor';
          break;
        case Level.alien:
          logMessage = '$redColor[ALIEN][$timeString] $message $resetColor';
          break;
      }
      // Use the DebugPrintCallback to ensure long strings are not truncated
      developer.log(logMessage);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

/// An interceptor that logs the requests and responses in a readable format.
class LoggerInterceptor extends Interceptor {
  /// Creates a [LoggerInterceptor] with configurable logging options.
  LoggerInterceptor({
    this.logRequestUrl = true,
    this.logRequestHeader = false,
    this.logRequestBody = false,
    this.logResponseHeader = false,
    this.logResponseBody = true,
    this.logResponseError = true,
  });

  /// Whether to print the request URL.
  final bool logRequestUrl;

  /// Whether to print the request headers.
  final bool logRequestHeader;

  /// Whether to print the request body.
  final bool logRequestBody;

  /// Whether to print the response body.
  final bool logResponseBody;

  /// Whether to print the response headers.
  final bool logResponseHeader;

  /// Whether to print error messages.
  final bool logResponseError;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final requestPath = '${options.baseUrl}${options.path}';

    // Check for per-request override
    final bool currentLogResponseError =
        options.extra['logResponseError'] ?? logResponseError;

    // Log the error request and error message
    if (currentLogResponseError) {
      logDebug('onError: ${options.method} request => $requestPath',
          level: Level.error);
      logDebug('onError: ${err.error}, Message: ${err.message}',
          level: Level.debug);
    }

    // Call the super class to continue handling the error
    return super.onError(err, handler);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestPath = '${options.baseUrl}${options.path}';

    // Check for per-request overrides
    final bool currentLogRequestUrl =
        options.extra['logRequestUrl'] ?? logRequestUrl;
    final bool currentLogRequestHeader =
        options.extra['logRequestHeader'] ?? logRequestHeader;
    final bool currentLogRequestBody =
        options.extra['logRequestBody'] ?? logRequestBody;

    // Log request details
    if (currentLogRequestUrl) {
      logDebug('onRequest: ${options.method} request => $requestPath',
          level: Level.info);
    }
    if (currentLogRequestHeader) {
      logDebug('onRequest: Request Headers => ${options.headers}',
          level: Level.info);
    }
    if (currentLogRequestBody) {
      logDebug('onRequest: Request Data => ${_prettyJsonEncode(options.data)}',
          level: Level.info);
    }

    // Call the super class to continue handling the request
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;

    // Check for per-request overrides
    final bool currentLogResponseBody =
        options.extra['logResponseBody'] ?? logResponseBody;
    final bool currentLogResponseHeader =
        options.extra['logResponseHeader'] ?? logResponseHeader;

    // Log the response status code and data
    if (currentLogResponseHeader) {
      logDebug('onResponse: Response Headers => ${response.headers}',
          level: Level.debug);
    }
    if (currentLogResponseBody) {
      logDebug(
          'onResponse: StatusCode: ${response.statusCode}, Data: ${_prettyJsonEncode(response.data)}',
          level: Level.debug); // Log formatted response data
    }

    // Call the super class to continue handling the response
    return super.onResponse(response, handler);
  }

  // Helper method to convert data to pretty JSON format
  String _prettyJsonEncode(dynamic data) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      final jsonString = encoder.convert(data);
      return jsonString;
    } catch (e) {
      return data.toString();
    }
  }
}
