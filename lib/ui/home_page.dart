import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/custom_drawer.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          "Aila",
          style: AppTextStyles.appBarTitle,
        ),
      ),
      drawer: CustomDrawer(), // Agregamos la pestaña lateral
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80), // Mueve el texto más arriba
            Text(
              "¡Hola! ¿En qué puedo ayudarte?",
              style: AppTextStyles.bigTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            // Imagen de la mascota
            Center(
              child: Image.asset(
                "assets/mascota1.png",
                height: 550,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(),
    );
  }
}