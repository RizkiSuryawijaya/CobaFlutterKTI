// controllers/ess_overtime_withdraw_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/ess_overtime_withdraw_service.dart';

class EssOvertimeWithdrawController extends GetxController {
  var isLoading = false.obs;

  Future<void> withdrawOvertime(String overtimeId) async {
    try {
      isLoading.value = true;
      await EssOvertimeWithdrawService.withdraw(overtimeId);

      // Tutup modal atau halaman setelah berhasil
      Get.back();

      // Tampilkan notifikasi sukses
      Get.snackbar(
        "Berhasil 🎉",
        "Lembur berhasil ditarik!",
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Gagal 🙁",
        "Gagal menarik lembur: $e",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
