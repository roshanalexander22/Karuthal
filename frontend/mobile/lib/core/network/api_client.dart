import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/app_config.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';
import 'network_exceptions.dart';

/// Riverpod provider for the shared [Dio] instance.
final dioProvider = Provider<Dio>((ref) => _buildDio(ref));

/// Riverpod provider for the [ApiClient] facade.
final apiClientProvider = Provider<ApiClient>((ref) {
  final dioInstance = ref.watch(dioProvider);
  return ApiClient(dioInstance);
});

// ── Dio factory ──────────────────────────────────────────────────────────────

Dio _buildDio(Ref ref) {
  final log = AppLogger.forName('DioClient');

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
      sendTimeout: const Duration(milliseconds: AppConstants.sendTimeoutMs),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-App-Version': '0.1.0',
        'X-Platform': 'android',
      },
    ),
  );

  // Add interceptors in priority order
  dio.interceptors.addAll([
    _LoggingInterceptor(log),
    _JwtInterceptor(dio),
    _ErrorInterceptor(),
  ]);

  return dio;
}

// ── Logging Interceptor ───────────────────────────────────────────────────────

class _LoggingInterceptor extends Interceptor {
  _LoggingInterceptor(this._log);

  final AppLogger _log;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log.d('→ ${options.method} ${options.uri}');
    if (options.data != null) _log.d('  Body: ${options.data}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log.d('← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log.e(
      '✗ ${err.requestOptions.method} ${err.requestOptions.uri}',
      err,
    );
    handler.next(err);
  }
}

// ── JWT Interceptor ───────────────────────────────────────────────────────────

class _JwtInterceptor extends QueuedInterceptorsWrapper {
  _JwtInterceptor(this._dio);

  final Dio _dio;

  static const _storage = FlutterSecureStorage();
  static const _accessKey = AppConstants.prefKeyAccessToken;
  static const _refreshKey = AppConstants.prefKeyRefreshToken;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for auth endpoints to avoid circular dependency.
    final skipPaths = {
      ApiEndpoints.authLogin,
      ApiEndpoints.authRegister,
      ApiEndpoints.authRefresh,
    };
    if (skipPaths.any((p) => options.path.contains(p))) {
      handler.next(options);
      return;
    }

    final token = await _storage.read(key: _accessKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Attempt silent token refresh once.
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        // Retry the original request with the new token.
        try {
          final token = await _storage.read(key: _accessKey);
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $token';
          final response = await _dio.fetch(opts);
          handler.resolve(response);
          return;
        } catch (_) {
          // Fall through to error propagation.
        }
      }
    }
    handler.next(err);
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await _storage.read(key: _refreshKey);
      if (refreshToken == null) return false;

      final response = await _dio.post(
        ApiEndpoints.authRefresh,
        data: {'refresh_token': refreshToken},
      );

      final newAccess = response.data['access_token'] as String?;
      final newRefresh = response.data['refresh_token'] as String?;

      if (newAccess != null) {
        await _storage.write(key: _accessKey, value: newAccess);
        if (newRefresh != null) {
          await _storage.write(key: _refreshKey, value: newRefresh);
        }
        return true;
      }
    } catch (_) {
      // Could not refresh; user must re-login.
    }
    return false;
  }
}

// ── Error Interceptor ─────────────────────────────────────────────────────────

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Transform Dio exceptions into domain-specific [NetworkException]s.
    final appException = _map(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: appException,
        type: err.type,
        response: err.response,
        message: appException.message,
      ),
    );
  }

  NetworkException _map(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return const TimeoutException();
    }

    if (err.type == DioExceptionType.connectionError) {
      return const NoInternetException();
    }

    final statusCode = err.response?.statusCode;
    final message = _parseMessage(err.response?.data);

    return switch (statusCode) {
      401 => UnauthorizedException(message: message),
      403 => ForbiddenException(message: message),
      404 => NotFoundException(message: message),
      422 => ValidationException(
          message: message,
          errors: _parseErrors(err.response?.data),
        ),
      500 || 502 || 503 => ServerException(
          message: message,
          statusCode: statusCode,
        ),
      _ => NetworkException(
          message: message ?? 'An unexpected error occurred.',
          statusCode: statusCode,
        ),
    };
  }

  String? _parseMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['detail']?.toString() ??
          data['message']?.toString() ??
          data['error']?.toString();
    }
    return null;
  }

  Map<String, List<String>>? _parseErrors(dynamic data) {
    if (data is Map<String, dynamic> && data['errors'] is Map) {
      return (data['errors'] as Map).map(
        (k, v) => MapEntry(
          k.toString(),
          (v as List).map((e) => e.toString()).toList(),
        ),
      );
    }
    return null;
  }
}

// ── ApiClient facade ──────────────────────────────────────────────────────────

/// A thin facade over [Dio] providing typed helper methods.
///
/// Feature-specific repositories should inject this via Riverpod rather than
/// using [Dio] directly, so network concerns remain centralised.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters, options: options);

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _dio.patch<T>(path, data: data, options: options);

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _dio.delete<T>(path, data: data, options: options);

  Future<Response<T>> upload<T>(
    String path, {
    required FormData formData,
    ProgressCallback? onSendProgress,
  }) =>
      _dio.post<T>(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
        onSendProgress: onSendProgress,
      );
}
