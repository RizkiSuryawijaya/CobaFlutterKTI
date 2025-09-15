// File: controllers/ess_overtime_history_controller.dart
import 'package:get/get.dart';
import '../models/ess_overtime_request.dart';
import '../services/ess_overtime_history_service.dart';

class EssOvertimeHistoryController extends GetxController {
  var isLoading = false.obs;
  var historyRequests = <EssOvertimeRequest>[].obs;

  @override
  void onInit() {
    fetchHistory();
    super.onInit();
  }

  Future<void> fetchHistory() async {
    try {
      isLoading.value = true;
      final fetchedRequests = await EssOvertimeHistoryService.getAll();
      historyRequests.assignAll(fetchedRequests);
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil riwayat lembur: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchHistoryByPeriod(DateTime start, DateTime end) async {
    try {
      isLoading.value = true;
      final fetchedRequests = await EssOvertimeHistoryService.getByPeriod(start, end);
      historyRequests.assignAll(fetchedRequests);
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil riwayat lembur per periode: $e");
    } finally {
      isLoading.value = false;
    }
  }
}


