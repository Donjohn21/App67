import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _keyToken = 'auth_token';
  static const _keyRefresh = 'refresh_token';
  static const _keyTempToken = 'temp_token';

  static Future<void> saveToken(String token, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyRefresh, refreshToken);
  }

  static Future<void> saveTempToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTempToken, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<String?> getTempToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTempToken);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefresh);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyRefresh);
    await prefs.remove(_keyTempToken);
  }
}
