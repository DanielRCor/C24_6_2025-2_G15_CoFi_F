// Widget del botón de micrófono flotante
import 'package:flutter/material.dart';

class MicButton extends StatelessWidget {
  const MicButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      // TODO: Reemplazar con el ícono personalizado
      child: const Icon(Icons.mic),
      onPressed: () {
        // TODO: Implementar funcionalidad del micrófono
        print('Micrófono presionado');
      },
    );
  }
}
