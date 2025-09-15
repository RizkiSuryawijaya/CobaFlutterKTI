import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/overtime_summary.dart';

class OvertimeSummaryService {
  static const String baseUrl = "http://localhost:3000/api/overtime-summary";
  // ganti sesuai URL backend kamu

  static Future<OvertimeSummary> getUserSummary(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/status/user"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return OvertimeSummary.fromJson(body['data']);
    } else {
      throw Exception("Gagal mengambil summary user");
    }
  }

  static Future<OvertimeSummary> getAdminSummary(String token) async {
    
    print("DEBUG TOKEN ADMIN: $token"); // cek apakah kosong
    final response = await http.get(
      Uri.parse("$baseUrl/status/all"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return OvertimeSummary.fromJson(body['data']);
    } else {
      throw Exception("Gagal mengambil summary admin");
    }
  }
}
