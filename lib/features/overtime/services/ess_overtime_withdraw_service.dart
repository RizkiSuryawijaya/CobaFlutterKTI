import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/ess_overtime_request.dart';
import '../../../core/api_service.dart';

class EssOvertimeWithdrawService {
  static const String _baseUrl = "${ApiService.baseUrl}/overtime-requests";

  //  Ambil token dari SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  //  Buat header standar
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  //  Tarik lembur (PATCH /lembur/:id/withdraw)
  static Future<EssOvertimeRequest> withdraw(String id) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse("$_baseUrl/$id/withdraw"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return EssOvertimeRequest.fromJson(json['data']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to withdraw overtime');
    }
  }


}
