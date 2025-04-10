import 'package:bson/bson.dart';

class User {
  final ObjectId id;
  final String name;
  final String username;
  final String email;
  final String password;
  final String tipoUsuario;
  final List<Map<String, dynamic>> ubicacion;
  final List<Map<String, dynamic>> contacto;

  User({
    ObjectId? id,
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    this.tipoUsuario = "Normal",
    this.ubicacion = const [],
    this.contacto = const [],
  }) : id = id ?? ObjectId(); // Genera ObjectId automáticamente si no se proporciona

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'tipoUsuario': tipoUsuario,
      'ubicacion': ubicacion,
      'contacto': contacto,
      'apikey': null,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] ?? ObjectId(),
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      tipoUsuario: map['tipoUsuario'] ?? 'Normal',
      ubicacion: List<Map<String, dynamic>>.from(map['ubicacion'] ?? []),
      contacto: List<Map<String, dynamic>>.from(map['contacto'] ?? []),
    );
  }

  User copyWith({
    ObjectId? id,
    String? name,
    String? username,
    String? email,
    String? password,
    String? tipoUsuario,
    List<Map<String, dynamic>>? ubicacion,
    List<Map<String, dynamic>>? contacto,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      tipoUsuario: tipoUsuario ?? this.tipoUsuario,
      ubicacion: ubicacion ?? this.ubicacion,
      contacto: contacto ?? this.contacto,
    );
  }
}
