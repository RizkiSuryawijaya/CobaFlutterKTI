import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ess_config_overtime.dart';
import '../../../core/api_service.dart';

class ConfigOvertimeService {
  static const String _baseUrl = "${ApiService.baseUrl}/config-overtime";

  // Ambil token dari SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Buat header standar
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // GET semua config overtime
  static Future<List<EssConfigOvertime>> fetchAll() async {
    final headers = await _getHeaders();
    final res = await http.get(Uri.parse(_baseUrl), headers: headers);

    if (res.statusCode == 200) {
      final jsonRes = jsonDecode(res.body);
      final List data = jsonRes['data'];
      return data.map((e) => EssConfigOvertime.fromMap(e)).toList();
    } else {
      final error = jsonDecode(res.body);
      throw Exception(error['message'] ?? 'Gagal ambil config overtime');
    }
  }

  // POST buat config baru
  static Future<EssConfigOvertime> create(EssConfigOvertime config) async {
    final headers = await _getHeaders();
    print("DEBUG POST body: ${config.toCreateJson()}"); // ✅ Debugging
    final res = await http.post(
      Uri.parse(_baseUrl),
      headers: headers,
      body: config.toCreateJson(),
    );

    if (res.statusCode == 201) {
      final jsonRes = jsonDecode(res.body);
      return EssConfigOvertime.fromMap(jsonRes['data']);
    } else {
      final error = jsonDecode(res.body);
      throw Exception(error['message'] ?? 'Gagal buat config overtime');
    }
  }

  // PUT update config overtime
  static Future<EssConfigOvertime> update(
      String id, EssConfigOvertime config) async {
    final headers = await _getHeaders();
    print("DEBUG PUT body: ${config.toCreateJson()}"); // ✅ Debugging
    final res = await http.put(
      Uri.parse("$_baseUrl/$id"),
      headers: headers,
      body: config.toCreateJson(),
    );

    if (res.statusCode == 200) {
      final jsonRes = jsonDecode(res.body);
      return EssConfigOvertime.fromMap(jsonRes['data']);
    } else {
      final error = jsonDecode(res.body);
      throw Exception(error['message'] ?? 'Gagal update config overtime');
    }
  }

  // DELETE config overtime
  static Future<void> delete(String id) async {
    final headers = await _getHeaders();
    final res = await http.delete(Uri.parse("$_baseUrl/$id"), headers: headers);

    if (res.statusCode != 200) {
      final error = jsonDecode(res.body);
      throw Exception(error['message'] ?? 'Gagal hapus config overtime');
    }
  }
}
