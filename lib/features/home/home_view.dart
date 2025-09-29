// Vista principal con Navbar
import 'package:flutter/material.dart';
import '../../core/widgets/mic_button.dart';
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
      floatingActionButton: _selectedIndex == 0 ? const MicButton() : null,
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
            // TODO: Reemplazar con tu ícono personalizado
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            // TODO: Reemplazar con tu ícono personalizado
            icon: Icon(Icons.group),
            label: 'Grupos',
          ),
          BottomNavigationBarItem(
            // TODO: Reemplazar con tu ícono personalizado
            icon: Icon(Icons.psychology),
            label: 'AI',
          ),
          BottomNavigationBarItem(
            // TODO: Reemplazar con tu ícono personalizado
            icon: Icon(Icons.flag),
            label: 'Metas',
          ),
          BottomNavigationBarItem(
            // TODO: Reemplazar con tu ícono personalizado
            icon: Icon(Icons.bar_chart),
            label: 'Reportes',
          ),
          BottomNavigationBarItem(
            // TODO: Reemplazar con tu ícono personalizado
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}