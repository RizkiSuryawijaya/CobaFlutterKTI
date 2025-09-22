import 'package:get/get.dart';
import '../models/ess_overtime_summary.dart';
import '../services/ess_overtime_summary_service.dart';

class OvertimeSummaryController extends GetxController {
  var isLoading = false.obs;
  var summary = Rxn<OvertimeSummary>();

  @override
  void onInit() {
    super.onInit();
    // Default ambil summary admin (bisa diganti sesuai kebutuhan)
    fetchAdminSummary();
  }

  Future<void> fetchUserSummary() async {
    try {
      isLoading.value = true;
      summary.value = await OvertimeSummaryService.getUserSummary();
    } catch (e) {
      Get.snackbar("Error", "Gagal ambil summary user: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAdminSummary() async {
    try {
      isLoading.value = true;
      summary.value = await OvertimeSummaryService.getAdminSummary();
    } catch (e) {
      Get.snackbar("Error", "Gagal ambil summary admin: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Bisa dipanggil manual buat refresh instan
  Future<void> refreshData({bool isAdmin = true}) async {
    if (isAdmin) {
      await fetchAdminSummary();
    } else {
      await fetchUserSummary();
    }
  }
}
