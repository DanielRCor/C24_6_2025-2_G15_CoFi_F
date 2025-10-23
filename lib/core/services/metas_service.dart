import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class GoalService {
  final String baseUrl = "https://co-fi-web.vercel.app/api/savings";

  Future<String?> _getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    return await user.getIdToken();
  }

  /* 🟣 Listar metas */
  Future<List<Map<String, dynamic>>> getGoals() async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse(baseUrl),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    } else {
      throw Exception("Error al obtener metas: ${res.body}");
    }
  }

  /* 🟢 Crear meta */
  Future<Map<String, dynamic>> createGoal({
    required String title,
    required double targetAmount,
    DateTime? targetDate,
  }) async {
    final token = await _getToken();
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "title": title,
        "targetAmount": targetAmount,
        "targetDate": targetDate?.toIso8601String(),
      }),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Error al crear meta: ${res.body}");
    }
  }

  /* 🟠 Actualizar meta */
  Future<void> updateGoal(String id, Map<String, dynamic> data) async {
    final token = await _getToken();
    final res = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );

    if (res.statusCode != 200) {
      throw Exception("Error al actualizar meta: ${res.body}");
    }
  }

  /* 🔴 Eliminar meta */
  Future<void> deleteGoal(String id) async {
    final token = await _getToken();
    final res = await http.delete(
      Uri.parse("$baseUrl/$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode != 200) {
      throw Exception("Error al eliminar meta: ${res.body}");
    }
  }
}
