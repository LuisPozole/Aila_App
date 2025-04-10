import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/mongodb_service.dart';
import 'agregar_contacto_page.dart';
import 'editar_contacto_page.dart';
import '../utils/constants.dart';

class ContactosPage extends StatefulWidget {
  @override
  _ContactosPageState createState() => _ContactosPageState();
}

class _ContactosPageState extends State<ContactosPage> {
  final _storage = FlutterSecureStorage();
  List<dynamic> contactos = [];

  @override
  void initState() {
    super.initState();
    _cargarContactos();
  }

  Future<void> _cargarContactos() async {
    final username = await _storage.read(key: 'loggedUser');
    if (username != null) {
      final userData = await MongoDBService.getCollection('Usuarios')
          .findOne({'username': username});
      setState(() {
        contactos = List<Map<String, dynamic>>.from(userData?['contacto'] ?? []);
      });
    }
  }

  Future<void> _eliminarContacto(String id) async {
    final username = await _storage.read(key: 'loggedUser');
    if (username != null) {
      await MongoDBService.getCollection('Usuarios').updateOne(
        {'username': username},
        {
          r'$pull': {
            'contacto': {'_id': id}
          }
        },
      );
      _cargarContactos();
    }
  }

  void _editarContacto(Map<String, dynamic> contacto) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditarContactoPage(contacto: contacto)),
    ).then((_) => _cargarContactos());
  }

  void _navegarAAgregarContacto() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AgregarContactoPage()),
    ).then((_) => _cargarContactos());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Contactos", style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.appBar,
        elevation: 4,
      ),
      body: contactos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/mascota3.png", width: 180),
                  SizedBox(height: 15),
                  Text("Aún no tienes contactos",
                      style: AppTextStyles.bigTitle),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _navegarAAgregarContacto,
                    icon: Icon(Icons.person_add, color: Colors.white),
                    label: Text("Añadir Contacto"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: ListView.builder(
                itemCount: contactos.length,
                itemBuilder: (context, index) {
                  // Obtener el teléfono y quitar el prefijo "521" si está presente
                  String telefono = contactos[index]['telefono'];
                  if (telefono.startsWith("521")) {
                    telefono = telefono.substring(3);
                  }
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.secondary,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        contactos[index]['nombre'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        telefono,
                        style: AppTextStyles.bodyText,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: AppColors.primary),
                            onPressed: () => _editarContacto(contactos[index]),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _eliminarContacto(contactos[index]['_id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navegarAAgregarContacto,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
