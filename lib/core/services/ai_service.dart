import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class AiService {
  static const String _backendUrl =
      "https://co-fi-web.vercel.app/api/ai/request";

  static Future<String> getAIResponse(
    String message, {
    bool concise = false,
  }) async {
    try {
      var trimmed = message.trim();
      if (trimmed.isEmpty) {
        print('⚠️ No se enviará petición a la IA: mensaje vacío');
        return '🤔 Escribe un mensaje antes de enviar.';
      }

      // Sugerimos siempre una respuesta breve y precisa (5 líneas, 3 puntos).
      final conciseInstruction =
          '\n\nPor favor responde en máximo 5 líneas y resume en 3 puntos.';
      trimmed = '$trimmed$conciseInstruction';

      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) {
        print('⚠️ Token de Firebase nulo. Usuario no autenticado.');
        return "⚠️ No se pudo autenticar con Firebase.";
      }

      // El backend de Next.js espera 'userMessage' (según handler). Enviamos
      // userMessage y requestType por defecto.
      final body = jsonEncode({
        "userMessage": trimmed,
        "requestType": "advice",
      });
      // Debug prints para diagnóstico (no imprimir token completo por seguridad)
      try {
        final shortToken = token.length > 10
            ? '${token.substring(0, 10)}...'
            : token;
        print('📤 Enviando petición IA a $_backendUrl');
        print('🔐 Authorization: Bearer $shortToken');
        print('📦 body: $body');
      } catch (_) {}

      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: body,
      );

      if (response.statusCode == 200) {
        // Imprimir body completo del backend para depuración
        try {
          print('✅ Respuesta backend (status 200): ${response.body}');
          final data = jsonDecode(response.body);
          print('🔎 Parsed response JSON: $data');
          var respText = (data["response"] as String?)?.trim() ?? '';

          // Si el backend devuelve el placeholder que significa "sin respuesta" o está vacío,
          // hacemos un reintento con una instrucción explícita de respuesta corta.
          if (respText.isEmpty ||
              respText == 'No se recibió respuesta de la IA.' ||
              respText.toLowerCase().contains('no se reci')) {
            print(
              '⚠️ Backend no devolvió respuesta útil, intentando reintento conciso',
            );
            try {
              final retryBody = jsonEncode({
                "userMessage": '$trimmed$conciseInstruction',
                "requestType": "advice",
              });
              final r2 = await http.post(
                Uri.parse(_backendUrl),
                headers: {
                  "Authorization": "Bearer $token",
                  "Content-Type": "application/json",
                },
                body: retryBody,
              );
              if (r2.statusCode == 200) {
                final data2 = jsonDecode(r2.body);
                respText = (data2['response'] as String?)?.trim() ?? '';
                print('🔁 Reintento backend (200): $respText');
              } else {
                print('❌ Reintento fallido (${r2.statusCode}): ${r2.body}');
              }
            } catch (e) {
              print('💥 Error en reintento conciso: $e');
            }
          }

          if (respText.isEmpty) {
            return '🤖 Lo siento, no obtuve respuesta de la IA. Intenta reformular la pregunta o comprueba la conexión.';
          }

          final placeholder = 'No se recibió respuesta de la IA.';
          if (respText == placeholder) {
            return '🤖 No pude obtener una respuesta de la IA. Prueba de nuevo o revisa el servicio backend.';
          }

          // Limpieza de formato: quitar '**' (bold markdown) y convertir líneas que
          // comienzan con '*' o '•' en guiones '-' para que se vea mejor en la UI.
          String _cleanFormatting(String s) {
            try {
              // Remover bold Markdown **texto** -> texto
              s = s.replaceAllMapped(
                RegExp(r"\*\*(.*?)\*\*"),
                (m) => m[1] ?? '',
              );

              // Convertir bullets '*' o '•' al inicio de línea en '- '
              s = s.replaceAllMapped(
                RegExp(r'(?m)^[ \t]*[\*\•][ \t]*'),
                (m) => '- ',
              );

              // Normalizar espacios múltiples
              s = s.replaceAll(RegExp(r'[ \t]{2,}'), ' ');

              // Quitar espacios al final de cada línea
              s = s
                  .split(RegExp(r"\r?\n"))
                  .map((l) => l.trimRight())
                  .join('\n');

              return s.trim();
            } catch (_) {
              return s;
            }
          }

          // Aplicar limpieza antes de truncar
          respText = _cleanFormatting(respText);

          // Truncar respuestas demasiado largas a un tamaño razonable (máx 5 líneas o 600 chars)
          String _truncateResponse(
            String s, {
            int maxLines = 5,
            int maxChars = 600,
          }) {
            final lines = s.split(RegExp(r"\r?\n"));
            final taken = lines.take(maxLines).toList();
            var result = taken.join('\n');
            if (result.length > maxChars) {
              result = result.substring(0, maxChars) + '...';
            }
            return result;
          }

          return _truncateResponse(respText);
        } catch (e) {
          print('⚠️ Error al parsear JSON del backend: $e');
          // Si no se puede parsear, devolvemos mensaje por defecto
          return "🤔 No recibí respuesta de la IA, intenta nuevamente.";
        }
      }

      // Si el backend responde con 400 indicando que falta el mensaje,
      // intentamos algunos payloads alternativos comunes.
      if (response.statusCode == 400) {
        try {
          final respBody = response.body;
          final parsed = jsonDecode(respBody);
          if (parsed is Map &&
              parsed['error'] == 'Falta el mensaje del usuario') {
            print(
              '⚠️ Backend indica falta de campo message; reintentando con payload alternativos',
            );

            final altPayloads = [
              // incluir formato legacy 'message' por compatibilidad
              jsonEncode({'message': trimmed}),
              jsonEncode({'prompt': trimmed}),
              jsonEncode({'input': trimmed}),
              jsonEncode({
                'messages': [
                  {'role': 'user', 'content': trimmed},
                ],
              }),
            ];

            for (final p in altPayloads) {
              try {
                print('📤 Reintentando con payload: $p');
                final r2 = await http.post(
                  Uri.parse(_backendUrl),
                  headers: {
                    "Authorization": "Bearer $token",
                    "Content-Type": "application/json",
                  },
                  body: p,
                );
                if (r2.statusCode == 200) {
                  final data2 = jsonDecode(r2.body);
                  return data2['response'] ?? '🤔 No recibí respuesta de la IA';
                } else {
                  print('❌ Reintento fallido (${r2.statusCode}): ${r2.body}');
                }
              } catch (e) {
                print('💥 Error en reintento con payload $p: $e');
              }
            }
          }
        } catch (e) {
          print('⚠️ No se pudo parsear body 400: ${response.body}');
        }
      }

      print("❌ Error IA: ${response.body}");
      throw Exception("Error ${response.statusCode}: ${response.body}");
    } catch (e) {
      print("💥 Error al consultar la IA: $e");
      return "❌ Ocurrió un error";
    }
  }
}
