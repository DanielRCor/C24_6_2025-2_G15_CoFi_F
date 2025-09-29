// Pantalla Splash (logo inicial)
import 'package:flutter/material.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    // Navegar a onboarding1 después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/onboarding1');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2ED),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/image2.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20), // Espacio entre logo y texto
            // Texto con nombre del proyecto
            const Text(
              "COFI",
              style: TextStyle(
                fontSize: 28, // Tamaño del texto
                fontWeight: FontWeight.bold, // Negrita
                color: Colors.brown, // Puedes cambiar el color
                letterSpacing: 2, // Espaciado entre letras
              ),
            ),
          ],
        ),
      ),
    );
  }
}
