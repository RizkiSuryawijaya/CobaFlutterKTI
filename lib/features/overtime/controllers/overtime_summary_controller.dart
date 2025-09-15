import 'package:get/get.dart';
import '../models/overtime_summary.dart';
import '../services/ess_overtime_summary_service.dart';

class OvertimeSummaryController extends GetxController {
  var isLoading = false.obs;
  var summary = Rxn<OvertimeSummary>();

  Future<void> fetchUserSummary() async {
    try {
      isLoading.value = true;
      summary.value = await OvertimeSummaryService.getUserSummary();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAdminSummary() async {
    try {
      isLoading.value = true;
      summary.value = await OvertimeSummaryService.getAdminSummary();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
