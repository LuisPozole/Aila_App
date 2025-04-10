import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/mongodb_service.dart';
import '../utils/constants.dart';

class AgregarContactoPage extends StatefulWidget {
  @override
  _AgregarContactoPageState createState() => _AgregarContactoPageState();
}

class _AgregarContactoPageState extends State<AgregarContactoPage> {
  final _storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  bool _isSaving = false;

  Future<void> _guardarContacto() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final username = await _storage.read(key: 'loggedUser');
    if (username != null) {
      final collection = MongoDBService.getCollection('Usuarios');
      final userData = await collection.findOne({'username': username});

      if (userData != null) {
        List<dynamic> contactos = List.from(userData['contacto'] ?? []);

        // Obtener el teléfono y agregar el prefijo "521" si no lo tiene
        String telefono = _telefonoController.text.trim();
        if (!telefono.startsWith("521")) {
          telefono = "521" + telefono;
        }

        contactos.add({
          '_id': DateTime.now().millisecondsSinceEpoch.toString(), // ID único para el contacto
          'nombre': _nombreController.text.trim(),
          'telefono': telefono,
        });

        await collection.updateOne(
          {'username': username},
          {'\$set': {'contacto': contactos}},
        );

        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Contacto agregado con éxito"),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Agregar Contacto", style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.appBar,
        elevation: 4,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Nombre", style: AppTextStyles.bodyText),
              SizedBox(height: 5),
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  hintText: "Ingrese el nombre",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? "Este campo es obligatorio" : null,
              ),
              SizedBox(height: 15),
              Text("Teléfono", style: AppTextStyles.bodyText),
              SizedBox(height: 5),
              TextFormField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "Ingrese el número de teléfono",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return "Este campo es obligatorio";
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) return "Ingrese solo números";
                  return null;
                },
              ),
              SizedBox(height: 25),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _guardarContacto,
                  icon: Icon(Icons.save, color: Colors.white),
                  label: _isSaving ? CircularProgressIndicator(color: Colors.white) : Text("Guardar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
