import 'package:flutter/material.dart';
import 'package:aila_/ui/reminders_page.dart';
import 'package:aila_/ui/chatbot_page.dart'; 
import 'package:aila_/ui/devices_page.dart';

class BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.blue,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      currentIndex: 1,
      onTap: (index) {
        if (index == 0) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => RemindersPage()));
        } else if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatbotPage())); // Agrega la navegación
        } else if (index == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => DevicesPage())); // Navegación a la nueva página
        }
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Recordatorios"),
        BottomNavigationBarItem(icon: Icon(Icons.mic), label: "Hablar"),
        BottomNavigationBarItem(icon: Icon(Icons.laptop), label: "Dispositivos"),
      ],
    );
  }
}
