import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF134074); // Azul oscuro
  static const Color secondary = Color(0xFF3D5A80); // Azul medio
  static const Color accent = Color(0xFF98C1D9); // Azul claro
  static const Color background = Color(0xFFD8E2DC); // Rosa claro
  static const Color textPrimary = Color(0xFF1D3557); // Azul oscuro para texto
  static const Color appBar = Color(0xFFB8C0FF); // Azul claro para AppBar
  static const Color success = Color(0xFF4CAF50);
}

class AppTextStyles {
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle bigTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary, // Usa el color de texto definido
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );
}
