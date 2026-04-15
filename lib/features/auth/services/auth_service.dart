import '../../../core/api/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../models/auth_model.dart';

class AuthService {
  static Future<String> registro(String matricula) async {
    final res = await ApiClient.postPublic('/auth/registro', {'matricula': matricula});
    final data = res.data;
    if (data['success'] == true) {
      final token = data['data']['token'] as String;
      await LocalStorage.saveTempToken(token);
      return token;
    }
    throw Exception(data['message'] ?? 'Error en registro');
  }

  static Future<AuthTokens> activar(
      String token, String contrasena) async {
    final res = await ApiClient.postPublic(
        '/auth/activar', {'token': token, 'contrasena': contrasena});
    final data = res.data;
    if (data['success'] == true) {
      final tokens = AuthTokens.fromJson(data['data']);
      await LocalStorage.saveToken(tokens.token, tokens.refreshToken);
      return tokens;
    }
    throw Exception(data['message'] ?? 'Error al activar');
  }

  static Future<AuthTokens> login(
      String matricula, String contrasena) async {
    final res = await ApiClient.postPublic(
        '/auth/login', {'matricula': matricula, 'contrasena': contrasena});
    final data = res.data;
    if (data['success'] == true) {
      final tokens = AuthTokens.fromJson(data['data']);
      await LocalStorage.saveToken(tokens.token, tokens.refreshToken);
      return tokens;
    }
    throw Exception(data['message'] ?? 'Credenciales incorrectas');
  }

  static Future<void> olvidar(String matricula) async {
    final res = await ApiClient.postPublic(
        '/auth/olvidar', {'matricula': matricula});
    final data = res.data;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Error al restablecer contraseña');
    }
  }

  static Future<void> cambiarClave(
      String actual, String nueva) async {
    final res = await ApiClient.postAuth(
        '/auth/cambiar-clave', {'actual': actual, 'nueva': nueva});
    final data = res.data;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Error al cambiar contraseña');
    }
  }

  static Future<AuthTokens> refresh() async {
    final refreshToken = await LocalStorage.getRefreshToken();
    if (refreshToken == null) throw Exception('No refresh token');
    final res = await ApiClient.postPublic(
        '/auth/refresh', {'refreshToken': refreshToken});
    final data = res.data;
    if (data['success'] == true) {
      final tokens = AuthTokens.fromJson(data['data']);
      await LocalStorage.saveToken(tokens.token, tokens.refreshToken);
      return tokens;
    }
    throw Exception(data['message'] ?? 'Token expirado');
  }

  static Future<void> logout() async {
    await LocalStorage.clear();
  }
}
