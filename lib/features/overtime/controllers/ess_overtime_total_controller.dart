// File: ess_overtime_total_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/ess_overtime_total_service.dart';

class EssOvertimeTotalController extends GetxController {
  var isLoading = false.obs;
  var total = 0.0.obs;

  @override
  void onInit() {
    fetchTotalOvertime();
    super.onInit();
  }

  Future<void> fetchTotalOvertime() async {
    try {
      isLoading.value = true;
      final result = await EssOvertimeTotalService.fetchTotal();
      total.value = result;
    } catch (e) {
      Get.snackbar(
        "Gagal 🙁",
        "Gagal mengambil total jam lembur: $e",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Konversi total jam (double) menjadi format jam dan menit yang mudah dibaca.
  String get totalFormatted {
    final jam = total.value.floor();
    final menit = ((total.value - jam) * 60).round();
    if (jam > 0 && menit > 0) return "$jam jam $menit menit";
    if (jam > 0) return "$jam jam";
    if (menit > 0) return "$menit menit";
    return "0 menit";
  }
}