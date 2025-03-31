class User {
  final String id;
  final String name;
  final String username;
  final String email;
  final String password;
  final String tipoUsuario;
  final List<Map<String, dynamic>> ubicacion;
  final List<Map<String, dynamic>> contacto; // Se agregó la lista de contactos

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    this.tipoUsuario = "Normal",
    this.ubicacion = const [],
    this.contacto = const [], // Se inicializa correctamente
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id, // Se incluyó el ID en el mapa para consistencia
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'tipoUsuario': tipoUsuario,
      'ubicacion': ubicacion,
      'contacto': contacto, // Se asegura de que `contacto` se guarde correctamente
      'apikey': null,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? password,
    String? tipoUsuario,
    List<Map<String, dynamic>>? ubicacion,
    List<Map<String, dynamic>>? contacto, // Se añadió en copyWith
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      tipoUsuario: tipoUsuario ?? this.tipoUsuario,
      ubicacion: ubicacion ?? this.ubicacion,
      contacto: contacto ?? this.contacto, // Se mantiene la lista actual si no se pasa una nueva
    );
  }
}