import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/mongodb_service.dart';
import '../utils/constants.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  
  final _calleController = TextEditingController();
  final _coloniaController = TextEditingController();
  final _cpController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _estadoController = TextEditingController();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final existingUser = await MongoDBService.getCollection('Usuarios')
          .findOne({'username': _userController.text});

      if (existingUser != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡El nombre de usuario ya existe!'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      final bytes = utf8.encode(_passController.text);
      final digest = sha256.convert(bytes);
      final encryptedPassword = digest.toString();

      final nuevaDireccion = {
        'calle': _calleController.text,
        'colonia': _coloniaController.text,
        'CP': _cpController.text,
        'ciudad': _ciudadController.text,
        'Estado': _estadoController.text,
      };

      final newUser = User(
        id: DateTime.now().toString(),
        name: _nameController.text,
        username: _userController.text,
        email: _emailController.text,
        password: encryptedPassword,
        ubicacion: [nuevaDireccion],
      );

      await MongoDBService.getCollection('Usuarios').insert(newUser.toMap());
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Registro exitoso!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Crear cuenta', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_nameController, 'Nombre completo'),
              _buildTextField(_emailController, 'Correo electrónico',
                  keyboardType: TextInputType.emailAddress),
              _buildTextField(_userController, 'Nombre de usuario'),
              _buildTextField(_passController, 'Contraseña', obscureText: true),
              SizedBox(height: 20),
              Text('Dirección:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildTextField(_calleController, 'Calle'),
              _buildTextField(_coloniaController, 'Colonia'),
              _buildTextField(_cpController, 'Código Postal',
                  keyboardType: TextInputType.number),
              _buildTextField(_ciudadController, 'Ciudad'),
              _buildTextField(_estadoController, 'Estado'),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text('Registrarse',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
    );
  }
}