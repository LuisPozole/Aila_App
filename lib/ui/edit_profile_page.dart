import 'package:flutter/material.dart';
import '../services/mongodb_service.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  EditProfilePage({required this.user});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
  }

  Future<void> _updateUserInDatabase(User updatedUser) async {
    await MongoDBService.getCollection('Usuarios').updateOne(
      {'username': updatedUser.username},
      {
        '\$set': {
          'name': updatedUser.name,
          'email': updatedUser.email,
          'ubicacion': updatedUser.ubicacion,
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Icon(Icons.person, size: 50, color: AppColors.primary),
                ),
              ),
              SizedBox(height: 20),
              Text("Nombre", style: _labelStyle()),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("Ingresa tu nombre"),
                validator: (value) => value!.isEmpty ? "El nombre es requerido" : null,
              ),
              SizedBox(height: 16),
              Text("Correo Electrónico", style: _labelStyle()),
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration("Ingresa tu correo"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => _validateEmail(value),
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      User updatedUser = User(
                        id: widget.user.id,
                        name: _nameController.text,
                        username: widget.user.username,
                        email: _emailController.text,
                        password: '',
                        tipoUsuario: widget.user.tipoUsuario,
                        ubicacion: widget.user.ubicacion,
                      );

                      await _updateUserInDatabase(updatedUser);
                      Navigator.pop(context, updatedUser);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text('Guardar Cambios', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _labelStyle() {
    return TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "El correo es requerido";
    }
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (!emailRegex.hasMatch(value)) {
      return "Ingresa un correo válido";
    }
    return null;
  }
}
