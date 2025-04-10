import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF134074); // Azul oscuro
  static const Color secondary = Color(0xFF3D5A80); // Azul medio
  static const Color accent = Color(0xFF98C1D9); // Azul claro
  static const Color background = Color(0xFFD8E2DC); // Rosa claro
  static const Color textPrimary = Color(0xFF1D3557); // Azul oscuro para texto
  static const Color appBar = Color(0xFFB8C0FF); // Azul claro para AppBar
  static const Color success = Color(0xFF4CAF50);
  static const primaryDark = Color(0xFF1976D2);
  static const primaryLight = Color(0xFFBBDEFB);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color border = Color(0xFFDFE6E9);
  static const Color error = Color(0xFFD63031);
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
   
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

}