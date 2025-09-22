// File: controllers/ess_overtime_config_controller.dart

import 'package:flutter/material.dart'; 
import 'package:get/get.dart';
import '../models/ess_overtime_config.dart';
import '../services/ess_overtime_config_service.dart';

class ConfigOvertimeController extends GetxController {
  var configs = <EssConfigOvertime>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchConfigs();
    super.onInit();
  }

  Future<void> fetchConfigs() async {
    try {
      isLoading.value = true;
      configs.value = await ConfigOvertimeService.fetchAll();
    } catch (e) {
      Get.snackbar(
        "Gagal 🙁",
        "Gagal mengambil data konfigurasi: $e",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createConfig(EssConfigOvertime config) async {
    try {
      isLoading.value = true;
      final newConfig = await ConfigOvertimeService.create(config);
      configs.add(newConfig);
      
      Get.back(); // Tutup halaman create
      
      Get.snackbar(
        "Berhasil 🎉",
        "Konfigurasi berhasil dibuat.",
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Gagal 🙁",
        "Gagal membuat konfigurasi: $e",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateConfig(String id, EssConfigOvertime config) async {
    try {
      isLoading.value = true;
      final updated = await ConfigOvertimeService.update(id, config);
      int index = configs.indexWhere((c) => c.id == id);
      if (index != -1) configs[index] = updated;
      
      Get.back(); // Tutup halaman update
      
      Get.snackbar(
        "Berhasil 🎉",
        "Konfigurasi berhasil diperbarui!",
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Gagal 🙁",
        "Gagal memperbarui konfigurasi: $e",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteConfig(String id) async {
    try {
      isLoading.value = true;
      await ConfigOvertimeService.delete(id);
      configs.removeWhere((c) => c.id == id);
      
      Get.snackbar(
        "Berhasil 🎉",
        "Konfigurasi berhasil dihapus.",
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Gagal 🙁",
        "Gagal menghapus konfigurasi: $e",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

