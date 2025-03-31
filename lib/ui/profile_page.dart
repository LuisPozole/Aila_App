import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../services/mongodb_service.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _storage = FlutterSecureStorage();
  final _picker = ImagePicker();
  User? _currentUser;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final username = await _storage.read(key: 'loggedUser');
    if (username != null) {
      final userData = await MongoDBService.getCollection('Usuarios')
          .findOne({'username': username});

      if (userData != null) {
        setState(() {
          _currentUser = User(
            id: userData['_id'].toString(),
            name: userData['name'],
            username: userData['username'],
            email: userData['email'],
            password: '',
            tipoUsuario: userData['tipoUsuario'],
            ubicacion: List<Map<String, dynamic>>.from(userData['ubicacion']),
          );
        });
        _loadProfileImage(); // Cargar la imagen del usuario después de cargar los datos
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final username = _currentUser?.username;
      if (username == null) return;

      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      // Guardar la imagen con una clave única por usuario
      await _storage.write(key: 'profile_image_$username', value: base64Image);

      setState(() {
        _selectedImage = File(image.path);
      });
    } catch (e) {
      print('Error al seleccionar imagen: $e');
    }
  }

  Future<void> _loadProfileImage() async {
    try {
      final username = _currentUser?.username;
      if (username == null) return;

      final base64Image = await _storage.read(key: 'profile_image_$username');
      if (base64Image != null && base64Image.isNotEmpty) {
        final bytes = base64Decode(base64Image);
        final tempDir = await Directory.systemTemp.createTemp();
        final file = File('${tempDir.path}/profile_image.png');
        await file.writeAsBytes(bytes);

        setState(() {
          _selectedImage = file;
        });
      }
    } catch (e) {
      print('Error al cargar imagen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _currentUser == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
                  color: AppColors.primary.withOpacity(0.2),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.black87),
                            onPressed: () => Navigator.pop(context),
                          ),
                          SizedBox(width: 8),
                          Text('Perfil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.accent,
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : AssetImage('assets/placeholder.png') as ImageProvider,
                              child: _selectedImage == null
                                  ? Icon(Icons.person, size: 50, color: Colors.white70)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.edit, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(_currentUser!.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(_currentUser!.email, style: TextStyle(color: Colors.grey[700])),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final updatedUser = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfilePage(user: _currentUser!),
                            ),
                          );

                          if (updatedUser != null && updatedUser is User) {
                            setState(() {
                              _currentUser = updatedUser;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Perfil actualizado correctamente'),
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text('Editar'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Direcciones:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ..._currentUser!.ubicacion.map((direccion) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileItem('Calle', direccion['calle']),
                              _buildProfileItem('Colonia', direccion['colonia']),
                              _buildProfileItem('Ciudad', direccion['ciudad']),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileItem(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$title:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                )),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                )),
          ),
        ],
      ),
    );
  }
}
