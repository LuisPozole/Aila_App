class User {
  final String id;
  final String name;
  final String username;
  final String email;
  final String password;
  final String tipoUsuario;
  final List<Map<String, dynamic>> ubicacion;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    this.tipoUsuario = "Normal",
    this.ubicacion = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'tipoUsuario': tipoUsuario,
      'ubicacion': ubicacion,
      'contacto': [],
      'apikey': null,
    };
  }

  User copyWith({
    String? name,
    String? username,
    String? email,
    String? password,
    String? tipoUsuario,
    List<Map<String, dynamic>>? ubicacion,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      tipoUsuario: tipoUsuario ?? this.tipoUsuario,
      ubicacion: ubicacion ?? this.ubicacion,
    );
  }
}
