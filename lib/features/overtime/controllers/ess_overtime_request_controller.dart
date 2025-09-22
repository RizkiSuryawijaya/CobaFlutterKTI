import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/ess_overtime_request.dart';
import '../services/ess_overtime_request_service.dart';
import '../../../routes/app_routes.dart';

class EssOvertimeRequestController extends GetxController {
  var isLoading = false.obs;
  var overtimeRequests = <EssOvertimeRequest>[].obs;

  @override
  void onInit() {
    fetchOvertimeRequests();
    super.onInit();
  }

  Future<void> fetchOvertimeRequests() async {
    try {
      isLoading.value = true;
      final fetchedRequests = await EssOvertimeRequestService.getAll();
      overtimeRequests.assignAll(fetchedRequests);
    } catch (e) {
      Get.snackbar(
        "Error", 
        "Gagal mengambil data lembur: $e",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> createOvertime(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      await EssOvertimeRequestService.create(data);
      
      Get.snackbar(
        "Berhasil 🎉", 
        "Pengajuan lembur berhasil diajukan!",
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
      
      // Mengganti halaman saat ini (create page) dengan halaman list history
      // agar tombol 'back' di history tidak kembali ke halaman create
      Get.offNamed(AppRoutes.overtimeHistory);
      
      // Memuat ulang data setelah navigasi selesai
      fetchOvertimeRequests();
    } catch (e) {
      Get.snackbar(
        "Gagal 🙁", 
        "Gagal mengajukan lembur: $e",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOvertime(String id, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      await EssOvertimeRequestService.update(id, data);
      
      // Tutup halaman update dan kembali ke halaman sebelumnya
      Get.back(); 

      Get.snackbar(
        "Berhasil 🎉", 
        "Pengajuan lembur berhasil diperbarui!",
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
      
      // Memuat ulang data setelah kembali
      fetchOvertimeRequests(); 
    } catch (e) {
      Get.snackbar(
        "Gagal 🙁", 
        "Gagal memperbarui lembur: $e",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteOvertime(String id) async {
    try {
      isLoading.value = true;
      await EssOvertimeRequestService.delete(id);
      
      Get.snackbar(
        "Berhasil 🎉", 
        "Pengajuan lembur berhasil dihapus!",
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
      
      fetchOvertimeRequests();
    } catch (e) {
      Get.snackbar(
        "Gagal 🙁", 
        "Gagal menghapus lembur: $e",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}