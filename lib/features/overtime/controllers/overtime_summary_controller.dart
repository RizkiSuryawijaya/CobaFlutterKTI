import 'package:get/get.dart';
import '../models/overtime_summary.dart';
import '../services/ess_overtime_summary_service.dart';

class OvertimeSummaryController extends GetxController {
  var isLoading = false.obs;
  var summary = Rxn<OvertimeSummary>();

  Future<void> fetchUserSummary(String token) async {
    try {
      isLoading.value = true;
      summary.value = await OvertimeSummaryService.getUserSummary(token);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAdminSummary(String token) async {
    try {
      isLoading.value = true;
      summary.value = await OvertimeSummaryService.getAdminSummary(token);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
