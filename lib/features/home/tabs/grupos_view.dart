// Tab Grupos
import 'package:flutter/material.dart';

class GruposView extends StatelessWidget {
  const GruposView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título principal
          const Text(
            'Mis Grupos',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          // Subtítulo
          const Text(
            'Gestiona tus gastos compartidos',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black38,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 28),
          // Invitaciones pendientes
          const Text(
            'Invitaciones Pendientes',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 28),
          // Texto: Todavía no tienes invitaciones
          const Center(
            child: Text(
              'Todavía no tienes invitaciones',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 40),
          // Botón Crear Nuevo Grupo
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                // Acción para crear grupo
              },
              icon: Icon(Icons.add, color: Colors.orange[700]),
              label: const Text(
                'Crear Nuevo Grupo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.orange.shade200, width: 1.4),
                minimumSize: const Size(260, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Texto: Todavía no tienes Grupos
          const Center(
            child: Text(
              'Todavía no tienes Grupos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
