import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ess_overtime_summary.dart';
import '../../../core/api_service.dart';

class OvertimeSummaryService {
  static const String _baseUrl = "${ApiService.baseUrl}/overtime-summary";

  /// Ambil token dari SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  /// Header standar
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// GET summary user
  static Future<OvertimeSummary> getUserSummary() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse("$_baseUrl/status/user"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return OvertimeSummary.fromJson(body['data']);
    } else {
      throw Exception("Gagal mengambil summary user: ${response.body}");
    }
  }

  /// GET summary admin
  static Future<OvertimeSummary> getAdminSummary() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse("$_baseUrl/status/all"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return OvertimeSummary.fromJson(body['data']);
    } else {
      throw Exception("Gagal mengambil summary admin: ${response.body}");
    }
  }
}
