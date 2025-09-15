import 'package:get/get.dart';
import '../models/ess_reason_ot.dart';
import '../services/ess_reason_ot_service.dart';

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
      Get.snackbar("Error", "Gagal mengambil reason: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addReason(String kodeReason, String name) async {
    try {
      isLoading.value = true;
      await EssReasonOTService.create({
        "kode_reason": kodeReason,
        "name": name
      });
      await fetchReasons();
      Get.snackbar("Success", "Reason berhasil ditambahkan");
    } catch (e) {
      Get.snackbar("Error", "Gagal menambah reason: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateReason(String reasonId, String kodeReason, String name) async {
    try {
      isLoading.value = true;
      await EssReasonOTService.update(reasonId, {
        "kode_reason": kodeReason,
        "name": name
      });
      await fetchReasons();
      Get.snackbar("Success", "Reason berhasil diperbarui");
    } catch (e) {
      Get.snackbar("Error", "Gagal memperbarui reason: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteReason(String reasonId) async {
    try {
      isLoading.value = true;
      await EssReasonOTService.delete(reasonId);
      await fetchReasons();
      Get.snackbar("Success", "Reason berhasil dihapus");
    } catch (e) {
      Get.snackbar("Error", "Gagal menghapus reason: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
