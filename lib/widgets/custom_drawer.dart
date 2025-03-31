import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';
import '../services/mongodb_service.dart';
import 'package:aila_/ui/cuentas_page.dart'; // Importa la nueva página

class CustomDrawer extends StatelessWidget {
  final _storage = FlutterSecureStorage();

  Future<Map<String, dynamic>?> _getUserInfo() async {
    final username = await _storage.read(key: 'loggedUser');
    if (username != null) {
      final userData = await MongoDBService.getCollection('Usuarios')
          .findOne({'username': username});

      final base64Image = await _storage.read(key: 'profile_image_$username');

      return {
        'name': userData?['name'] ?? 'Usuario',
        'image': base64Image,
      };
    }
    return null;
  }

  Future<void> _logout(BuildContext context) async {
    await _storage.delete(key: 'loggedUser');
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: _getUserInfo(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return DrawerHeader(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final userInfo = snapshot.data;
              final imageProvider = (userInfo?['image'] != null)
                  ? MemoryImage(base64Decode(userInfo!['image']))
                  : AssetImage('assets/placeholder.png') as ImageProvider;

              return Container(
                color: AppColors.primary.withOpacity(0.1),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  children: [
                    CircleAvatar(radius: 30, backgroundImage: imageProvider),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        userInfo?['name'] ?? 'Usuario',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person, color: AppColors.primary),
            title: Text("Perfil"),
            onTap: () => Navigator.pushNamed(context, "/perfil"),
          ),
          ListTile(
            leading: Icon(Icons.lock, color: AppColors.primary),
            title: Text("Cuentas"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CuentaPage()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.contacts, color: AppColors.primary),
            title: Text("Contactos"),
            onTap: () => Navigator.pushNamed(context, "/contactos"),
          ),
          Divider(color: AppColors.primary),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.red),
            title: Text("Cerrar sesión", style: TextStyle(color: Colors.red)),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
