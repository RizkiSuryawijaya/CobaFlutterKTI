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

  @override
  void onInit() {
    super.onInit();
    loadUser(); // cek apakah user masih login saat app dibuka
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString("token");
    final savedUser = prefs.getString("user");

    if (savedToken != null && savedUser != null) {
      token.value = savedToken;
      currentUser.value = User.fromJson(jsonDecode(savedUser));

      // langsung arahkan ke dashboard sesuai role
      if (currentUser.value?.role == "Admin") {
        Get.offAllNamed(AppRoutes.adminDashboard);
      } else {
        Get.offAllNamed(AppRoutes.karyawanDashboard);
      }
    } else {
      // kalau belum login, arahkan ke login
      Get.offAllNamed(AppRoutes.login);
    }
  }

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

      // hapus data lokal
      await prefs.clear();
      currentUser.value = null;
      token.value = "";

      // redirect ke login
      Get.offAllNamed(AppRoutes.login);

      // panggil API logout (opsional, di background)
      if (savedToken != null && savedToken.isNotEmpty) {
        try {
          await AuthService.logout(savedToken);
        } catch (e) {
          print("Logout API error: $e");
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal logout: $e");
    }
  }
}
