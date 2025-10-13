import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Widget modular del botón de micrófono con animaciones
class MicrophoneButton extends StatefulWidget {
  final VoidCallback? onTranscriptionComplete;
  
  const MicrophoneButton({
    super.key,
    this.onTranscriptionComplete,
  });

  @override
  State<MicrophoneButton> createState() => _MicrophoneButtonState();
}

class _MicrophoneButtonState extends State<MicrophoneButton>
    with TickerProviderStateMixin {
  bool _isListening = false;
  bool _hasPermission = false;
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Animación de pulso (ondas)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeOut,
      ),
    );

    // Animación de escala del ícono
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.microphone.status;
    setState(() {
      _hasPermission = status.isGranted;
    });
  }

  Future<void> _requestPermission() async {
    final status = await Permission.microphone.request();
    
    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
      });
      _startListening();
    } else if (status.isDenied) {
      _showPermissionDialog('Permiso denegado', 
        'Necesitamos acceso al micrófono para esta función.');
    } else if (status.isPermanentlyDenied) {
      _showPermissionDialog('Permiso bloqueado',
        'Por favor, habilita el permiso del micrófono en la configuración de la app.');
    }
  }

  void _showPermissionDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Configuración'),
          ),
        ],
      ),
    );
  }

  void _startListening() {
    setState(() {
      _isListening = true;
    });
    
    // Iniciar animaciones
    _pulseController.repeat();
    _scaleController.forward();
    
    // Simular escucha (aquí irá la lógica de speech_to_text)
    debugPrint('🎤 Micrófono activado - Escuchando...');
    
    // Mostrar feedback visual
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.mic, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Escuchando...'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    
    // Detener animaciones
    _pulseController.stop();
    _pulseController.reset();
    _scaleController.reverse();
    
    debugPrint('🎤 Micrófono desactivado');
    
    // Mostrar feedback de finalización
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Grabación finalizada'),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleListening() {
    if (!_hasPermission) {
      _requestPermission();
      return;
    }

    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Ondas de pulso (solo cuando está activo)
        if (_isListening) ...[
          _buildPulseWave(0.0, Colors.blue.withOpacity(0.4)),
          _buildPulseWave(0.3, Colors.blue.withOpacity(0.3)),
          _buildPulseWave(0.6, Colors.blue.withOpacity(0.2)),
        ],
        
        // Botón principal
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isListening
                    ? [Colors.red.shade400, Colors.red.shade600]
                    : [Colors.blue.shade400, Colors.blue.shade600],
              ),
              boxShadow: [
                BoxShadow(
                  color: (_isListening ? Colors.red : Colors.blue).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleListening,
                borderRadius: BorderRadius.circular(35),
                child: Center(
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Indicador de grabación
        if (_isListening)
          Positioned(
            top: -5,
            right: -5,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPulseWave(double delay, Color color) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final delayedValue = (_pulseAnimation.value - delay).clamp(0.0, 1.0);
        
        return Container(
          width: 70 * delayedValue * 1.5,
          height: 70 * delayedValue * 1.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(1.0 - delayedValue),
              width: 3,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
}