import 'package:flutter/material.dart';
import '../utils/constants.dart';

class BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.primary,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      currentIndex: 1, // Resaltar "Hablar" como opción central
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Recordatorios"),
        BottomNavigationBarItem(icon: Icon(Icons.mic), label: "Hablar"),
        BottomNavigationBarItem(icon: Icon(Icons.laptop), label: "dispositivos"),
      ],
    );
  }
}
