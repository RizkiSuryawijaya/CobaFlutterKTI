import 'package:get/get.dart';
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
      Get.snackbar("Error", "Gagal mengambil data lembur: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createOvertime(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      await EssOvertimeRequestService.create(data);
      Get.snackbar("Success", "Overtime berhasil diajukan!");
      fetchOvertimeRequests();
      // Baris setelah diubah
      Get.toNamed(AppRoutes.overtimeHistory);
    } catch (e) {
      Get.snackbar("Error", "Gagal mengajukan lembur: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOvertime(String id, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      await EssOvertimeRequestService.update(id, data);
      Get.snackbar("Success", "Overtime berhasil diperbarui!");
      fetchOvertimeRequests(); // refresh list
    } catch (e) {
      Get.snackbar("Error", "Gagal memperbarui lembur: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteOvertime(String id) async {
    try {
      isLoading.value = true;
      await EssOvertimeRequestService.delete(id);
      Get.snackbar("Success", "Overtime berhasil dihapus!");
      fetchOvertimeRequests(); // refresh list
    } catch (e) {
      Get.snackbar("Error", "Gagal menghapus lembur: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
