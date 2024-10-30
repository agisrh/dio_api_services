import 'package:dio/dio.dart';
export 'package:dio/dio.dart';
import 'dio_error_util.dart';
import 'connectivity_status.dart';
import 'dio_logger_interceptor.dart';
import 'smart_retry/retry_interceptor.dart';

// ignore: constant_identifier_names
enum MethodRequest { POST, GET, PUT, DELETE }

class DioApiService {
  final Dio _dio = Dio();

  DioApiService({
    required String baseUrl,
    Duration connectTimeout = const Duration(seconds: 90),
    Duration? receiveTimeout = const Duration(seconds: 50),
  }) {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = connectTimeout;
    _dio.options.receiveTimeout = receiveTimeout;
    _dio.options.headers = {
      'Accept': 'application/json',
    };
    _dio.options.receiveDataWhenStatusError = true;

    //Interceptors header
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers.addAll(
            {
              if (!options.headers.containsKey("Accept")) 'Accept': 'application/json',
            },
          );

          return handler.next(options);
        },
      ),
    );

    // Interceptor retry
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        logPrint: print, // specify log function (optional)
        retries: 3, // retry count (optional)
        retryDelays: const [
          // set delays between retries (optional)
          Duration(seconds: 1), // wait 1 sec before first retry
          Duration(seconds: 2), // wait 2 sec before second retry
          Duration(seconds: 3), // wait 3 sec before third retry
        ],
      ),
    );
  }

  Future<Response> call(
    String url, {
    MethodRequest method = MethodRequest.POST,
    dynamic request,
    Map<String, String>? header,
    bool useFormData = false,
    bool logRequestUrl = true,
    bool logRequestHeader = false,
    bool logRequestBody = false,
    bool logResponseBody = true,
    bool logResponseHeader = false,
    bool logResponseError = true,
  }) async {
    // Check Internet Connection
    bool isOnline = await ConnectivityStatus.hasNetwork();
    if (isOnline != true) {
      Response response = Response(
        data: {
          "message": "You're offline. Check your connection",
        },
        statusCode: 00,
        requestOptions: RequestOptions(path: ''),
      );
      return response;
    }

    // Add header options
    if (header != null) {
      _dio.options.headers = header;
    }

    // Dio Logger
    _dio.interceptors.add(LoggerInterceptor(
      requestUrl: logRequestUrl,
      requestHeader: logRequestHeader,
      responseHeader: logResponseHeader,
      requestBody: logRequestBody,
      responseBody: logResponseBody,
      responseError: logResponseError,
    ));

    try {
      Response response;
      switch (method) {
        case MethodRequest.GET:
          response = await _dio.get(url, queryParameters: request);
          break;
        case MethodRequest.PUT:
          response = await _dio.put(
            url,
            data: useFormData ? FormData.fromMap(request!) : request,
          );
          break;
        case MethodRequest.DELETE:
          response = await _dio.delete(
            url,
            data: useFormData ? FormData.fromMap(request!) : request,
          );
          break;
        default:
          response = await _dio.post(
            url,
            data: useFormData ? FormData.fromMap(request!) : request,
          );
      }

      return response;
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        if (!(e.response?.data as Map).containsKey("message")) {
          (e.response?.data as Map).addAll(<String, dynamic>{
            "message": DioErrorUtil.handleError(e),
          });
        }

        return e.response!;
      } else {
        Response response = Response(
          data: {
            "message": DioErrorUtil.handleError(e),
          },
          requestOptions: e.requestOptions,
          statusCode: e.response?.statusCode,
        );
        return response;
      }
    }
  }
}
