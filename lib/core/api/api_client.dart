import 'dart:convert';
import 'package:dio/dio.dart';
import '../storage/local_storage.dart';

class ApiClient {
  static const String baseUrl = 'https://taller-itla.ia3x.com/api';

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  static void _attachToken(Options options, String token) {
    options.headers ??= {};
    options.headers!['Authorization'] = 'Bearer $token';
  }

  // Encode JSON as datax form field
  static FormData _formData(Map<String, dynamic> data) {
    return FormData.fromMap({'datax': jsonEncode(data)});
  }

  // ── Public (no auth) ──────────────────────────────────────────────────────

  static Future<Response> get(String path, {Map<String, dynamic>? query}) {
    return _dio.get(path, queryParameters: query);
  }

  static Future<Response> postPublic(
      String path, Map<String, dynamic> data) async {
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

    final formMap = <String, dynamic>{
      'datax': jsonEncode(data),
    };
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
      formMap['$fileField'] ??= [];
      (formMap['$fileField'] as List).add(files[i]);
    }
    return _dio.post(path, data: FormData.fromMap(formMap), options: opts);
  }
}
