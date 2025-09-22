import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/ess_overtime_request.dart';
import '../../../core/api_service.dart';

class EssOvertimeRequestService {
  static const String _baseUrl = "${ApiService.baseUrl}/overtime-requests";
  
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  static Future<List<EssOvertimeRequest>> getAll() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(_baseUrl), headers: headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'];
      return data.map((item) => EssOvertimeRequest.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load overtime requests: ${response.statusCode}');
    }
  }

  static Future<EssOvertimeRequest> getById(String id) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$_baseUrl/$id'), headers: headers);

    if (response.statusCode == 200) {
      return EssOvertimeRequest.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load overtime request: ${response.statusCode}');
    }
  }

  static Future<EssOvertimeRequest> create(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return EssOvertimeRequest.fromJson(json['data']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to create overtime request');
    }
  }

  static Future<EssOvertimeRequest> update(String id, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return EssOvertimeRequest.fromJson(json['data']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to update overtime request');
    }
  }

  static Future<bool> delete(String id) async {
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse('$_baseUrl/$id'), headers: headers);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete overtime request: ${response.statusCode}');
    }
  }
}