import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/api_service.dart';  

class AuthService {
  static const String _authUrl = "${ApiService.baseUrl}/auth";

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$_authUrl/login");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("❌ Login gagal: ${response.body}");
    }
  }

  static Future<void> logout(String token) async {
    final url = Uri.parse("$_authUrl/logout");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("❌ Logout gagal: ${response.body}");
    }
  }
}
