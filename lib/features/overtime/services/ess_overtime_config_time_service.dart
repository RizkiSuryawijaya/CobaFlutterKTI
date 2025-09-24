import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ess_overtime_config.dart';
import '../../../core/api_service.dart';

class ConfigOvertimeService {
  static const String _baseUrl = "${ApiService.baseUrl}/config-overtime";

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

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

  // PUT update config overtime biasa
  static Future<EssConfigOvertime> update(
      String id, EssConfigOvertime config) async {
    final headers = await _getHeaders();
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

  // PUT update khusus isActive
  static Future<EssConfigOvertime> updateIsActive(String id, bool isActive) async {
    final headers = await _getHeaders();
    final res = await http.put(
      Uri.parse("$_baseUrl/$id"),
      headers: headers,
      body: json.encode({'is_active': isActive}),
    );

    if (res.statusCode == 200) {
      final jsonRes = jsonDecode(res.body);
      return EssConfigOvertime.fromMap(jsonRes['data']);
    } else {
      final error = jsonDecode(res.body);
      throw Exception(error['message'] ?? 'Gagal update status config overtime');
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
