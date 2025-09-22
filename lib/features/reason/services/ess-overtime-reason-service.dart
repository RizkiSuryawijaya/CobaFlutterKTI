import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/ess-overtime-reason.dart';
import '../../../core/api_service.dart'; // ⬅️ pakai ApiService

class EssReasonOTService {
  static const String _baseUrl = "${ApiService.baseUrl}/reasons";

  /// Ambil token dari SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Header standar dengan Authorization
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// GET semua reason
  static Future<List<EssReasonOT>> getAll() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(_baseUrl), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => EssReasonOT.fromJson(item)).toList();
    } else {
      throw Exception(
          'Failed to load overtime reasons: ${response.statusCode}');
    }
  }

  /// GET reason by ID
  static Future<EssReasonOT> getById(String id) async {
    final headers = await _getHeaders();
    final response =
        await http.get(Uri.parse('$_baseUrl/$id'), headers: headers);

    if (response.statusCode == 200) {
      return EssReasonOT.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Failed to load overtime reason: ${response.statusCode}');
    }
  }

  /// POST create reason
  /// data wajib ada: {"kode_reason": "...", "name": "..."}
  static Future<EssReasonOT> create(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return EssReasonOT.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to create overtime reason');
    }
  }

  /// PUT update reason
  static Future<EssReasonOT> update(
      String id, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return EssReasonOT.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to update overtime reason');
    }
  }

  /// DELETE reason
  static Future<bool> delete(String id) async {
    final headers = await _getHeaders();
    final response =
        await http.delete(Uri.parse('$_baseUrl/$id'), headers: headers);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
          'Failed to delete overtime reason: ${response.statusCode}');
    }
  }
}
