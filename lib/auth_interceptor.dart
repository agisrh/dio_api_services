import 'package:dio/dio.dart';

/// A professional interceptor to handle authentication via Bearer tokens.
///
/// Features:
/// - Automatic token injection into headers.
/// - Flexible token retrieval via [tokenProvider].
/// - Exclusion of specific paths (e.g., login, register).
class AuthInterceptor extends Interceptor {
  /// Creates an [AuthInterceptor].
  ///
  /// [tokenProvider] is the callback to fetch the token.
  /// [excludePaths] is the list of paths to skip authentication.
  /// [authPrefix] is the prefix for the Authorization header.
  /// [headerKey] is the header key for the Authorization header.
  AuthInterceptor({
    required this.tokenProvider,
    this.excludePaths,
    this.authPrefix = 'Bearer',
    this.headerKey = 'Authorization',
  });

  /// Callback to retrieve the authentication token.
  final Future<String?> Function() tokenProvider;

  /// Optional list of paths that do NOT require authentication.
  final List<String>? excludePaths;

  /// Format of the Authorization header prefix. Defaults to "Bearer".
  final String authPrefix;

  /// The header key to use. Defaults to "Authorization".
  final String headerKey;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check if current path is in the exclude list.
    final bool isExcluded = excludePaths?.any((path) => options.path.contains(path)) ?? false;

    if (!isExcluded) {
      final token = await tokenProvider();
      if (token != null && token.isNotEmpty) {
        options.headers[headerKey] = '$authPrefix $token'.trim();
      }
    }

    return super.onRequest(options, handler);
  }
}
