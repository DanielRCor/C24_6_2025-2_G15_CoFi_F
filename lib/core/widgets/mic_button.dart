// Widget del botón de micrófono flotante
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class MicButton extends StatelessWidget {
  const MicButton({super.key});

  Future<void> _requestMicPermission(BuildContext context) async {
    final status = await Permission.microphone.request();

    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso de micrófono concedido ✅')),
      );
      // Aquí más adelante podrás activar la lógica de grabación
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso de micrófono denegado ❌')),
      );
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El permiso fue bloqueado. Habilítalo manualmente en Configuración.',
          ),
        ),
      );
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.mic),
      onPressed: () => _requestMicPermission(context),
    );
  }
}
