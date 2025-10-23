import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ReportService {
  // 🔹 Cambia esta URL por tu dominio del backend
  final String baseUrl = "https://co-fi-web.vercel.app/api/reports";

  Future<String?> _getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    return await user?.getIdToken();
  }

  /// 🟢 Obtener resumen general de reportes (saldo, ingresos, egresos, ahorro)
  Future<Map<String, dynamic>> getGeneralReport() async {
    final token = await _getToken();
    final url = Uri.parse(baseUrl);

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Error al obtener reporte general: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// 🟣 Obtener reporte por categoría
  Future<List<Map<String, dynamic>>> getCategoryReport() async {
    final token = await _getToken();
    final url = Uri.parse("$baseUrl/category");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception(
        'Error al obtener reporte por categoría: ${response.statusCode}',
      );
    }
  }

  /// 🟠 Obtener evolución mensual (ingresos/gastos agrupados por mes)
  Future<List<Map<String, dynamic>>> getMonthlyReport() async {
    final token = await _getToken();
    final url = Uri.parse("$baseUrl/monthly");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception(
        'Error al obtener reporte mensual: ${response.statusCode}',
      );
    }
  }
}
