import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api_service.dart';

class EssOvertimeTotalService {
  static const String _baseUrl =
      "${ApiService.baseUrl}/overtime-durations/total";

  /// 🔹 Ambil token dari SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  /// 🔹 Header standar dengan Authorization jika ada
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  /// 🔹 GET total durasi lembur
  static Future<double> fetchTotal() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(_baseUrl), headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final total = json['data']?['total_durations'];
        if (total != null) {
          return (total as num).toDouble();
        } else {
          throw Exception("Data total_durations tidak ditemukan");
        }
      } else {
        throw Exception(
            "Gagal ambil total lembur (status: ${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan saat fetch total lembur: $e");
    }
  }
}
