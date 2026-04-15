class AuthTokens {
  final String token;
  final String refreshToken;

  AuthTokens({required this.token, required this.refreshToken});

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }
}

class UserProfile {
  final int id;
  final String matricula;
  final String nombre;
  final String email;
  final String? foto;
  final String? rol;
  final String? grupo;

  UserProfile({
    required this.id,
    required this.matricula,
    required this.nombre,
    required this.email,
    this.foto,
    this.rol,
    this.grupo,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      matricula: json['matricula'] ?? '',
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      foto: json['foto'],
      rol: json['rol'],
      grupo: json['grupo'],
    );
  }
}
