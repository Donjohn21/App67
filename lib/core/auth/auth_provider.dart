import 'package:flutter/foundation.dart';
import '../storage/local_storage.dart';

/// Provider que maneja el estado de autenticación de la aplicación.
///
/// Uso:
/// - Proveer con `ChangeNotifierProvider(create: (_) => AuthProvider()..check())`
/// - Leer estado con `context.watch<AuthProvider>().isLoggedIn`
/// - Llamar `check()` para sincronizar con SharedPreferences
/// - Llamar `logout()` para borrar el token y notificar a la UI
class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  /// Cuando está en true, se emiten prints de depuración a la consola.
  bool enableDebug = false;

  /// Verifica el estado actual leyendo el token desde SharedPreferences.
  /// Llama a `notifyListeners()` después de leer para actualizar la UI.
  Future<void> check() async {
    final logged = await LocalStorage.isLoggedIn();
    _isLoggedIn = logged;
    if (enableDebug) print('[AuthProvider] check -> isLoggedIn=$_isLoggedIn');
    notifyListeners();
  }

  /// Fuerza el estado de autenticación y notifica a los listeners.
  /// Útil si ya guardaste tokens manualmente y quieres actualizar la UI.
  void setLoggedIn(bool value) {
    _isLoggedIn = value;
    if (enableDebug)
      print('[AuthProvider] setLoggedIn -> isLoggedIn=$_isLoggedIn');
    notifyListeners();
  }

  /// Limpia el almacenamiento local y notifica el cambio de estado.
  /// Este método también puede ser llamado desde pantallas de logout.
  Future<void> logout() async {
    if (enableDebug) print('[AuthProvider] logout -> clearing local storage');
    await LocalStorage.clear();
    _isLoggedIn = false;
    if (enableDebug) print('[AuthProvider] logout -> isLoggedIn=$_isLoggedIn');
    notifyListeners();
  }

  /// Devuelve una cadena con el estado de depuración y opcionalmente la imprime.
  /// Útil para llamar desde UI o desde la consola para inspeccionar el estado.
  String debugState({bool printIt = true}) {
    final s = 'AuthProvider{isLoggedIn: $_isLoggedIn}';
    if (enableDebug || printIt) print('[AuthProvider] debugState -> $s');
    return s;
  }
}
