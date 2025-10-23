import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class GroupService {
  final String baseUrl = "https://co-fi-web.vercel.app/api/groups";

  Future<String?> _getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }
    return await user.getIdToken();
  }

  /// 🟢 Crear grupo
  Future<Map<String, dynamic>> createGroup({
    required String name,
    String? description,
    String privacy = "invite_only",
  }) async {
    final token = await _getToken();
    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    // Build body without null fields to avoid sending "description": null
    final Map<String, dynamic> body = {"name": name, "privacy": privacy};
    if (description != null && description.trim().isNotEmpty) {
      body['description'] = description.trim();
    }

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      // Try to parse error body to give a clearer message
      try {
        final parsed = jsonDecode(response.body);
        final message = parsed is Map
            ? (parsed['error'] ?? parsed['message'] ?? response.body)
            : response.body;
        throw Exception(
          'Error al crear grupo: $message (status ${response.statusCode})',
        );
      } catch (_) {
        throw Exception(
          'Error al crear grupo: ${response.body} (status ${response.statusCode})',
        );
      }
    }
  }

  /// 🟣 Listar grupos del usuario
  Future<List<dynamic>> getUserGroups() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al obtener grupos: ${response.body}");
    }
  }

  /// 🟡 Obtener detalle de un grupo
  Future<Map<String, dynamic>> getGroupDetail(String id) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al obtener detalle del grupo: ${response.body}");
    }
  }

  /// 🟠 Actualizar grupo
  Future<Map<String, dynamic>> updateGroup({
    required String id,
    required String name,
    String? description,
    String? privacy,
  }) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name,
        "description": description,
        "privacy": privacy,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al actualizar grupo: ${response.body}");
    }
  }

  /// 🔴 Eliminar grupo
  Future<void> deleteGroup(String id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse("$baseUrl/$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Error al eliminar grupo: ${response.body}");
    }
  }

  /// 🟣 Invitar miembro
  Future<Map<String, dynamic>> inviteMember({
    required String groupId,
    required String inviteeEmail,
  }) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse("$baseUrl/invites"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"groupId": groupId, "inviteeEmail": inviteeEmail}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al enviar invitación: ${response.body}");
    }
  }

  /// 🟢 Unirse a grupo por código
  Future<Map<String, dynamic>> joinGroup(String joinCode) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse("$baseUrl/join"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"joinCode": joinCode}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al unirse al grupo: ${response.body}");
    }
  }

  /// 🟡 Salir de un grupo
  Future<Map<String, dynamic>> leaveGroup(String groupId) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse("$baseUrl/members/leave"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"groupId": groupId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al salir del grupo: ${response.body}");
    }
  }

  /// 🟣 Listar miembros de un grupo
  Future<List<dynamic>> getGroupMembers(String groupId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/members?groupId=$groupId"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al obtener miembros: ${response.body}");
    }
  }

  /// 🟠 Actualizar rol de miembro
  Future<Map<String, dynamic>> updateMemberRole({
    required String memberId,
    required String newRole,
  }) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse("$baseUrl/members"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"memberId": memberId, "newRole": newRole}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al actualizar rol: ${response.body}");
    }
  }

  /// 🔴 Eliminar miembro
  Future<void> deleteMember(String memberId) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse("$baseUrl/members"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"memberId": memberId}),
    );

    if (response.statusCode != 200) {
      throw Exception("Error al eliminar miembro: ${response.body}");
    }
  }
}
