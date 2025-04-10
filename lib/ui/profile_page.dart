import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../services/mongodb_service.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'edit_profile_page.dart';
import 'package:aila_/widgets/shimer.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _storage = FlutterSecureStorage();
  final _picker = ImagePicker();
  User? _currentUser;
  File? _selectedImage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final username = await _storage.read(key: 'loggedUser');
      if (username != null) {
        final userData = await MongoDBService.getCollection('Usuarios')
            .findOne({'username': username});

        if (userData != null) {
          setState(() {
            _currentUser = User.fromMap(userData);
            _isLoading = false;
          });
          await _loadProfileImage();
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Error cargando datos');
    }
  }

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null || _currentUser == null) return;

      final tempFile = File(image.path);
      final bytes = await tempFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      await _storage.write(
        key: 'profile_image_${_currentUser!.username}',
        value: base64Image,
      );

      setState(() => _selectedImage = tempFile);
    } catch (e) {
      _showErrorSnackbar('Error seleccionando imagen');
    }
  }

  Future<void> _loadProfileImage() async {
    try {
      if (_currentUser == null) return;

      final base64Image = await _storage.read(
          key: 'profile_image_${_currentUser!.username}');
          
      if (base64Image != null && base64Image.isNotEmpty) {
        final bytes = base64Decode(base64Image);
        final tempDir = await Directory.systemTemp.createTemp();
        final file = File('${tempDir.path}/profile_image.png')
          ..writeAsBytesSync(bytes);
          
        setState(() => _selectedImage = file);
      }
    } catch (e) {
      print('Error loading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? _buildShimmerLoader()
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 20,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.7)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.edit_note_rounded, color: Colors.white),
                      onPressed: () => _navigateToEditProfile(),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Transform.translate(
                          offset: Offset(0, 2),
                          child: _buildProfileHeader(),
                        ),
                        _buildUserInfoSection(),
                        SizedBox(height: 30),
                        _buildAddressSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.accent,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : AssetImage('assets/placeholder.png') as ImageProvider,
                child: _selectedImage == null
                    ? Icon(Icons.person_rounded, size: 50, color: Colors.white70)
                    : null,
              ),
            ),
            _buildEditPhotoButton(),
          ],
        ),
        SizedBox(height: 20),
        Text(
          _currentUser!.name,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          _currentUser!.email,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildEditPhotoButton() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.person_outline_rounded,
                  color: AppColors.primary),
              title: Text('Nombre de usuario',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
              subtitle: Text(_currentUser!.username,
                  style: AppTextStyles.bodyLarge),
            ),
            Divider(height: 1),
            ListTile(
              leading: Icon(Icons.category_rounded, color: AppColors.primary),
              title: Text('Tipo de usuario',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
              subtitle: Text(_currentUser!.tipoUsuario ?? 'Estándar',
                  style: AppTextStyles.bodyLarge),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8, bottom: 16),
          child: Text('Direcciones',
              style: AppTextStyles.titleLarge),
        ),
        ..._currentUser!.ubicacion.map((direccion) => _buildAddressCard(direccion)).toList(),
      ],
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> direccion) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddressItem(Icons.location_on_outlined, 'Calle', direccion['calle']),
            _buildAddressItem(Icons.house_rounded, 'Colonia', direccion['colonia']),
            _buildAddressItem(Icons.location_city_rounded, 'Ciudad', direccion['ciudad']),
            _buildAddressItem(Icons.flag_rounded, 'Estado', direccion['Estado']),
            _buildAddressItem(Icons.numbers_rounded, 'C.P.', direccion['CP']),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressItem(IconData icon, String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
              Text(value,
                  style: AppTextStyles.bodyLarge),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return ListView(
      padding: EdgeInsets.all(24),
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
        SizedBox(height: 30),
        Shimmer(
          child: Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
          ),
        ),
        SizedBox(height: 20),
        Shimmer(
          child: Container(
            height: 24,
            width: 200,
            color: Colors.grey[200],
          ),
        ),
        SizedBox(height: 10),
        Shimmer(
          child: Container(
            height: 18,
            width: 150,
            color: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  void _navigateToEditProfile() async {
    final updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(user: _currentUser!),
      ),
    );

    if (updatedUser != null && updatedUser is User) {
      setState(() => _currentUser = updatedUser);
      _showSuccessSnackbar('Perfil actualizado correctamente');
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}