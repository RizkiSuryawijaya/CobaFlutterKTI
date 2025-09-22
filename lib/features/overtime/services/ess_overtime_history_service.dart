// File: services/ess_overtime_history_service.dart
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/ess_overtime_request.dart';
import '../../../core/api_service.dart';

class EssOvertimeHistoryService {
  static const String _baseUrl = "${ApiService.baseUrl}/overtime-requests/history";

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
      throw Exception('Failed to load overtime history: ${response.statusCode}');
    }
  }

  static Future<List<EssOvertimeRequest>> getByPeriod(DateTime start, DateTime end) async {
    final headers = await _getHeaders();
    final url = Uri.parse("$_baseUrl?start=${start.toIso8601String()}&end=${end.toIso8601String()}");
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'];
      return data.map((item) => EssOvertimeRequest.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load overtime history by period: ${response.statusCode}');
    }
  }
}
