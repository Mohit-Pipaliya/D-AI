import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../config/app_constants.dart';
import '../errors/app_exception.dart';
import '../storage/local_storage.dart';
import '../utils/logger.dart';

/// Singleton Dio HTTP client with interceptors, retry logic,
/// and JWT token injection.
///
/// All external API communication goes through this client.
class ApiClient {
  /// Creates an [ApiClient] backed by [LocalStorage] for token access.
  ApiClient({required LocalStorage storage}) : _storage = storage {
    _dio = Dio(_baseOptions);
    _dio.interceptors.addAll([
      _AuthInterceptor(storage: _storage),
      _LoggingInterceptor(),
      _RetryInterceptor(dio: _dio),
    ]);
  }

  final LocalStorage _storage;
  late final Dio _dio;

  static BaseOptions get _baseOptions => BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(
          milliseconds: AppConstants.connectTimeoutMs,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.receiveTimeoutMs,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

  /// The underlying [Dio] instance (escape hatch for SSE streams etc.).
  Dio get dio => _dio;

  /// Performs an HTTP GET request.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Performs an HTTP POST request.
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Performs an HTTP PUT request.
  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Options? options,
  }) {
    return _dio.put<T>(path, data: data, options: options);
  }

  /// Performs an HTTP DELETE request.
  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Options? options,
  }) {
    return _dio.delete<T>(path, data: data, options: options);
  }
}

// ── Interceptors ────────────────────────────────────────────

/// Injects JWT Bearer token into every outgoing request.
class _AuthInterceptor extends Interceptor {
  _AuthInterceptor({required LocalStorage storage}) : _storage = storage;

  final LocalStorage _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(AppConstants.keyAccessToken);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      AppLogger.w('Received 401 — token may be expired');
      // TODO(auth): Implement refresh-token rotation.
    }
    handler.next(err);
  }
}

/// Logs request/response metadata without leaking PII.
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.d('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    AppLogger.d(
      '← ${response.statusCode} ${response.requestOptions.uri}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.e(
      '✖ ${err.requestOptions.method} ${err.requestOptions.uri} '
      '— ${err.message}',
    );
    handler.next(err);
  }
}

/// Automatic retry on transient network failures.
class _RetryInterceptor extends Interceptor {
  _RetryInterceptor({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_isRetryable(err)) {
      handler.next(err);
      return;
    }

    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;
    if (retryCount >= AppConstants.maxRetries) {
      handler.next(err);
      return;
    }

    final delay = Duration(milliseconds: 500 * (retryCount + 1));
    AppLogger.w('Retrying (${retryCount + 1}/${AppConstants.maxRetries}) '
        'after ${delay.inMilliseconds}ms');

    await Future<void>.delayed(delay);

    err.requestOptions.extra['retryCount'] = retryCount + 1;

    try {
      final response = await _dio.fetch<dynamic>(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _isRetryable(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}

/// Extension to convert [DioException] into typed [AppException].
extension DioExceptionMapper on DioException {
  /// Maps this Dio error to a domain [AppException].
  AppException toAppException() {
    if (response != null) {
      return ServerException(
        message ?? 'Server error',
        statusCode: response!.statusCode ?? 500,
        cause: this,
      );
    }
    return NetworkException(
      message ?? 'Network error',
      cause: this,
    );
  }
}
