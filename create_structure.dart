import 'dart:io';

void main() {
  final folders = [
    'lib/core/theme',
    'lib/core/widgets',
    'lib/core/services',
    'lib/features/splash',
    'lib/features/onboarding',
    'lib/features/auth',
    'lib/features/home/tabs',
    'lib/features/groups',
    'lib/routes',
  ];

  final files = {
    'lib/main.dart': '// main.dart - punto de entrada',
    'lib/core/theme/app_theme.dart': '// Definición de colores y estilos globales',
    'lib/core/widgets/mic_button.dart': '// Widget del botón de micrófono flotante',
    'lib/core/services/dummy_service.dart': '// Servicios globales (placeholder)',

    'lib/features/splash/splash_view.dart': '// Pantalla Splash (logo inicial)',

    'lib/features/onboarding/onboarding1_view.dart': '// Onboarding pantalla 1',
    'lib/features/onboarding/onboarding2_view.dart': '// Onboarding pantalla 2',
    'lib/features/onboarding/onboarding3_view.dart': '// Onboarding pantalla 3',

    'lib/features/auth/login_view.dart': '// Vista de Login',
    'lib/features/auth/register_view.dart': '// Vista de Registro',
    'lib/features/auth/auth_controller.dart': '// Controlador auth (placeholder)',
    'lib/features/auth/auth_service.dart': '// Lógica conexión backend (placeholder)',

    'lib/features/home/home_view.dart': '// Vista principal con Navbar',
    'lib/features/home/home_controller.dart': '// Controlador del Home',
    'lib/features/home/tabs/inicio_view.dart': '// Tab Inicio',
    'lib/features/home/tabs/grupos_view.dart': '// Tab Grupos',
    'lib/features/home/tabs/ai_view.dart': '// Tab AI',
    'lib/features/home/tabs/metas_view.dart': '// Tab Metas',
    'lib/features/home/tabs/reportes_view.dart': '// Tab Reportes',
    'lib/features/home/tabs/perfil_view.dart': '// Tab Perfil',

    'lib/features/groups/group_card.dart': '// UI de un grupo',
    'lib/features/groups/group_list_view.dart': '// Vista lista de grupos (swipe)',
    'lib/features/groups/group_controller.dart': '// Lógica de grupos (placeholder)',

    'lib/routes/app_routes.dart': '// Definición de rutas de la app',
  };

  // Crear carpetas
  for (var dir in folders) {
    Directory(dir).createSync(recursive: true);
    print('📁 Carpeta creada: $dir');
  }

  // Crear archivos
  files.forEach((path, content) {
    final file = File(path);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
      file.writeAsStringSync(content);
      print('📄 Archivo creado: $path');
    } else {
      print('⚠️ Ya existe: $path (no se sobrescribió)');
    }
  });

  print('\n✅ Estructura generada con éxito');
}
