import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../storage/local_storage.dart';

class ApiClient {
  static const String baseUrl = 'https://taller-itla.ia3x.com/api';

  // ── Concurrent 401 guard ──────────────────────────────────────────────────
  // Dart's event loop is single-threaded: the check-and-set below the first
  // `await` boundary is effectively atomic.
  static bool _isRefreshing = false;
  static Completer<bool>? _refreshCompleter;

  static final Dio _dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException err, ErrorInterceptorHandler handler) async {
        final response = err.response;
        final opts = err.requestOptions;

        // Only intercept 401 Unauthorized
        if (response?.statusCode != 401) {
          return handler.next(err);
        }

        // Prevent infinite retry: if this request was already a retry, give up
        if (opts.extra['retried'] == true) {
          await LocalStorage.clear();
          return handler.reject(_sessionExpiredError(opts, response));
        }

        // ── Another request is already refreshing — queue behind it ──────
        if (_isRefreshing) {
          final success = await _refreshCompleter!.future;
          if (!success) return handler.reject(err);
          try {
            opts.extra['retried'] = true;
            return handler.resolve(await _retry(opts));
          } catch (_) {
            return handler.reject(err);
          }
        }

        // ── First 401: kick off the token refresh ─────────────────────────
        _isRefreshing = true;
        _refreshCompleter = Completer<bool>();

        try {
          final newToken = await _performRefresh();
          _refreshCompleter!.complete(true);
          _isRefreshing = false;

          opts.headers['Authorization'] = 'Bearer $newToken';
          opts.extra['retried'] = true;
          return handler.resolve(await _retry(opts));
        } catch (_) {
          _refreshCompleter!.complete(false);
          _isRefreshing = false;
          await LocalStorage.clear();
          return handler.reject(_sessionExpiredError(opts, response));
        }
      },
    ));

    return dio;
  }

  // ── Refresh helpers ───────────────────────────────────────────────────────

  /// Calls /auth/refresh using a fresh Dio instance so the interceptor above
  /// is never re-entered during the refresh itself.
  static Future<String> _performRefresh() async {
    final refreshToken = await LocalStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('No refresh token');
    }

    final freshDio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ));

    final res = await freshDio.post(
      '/auth/refresh',
      data: FormData.fromMap(
          {'datax': jsonEncode({'refreshToken': refreshToken})}),
      options: Options(contentType: 'multipart/form-data'),
    );

    final data = res.data;
    if (data['success'] == true) {
      final token = data['data']['token'] as String;
      final newRefresh = data['data']['refreshToken'] as String;
      await LocalStorage.saveToken(token, newRefresh);
      return token;
    }
    throw Exception(data['message'] ?? 'Token expirado');
  }

  /// Retries a request, cloning FormData so it can be re-sent.
  static Future<Response> _retry(RequestOptions opts) {
    dynamic data = opts.data;
    if (data is FormData) data = data.clone();

    return _dio.request(
      opts.path,
      data: data,
      queryParameters: opts.queryParameters,
      options: Options(
        method: opts.method,
        headers: opts.headers,
        contentType: opts.contentType,
        extra: opts.extra,
      ),
    );
  }

  static DioException _sessionExpiredError(
      RequestOptions opts, Response? response) {
    return DioException(
      requestOptions: opts,
      response: response,
      type: DioExceptionType.badResponse,
      error: Exception(
          'Sesión expirada. Por favor inicia sesión nuevamente.'),
    );
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  static void _attachToken(Options options, String token) {
    options.headers ??= {};
    options.headers!['Authorization'] = 'Bearer $token';
  }

  /// Encodes [data] as the `datax` multipart form field required by this API.
  static FormData _formData(Map<String, dynamic> data) =>
      FormData.fromMap({'datax': jsonEncode(data)});

  // ── Public (no auth) ──────────────────────────────────────────────────────

  static Future<Response> get(String path,
      {Map<String, dynamic>? query}) {
    return _dio.get(path, queryParameters: query);
  }

  static Future<Response> postPublic(
      String path, Map<String, dynamic> data) {
    return _dio.post(
      path,
      data: _formData(data),
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  // ── Authenticated ─────────────────────────────────────────────────────────

  static Future<Response> getAuth(String path,
      {Map<String, dynamic>? query}) async {
    final token = await LocalStorage.getToken();
    final opts = Options();
    if (token != null) _attachToken(opts, token);
    return _dio.get(path, queryParameters: query, options: opts);
  }

  static Future<Response> postAuth(
      String path, Map<String, dynamic> data) async {
    final token = await LocalStorage.getToken();
    final opts = Options(contentType: 'multipart/form-data');
    if (token != null) _attachToken(opts, token);
    return _dio.post(path, data: _formData(data), options: opts);
  }

  static Future<Response> postAuthMultipart(
      String path, Map<String, dynamic> data,
      {List<MapEntry<String, MultipartFile>>? files,
      String fileField = 'foto'}) async {
    final token = await LocalStorage.getToken();
    final opts = Options(contentType: 'multipart/form-data');
    if (token != null) _attachToken(opts, token);

    final formMap = <String, dynamic>{'datax': jsonEncode(data)};
    if (files != null) {
      for (final f in files) {
        formMap[f.key] = f.value;
      }
    }
    return _dio.post(path, data: FormData.fromMap(formMap), options: opts);
  }

  static Future<Response> postAuthMultipartFiles(
    String path,
    Map<String, dynamic> data,
    List<MultipartFile> files,
    String fileField,
  ) async {
    final token = await LocalStorage.getToken();
    final opts = Options(contentType: 'multipart/form-data');
    if (token != null) _attachToken(opts, token);

    final formMap = <String, dynamic>{'datax': jsonEncode(data)};
    for (int i = 0; i < files.length; i++) {
      formMap[fileField] ??= [];
      (formMap[fileField] as List).add(files[i]);
    }
    return _dio.post(path, data: FormData.fromMap(formMap), options: opts);
  }
}
