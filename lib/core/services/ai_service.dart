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

      // Si se solicita una respuesta concisa, agregamos una instrucción breve al prompt.
      if (concise) {
        trimmed =
            '$trimmed\n\nPor favor responde en máximo 50 palabras y resume en 3 puntos.';
      }

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
          return data["response"] ??
              "🤔 No recibí respuesta de la IA, intenta nuevamente.";
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
      return "❌ Ocurrió un error al conectar con la IA.";
    }
  }
}
