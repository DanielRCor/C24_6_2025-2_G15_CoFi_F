// Vista principal con Navbar
import 'package:flutter/material.dart';
// Asegúrate de que esta importación ya no es necesaria si no la usas en otro lado
// import '../../core/widgets/mic_button.dart'; 
import 'tabs/inicio_view.dart';
import 'tabs/grupos_view.dart';
import 'tabs/ai_view.dart';
import 'tabs/metas_view.dart';
import 'tabs/reportes_view.dart';
import 'tabs/perfil_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const InicioView(),
    const GruposView(),
    const AiView(),
    const MetasView(),
    const ReportesView(),
    const PerfilView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      
      // LÍNEA ELIMINADA:
      // floatingActionButton: _selectedIndex == 0 ? const MicButton() : null,
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Grupos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Metas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reportes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}