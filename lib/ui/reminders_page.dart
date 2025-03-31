import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aila_/services/mongodb_service.dart';
import 'add_reminder_page.dart';
import 'package:aila_/utils/constants.dart'; // Asegúrate de importar tus constantes

class RemindersPage extends StatefulWidget {
  @override
  _RemindersPageState createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final storage = FlutterSecureStorage();
  String? userId;
  List<Map<String, dynamic>> reminders = [];

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    String? id = await storage.read(key: 'userId');
    if (id != null) {
      setState(() {
        userId = id;
      });
      _fetchReminders();
    }
  }

  Future<void> _fetchReminders() async {
    if (userId == null) return;
    List<Map<String, dynamic>> data = await MongoDBService.getReminders(userId!);
    setState(() {
      reminders = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Recordatorios", style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.appBar,
      ),
      body: userId == null
          ? Center(child: CircularProgressIndicator())
          : reminders.isEmpty
              ? _noRemindersWidget(context)
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: reminders.length,
                        itemBuilder: (context, index) {
                          var reminder = reminders[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              title: Text(
                                reminder['titulo'],
                                style: AppTextStyles.bigTitle,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(reminder['descripcion'], style: AppTextStyles.bodyText),
                                  SizedBox(height: 8),
                                  Text('Fecha: ${reminder['fecha']}', style: AppTextStyles.bodyText),
                                  Text('Hora: ${reminder['hora']}', style: AppTextStyles.bodyText),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddReminderPage()),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text("Añadir recordatorio", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _noRemindersWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Ups, aún no tienes recordatorios", style: AppTextStyles.bigTitle),
          SizedBox(height: 10),
          Image.asset('assets/mascota3.png', height: 150),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddReminderPage()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 80, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text("Añadir recordatorio", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
