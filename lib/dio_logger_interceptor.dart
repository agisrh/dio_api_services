import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

// Define an enum for the different log levels
enum Level { debug, info, warning, error, alien }

// Define a logDebug function that logs messages at the specified level
// log different colors
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
      //print(logMessage);
      // Use the DebugPrintCallback to ensure long strings are not truncated
      developer.log(logMessage);
    } catch (e) {
      print(e.toString());
    }
  }
}

// Define an interceptor that logs the requests and responses
class LoggerInterceptor extends Interceptor {
  /// Print request [Options]
  final bool requestUrl;

  /// Print request header [Options.headers]
  final bool requestHeader;

  /// Print request data [Options.data]
  final bool requestBody;

  /// Print [Response.data]
  final bool responseBody;

  /// Print [Response.headers]
  final bool responseHeader;

  /// Print error message
  final bool responseError;

  LoggerInterceptor({
    this.requestUrl = true,
    this.requestHeader = false,
    this.requestBody = false,
    this.responseHeader = false,
    this.responseBody = true,
    this.responseError = true,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final requestPath = '${options.baseUrl}${options.path}';

    final bool logResponseError = options.extra['logResponseError'] ?? responseError;

    // Log the error request and error message
    if (logResponseError) {
      logDebug('onError: ${options.method} request => $requestPath', level: Level.error);
      logDebug('onError: ${err.error}, Message: ${err.message}', level: Level.debug);
    }

    // Call the super class to continue handling the error
    return super.onError(err, handler);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestPath = '${options.baseUrl}${options.path}';

    final bool logRequestUrl = options.extra['logRequestUrl'] ?? requestUrl;
    final bool logRequestHeader = options.extra['logRequestHeader'] ?? requestHeader;
    final bool logRequestBody = options.extra['logRequestBody'] ?? requestBody;

    // Log request details
    if (logRequestUrl) {
      logDebug('onRequest: ${options.method} request => $requestPath', level: Level.info);
    }
    if (logRequestHeader) {
      logDebug('onRequest: Request Headers => ${options.headers}', level: Level.info);
    }
    if (logRequestBody) {
      logDebug('onRequest: Request Data => ${_prettyJsonEncode(options.data)}', level: Level.info);
    }

    // Call the super class to continue handling the request
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;

    final bool logResponseBody = options.extra['logResponseBody'] ?? responseBody;
    final bool logResponseHeader = options.extra['logResponseHeader'] ?? responseHeader;

    // Log the response status code and data
    if (logResponseBody) {
      logDebug('onResponse: StatusCode: ${response.statusCode}, Data: ${_prettyJsonEncode(response.data)}',
          level: Level.debug); // Log formatted response data
    }

    if (logResponseHeader) {
      logDebug('onResponse: Response Headers => ${response.headers}', level: Level.info);
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
