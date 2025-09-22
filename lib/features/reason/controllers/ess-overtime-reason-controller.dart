import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/ess-overtime-reason.dart';
import '../services/ess-overtime-reason-service.dart';

class EssReasonOTController extends GetxController {
  var isLoading = false.obs;
  var reasons = <EssReasonOT>[].obs;

  @override
  void onInit() {
    fetchReasons();
    super.onInit();
  }

  Future<void> fetchReasons() async {
    try {
      isLoading.value = true;
      final data = await EssReasonOTService.getAll();
      reasons.assignAll(data);
    } catch (e) {
      Get.snackbar(
        "Gagal 🙁",
        "Gagal mengambil alasan lembur: $e",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addReason(String kodeReason, String name) async {
    try {
      isLoading.value = true;
      await EssReasonOTService.create({
        "kode_reason": kodeReason,
        "name": name,
      });
      await fetchReasons(); // Muat ulang daftar setelah berhasil
      Get.snackbar(
        "Berhasil 🎉",
        "Alasan lembur berhasil ditambahkan.",
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Gagal 🙁",
        "Gagal menambah alasan lembur: $e",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateReason(String reasonId, String kodeReason, String name) async {
    try {
      isLoading.value = true;
      await EssReasonOTService.update(reasonId, {
        "kode_reason": kodeReason,
        "name": name,
      });
      await fetchReasons(); // Muat ulang daftar setelah berhasil
      Get.snackbar(
        "Berhasil 🎉",
        "Alasan lembur berhasil diperbarui.",
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Gagal 🙁",
        "Gagal memperbarui alasan lembur: $e",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteReason(String reasonId) async {
    try {
      isLoading.value = true;
      await EssReasonOTService.delete(reasonId);
      await fetchReasons(); // Muat ulang daftar setelah berhasil
      Get.snackbar(
        "Berhasil 🎉",
        "Alasan lembur berhasil dihapus.",
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Gagal 🙁",
        "Gagal menghapus alasan lembur: $e",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}