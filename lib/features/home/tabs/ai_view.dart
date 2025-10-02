// Tab AI
// lib/features/home/tabs/ai_view.dart
import 'package:flutter/material.dart';

class AiView extends StatelessWidget {
  const AiView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono de IA
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.blue[300], size: 32),
              const SizedBox(width: 8),
              Icon(Icons.auto_awesome, color: Colors.blue[200], size: 24),
              const SizedBox(width: 4),
              Icon(Icons.auto_awesome, color: Colors.blue[100], size: 16),
            ],
          ),
          const SizedBox(height: 8),
          // Título
          const Text(
            'Análisis de IA',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Subtítulo
          const Text(
            'Inteligencia artificial para analizar tus hábitos financieros',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 28),
          // Card del asistente
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Colors.blue[200]!, width: 1.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header del asistente
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.blue[300]),
                    const SizedBox(width: 8),
                    const Text(
                      'Asistente Financiero IA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pregúntame sobre tus finanzas y recibe recomendaciones personalizadas',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 18),
                // Mensaje del bot
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0F0FB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hola! Soy tu asistente financiero inteligente. '
                          'Puedo ayudarte a analizar tus hábitos de gasto, identificar patrones y ofrecerte recomendaciones personalizadas. '
                          '¿En qué puedo ayudarte hoy?',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '2:30:16',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Input de mensaje
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Pregúntame sobre tus dudas',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.black87,
                      radius: 18,
                      child: Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
