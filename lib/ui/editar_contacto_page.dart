import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/mongodb_service.dart';
import '../utils/constants.dart';

class EditarContactoPage extends StatefulWidget {
  final Map<String, dynamic> contacto;

  EditarContactoPage({required this.contacto});

  @override
  _EditarContactoPageState createState() => _EditarContactoPageState();
}

class _EditarContactoPageState extends State<EditarContactoPage> {
  final _formKey = GlobalKey<FormState>();
  final _storage = FlutterSecureStorage();
  late TextEditingController _nombreController;
  late TextEditingController _telefonoController;
  final double _elementSpacing = 24.0;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.contacto['nombre']);
    _telefonoController = TextEditingController(text: widget.contacto['telefono']);
  }

  Future<void> _actualizarContacto() async {
    if (_formKey.currentState!.validate()) {
      final username = await _storage.read(key: 'loggedUser');
      if (username != null) {
        final collection = MongoDBService.getCollection('Usuarios');
        await collection.updateOne(
          {
            'username': username,
            'contacto._id': widget.contacto['_id'],
          },
          {
            '\$set': {
              'contacto.\$.nombre': _nombreController.text,
              'contacto.\$.telefono': _telefonoController.text,
            }
          },
        );
        _showSuccessNotification('Contacto actualizado correctamente');
        Navigator.pop(context);
      }
    }
  }

  void _showSuccessNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(20),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInputSection(
                label: "Nombre del contacto",
                controller: _nombreController,
                icon: Icons.person_rounded,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese un nombre' : null,
              ),
              SizedBox(height: _elementSpacing),
              _buildInputSection(
                label: "Número telefónico",
                controller: _telefonoController,
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese un teléfono' : null,
              ),
              SizedBox(height: _elementSpacing * 1.5),
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Editar Contacto',
          style: AppTextStyles.appBarTitle.copyWith(fontWeight: FontWeight.w600)),
      backgroundColor: AppColors.appBar,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      shadowColor: Colors.black12,
      centerTitle: true,
    );
  }

  Widget _buildInputSection({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: AppTextStyles.bodyText.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: AppColors.primary.withOpacity(0.8)),
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          errorStyle: TextStyle(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton.icon(
      onPressed: _actualizarContacto,
      icon: Icon(Icons.save_rounded, size: 22),
      label: Text('ACTUALIZAR CONTACTO',
          style: TextStyle(letterSpacing: 0.8, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        shadowColor: AppColors.primary.withOpacity(0.3),
      ),
    );
  }
}