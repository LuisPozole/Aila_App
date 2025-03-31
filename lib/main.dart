// main.dart (actualizado)
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'services/mongodb_service.dart';
import 'ui/home_page.dart';
import 'ui/login_page.dart';
import 'ui/profile_page.dart'; // Nuevo import
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MongoDBService.connect();
  
  final storage = FlutterSecureStorage();
  final loggedUser = await storage.read(key: 'loggedUser');

  runApp(MyApp(loggedUser: loggedUser));
}

class MyApp extends StatelessWidget {
  final String? loggedUser;
  const MyApp({this.loggedUser, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        fontFamily: 'Roboto',
      ),
      home: loggedUser != null ? HomePage() : LoginPage(),
      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/perfil': (context) => ProfilePage(), // Nueva ruta
      },
    );
  }
}