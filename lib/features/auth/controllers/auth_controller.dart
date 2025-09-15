import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../../../routes/app_routes.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var currentUser = Rxn<User>();
  var token = "".obs;

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      final result = await AuthService.login(email, password);
      token.value = result["token"];

      final userData = result["user"];
      currentUser.value = User.fromJson(userData);

      // simpan ke storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token.value);
      await prefs.setString("user", jsonEncode(userData));

      // redirect sesuai role
      if (userData["role"] == "Admin") {
        Get.offAllNamed(AppRoutes.adminDashboard);
      } else {
        Get.offAllNamed(AppRoutes.karyawanDashboard);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString("token");

    // Clear local data dulu biar UI langsung balik ke login
    await prefs.clear();
    currentUser.value = null;
    token.value = "";

    // Redirect ke login tanpa nunggu API
    Get.offAllNamed(AppRoutes.login);

    // Opsional: panggil API logout di background (jangan ganggu UI)
    if (savedToken != null && savedToken.isNotEmpty) {
      try {
        await AuthService.logout(savedToken);
      } catch (e) {
        // Bisa di-log aja, jangan block UI
        print("Logout API error: $e");
      }
    }
  } catch (e) {
    Get.snackbar("Error", "Gagal logout: $e");
  }
}


}
