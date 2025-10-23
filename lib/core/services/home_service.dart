import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class HomeService {
  static const String baseUrl = "https://co-fi-web.vercel.app/api";

  static Future<Map<String, dynamic>> getHomeData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");

    final token = await user.getIdToken();

    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };

    // Helper to GET an endpoint and safely return a List<dynamic>.
    Future<List<dynamic>> fetchList(String path) async {
      try {
        final res = await http.get(
          Uri.parse('$baseUrl/$path'),
          headers: headers,
        );
        if (res.statusCode != 200) {
          // Non-OK: return empty list instead of throwing (keeps UI resilient)
          return [];
        }

        final body = res.body.trim();
        if (body.isEmpty) return [];

        try {
          final decoded = json.decode(body);
          if (decoded is List) return decoded;
          if (decoded is Map) {
            // Try common wrappers
            if (decoded['data'] is List) return decoded['data'];
            if (decoded['items'] is List) return decoded['items'];
            // Single object -> wrap into list
            return [decoded];
          }
          // Unknown shape => empty
          return [];
        } catch (_) {
          // Body was not valid JSON (e.g., HTML error page). Return empty list.
          return [];
        }
      } catch (e) {
        // Network or other error: return empty list so UI can show partial data
        return [];
      }
    }

    // Fetch all resources in parallel to reduce waiting time
    final results = await Future.wait<List<dynamic>>([
      fetchList('accounts'),
      fetchList('budgets'),
      fetchList('transactions'),
      fetchList('categories'),
      fetchList('goals'),
    ]);

    final accounts = results.length > 0 ? results[0] : [];
    final budgets = results.length > 1 ? results[1] : [];
    final transactions = results.length > 2 ? results[2] : [];
    final categories = results.length > 3 ? results[3] : [];
    final goals = results.length > 4 ? results[4] : [];

    return {
      "accounts": accounts,
      "budgets": budgets,
      "transactions": transactions,
      "categories": categories,
      "goals": goals,
    };
  }
}
