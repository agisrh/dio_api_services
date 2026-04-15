// ignore_for_file: constant_identifier_names

import 'package:dio/dio.dart';
export 'package:dio/dio.dart';
import 'dio_error_util.dart';
import 'connectivity_status.dart';
import 'dio_logger_interceptor.dart';
import 'smart_retry/retry_interceptor.dart';
import 'api_exception.dart';
export 'api_exception.dart';
export 'auth_interceptor.dart';

/// HTTP methods supported by [DioApiService].
enum MethodRequest {
  /// HTTP POST method.
  POST,

  /// HTTP GET method.
  GET,

  /// HTTP PUT method.
  PUT,

  /// HTTP DELETE method.
  DELETE
}

/// A highly configurable API service built on top of [Dio].
///
/// Features include:
/// - Automatic retry logic
/// - Connectivity checking
/// - Pretty logging
/// - Standardized error handling
class DioApiService {
  /// Creates a new [DioApiService].
  ///
  /// [baseUrl] is the base URL for all requests.
  /// [dio] can be provided to use an existing Dio instance.
  /// [interceptors] can be provided to add custom interceptors.
  /// [checkConnectivity] if true, will check for internet before each request.
  /// [connectivityChecker] optional custom connectivity check function.
  DioApiService({
    required String baseUrl,
    Dio? dio,
    List<Interceptor>? interceptors,
    Duration connectTimeout = const Duration(seconds: 90),
    Duration? receiveTimeout = const Duration(seconds: 50),
    bool checkConnectivity = true,
    Future<bool> Function()? connectivityChecker,
    // Logger settings
    bool logRequestUrl = true,
    bool logRequestHeader = false,
    bool logRequestBody = false,
    bool logResponseBody = true,
    bool logResponseHeader = false,
    bool logResponseError = true,
  })  : _checkConnectivity = checkConnectivity,
        _connectivityChecker = connectivityChecker {
    _dio = dio ?? Dio();
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = connectTimeout;
    _dio.options.receiveTimeout = receiveTimeout;
    _dio.options.headers.addAll({
      'Accept': 'application/json',
    });
    _dio.options.receiveDataWhenStatusError = true;

    // Add custom interceptors if provided
    if (interceptors != null) {
      _dio.interceptors.addAll(interceptors);
    }

    // Default Interceptor for default headers
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (!options.headers.containsKey("Accept")) {
            options.headers['Accept'] = 'application/json';
          }
          return handler.next(options);
        },
      ),
    );

    // Logger Interceptor (Added only once)
    _dio.interceptors.add(LoggerInterceptor(
      logRequestUrl: logRequestUrl,
      logRequestHeader: logRequestHeader,
      logResponseHeader: logResponseHeader,
      logRequestBody: logRequestBody,
      logResponseBody: logResponseBody,
      logResponseError: logResponseError,
    ));

    // Retry Interceptor
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        logPrint: (message) => logDebug(message, level: Level.debug),
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
      ),
    );
  }

  late final Dio _dio;
  final bool _checkConnectivity;
  final Future<bool> Function()? _connectivityChecker;

  /// Makes an API call to the specified [url].
  ///
  /// [method] defaults to [MethodRequest.POST].
  /// [request] can be a [Map] or [FormData], it will be sent as the body.
  /// [header] additional headers for this specific call.
  /// [queryParameters] GET parameters.
  /// [options] additional [Options] for the request.
  /// [cancelToken] used to cancel the request.
  Future<Response> call(
    String url, {
    MethodRequest method = MethodRequest.POST,
    dynamic request,
    Map<String, dynamic>? header,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool useFormData = false,
    bool? logRequestUrl,
    bool? logRequestHeader,
    bool? logRequestBody,
    bool? logResponseBody,
    bool? logResponseHeader,
    bool? logResponseError,
  }) async {
    // Check Internet Connection
    if (_checkConnectivity) {
      final isOnline = _connectivityChecker != null
          ? await _connectivityChecker()
          : await ConnectivityStatus.hasNetwork();
      if (!isOnline) {
        throw NoInternetException();
      }
    }

    // Merge headers and options
    final requestOptions = options ?? Options();
    if (header != null) {
      requestOptions.headers = (requestOptions.headers ?? {})..addAll(header);
    }

    // Set per-request logging options
    requestOptions.extra ??= {};
    if (logRequestUrl != null) requestOptions.extra!['logRequestUrl'] = logRequestUrl;
    if (logRequestHeader != null) requestOptions.extra!['logRequestHeader'] = logRequestHeader;
    if (logRequestBody != null) requestOptions.extra!['logRequestBody'] = logRequestBody;
    if (logResponseBody != null) requestOptions.extra!['logResponseBody'] = logResponseBody;
    if (logResponseHeader != null) requestOptions.extra!['logResponseHeader'] = logResponseHeader;
    if (logResponseError != null) requestOptions.extra!['logResponseError'] = logResponseError;

    try {
      Response response;
      final dynamic body =
          (useFormData && request is Map<String, dynamic>) ? FormData.fromMap(request) : request;

      switch (method) {
        case MethodRequest.GET:
          response = await _dio.get(
            url,
            queryParameters: queryParameters ?? (request is Map<String, dynamic> ? request : null),
            options: requestOptions,
            cancelToken: cancelToken,
          );
          break;
        case MethodRequest.PUT:
          response = await _dio.put(
            url,
            data: body,
            queryParameters: queryParameters,
            options: requestOptions,
            cancelToken: cancelToken,
          );
          break;
        case MethodRequest.DELETE:
          response = await _dio.delete(
            url,
            data: body,
            queryParameters: queryParameters,
            options: requestOptions,
            cancelToken: cancelToken,
          );
          break;
        case MethodRequest.POST:
          response = await _dio.post(
            url,
            data: body,
            queryParameters: queryParameters,
            options: requestOptions,
            cancelToken: cancelToken,
          );
          break;
      }

      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  /// Downloads a file from [url] and saves it to [savePath].
  ///
  /// [onReceiveProgress] callback to track download progress.
  /// [cancelToken] used to cancel the download.
  Future<Response> download(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    bool? logRequestUrl,
    bool? logRequestHeader,
    bool? logRequestBody,
    bool? logResponseBody,
    bool? logResponseHeader,
    bool? logResponseError,
  }) async {
    // Check Internet Connection
    if (_checkConnectivity) {
      final isOnline = _connectivityChecker != null
          ? await _connectivityChecker()
          : await ConnectivityStatus.hasNetwork();
      if (!isOnline) {
        throw NoInternetException();
      }
    }

    try {
      final requestOptions = options ?? Options();
      requestOptions.extra ??= {};
      if (logRequestUrl != null) requestOptions.extra!['logRequestUrl'] = logRequestUrl;
      if (logRequestHeader != null) requestOptions.extra!['logRequestHeader'] = logRequestHeader;
      if (logRequestBody != null) requestOptions.extra!['logRequestBody'] = logRequestBody;
      if (logResponseBody != null) requestOptions.extra!['logResponseBody'] = logResponseBody;
      if (logResponseHeader != null) requestOptions.extra!['logResponseHeader'] = logResponseHeader;
      if (logResponseError != null) requestOptions.extra!['logResponseError'] = logResponseError;

      final response = await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: requestOptions,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  /// Internal error handler to standardize error responses.
  ApiException _handleDioError(DioException e) {
    final message = DioErrorUtil.handleError(e);
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    return ServerResponseException(
      message: message,
      statusCode: statusCode,
      data: data,
    );
  }
}
