import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/mongodb_service.dart';
import 'agregar_contacto_page.dart';
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
        contactos = userData?['contacto'] ?? [];
      });
    }
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
                  Text("Aún no tienes contactos", style: AppTextStyles.bigTitle),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _navegarAAgregarContacto,
                    icon: Icon(Icons.person_add, color: Colors.white),
                    label: Text("Añadir Contacto"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                        contactos[index]['telefono'],
                        style: AppTextStyles.bodyText,
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
