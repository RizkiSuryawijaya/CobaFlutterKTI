// controllers/ess_overtime_withdraw_controller.dart
import 'package:get/get.dart';
import '../models/ess_overtime_request.dart';
import '../services/ess_overtime_withdraw_service.dart';

class EssOvertimeWithdrawController extends GetxController {
  var isLoading = false.obs;
  var withdrawRequests = <EssOvertimeRequest>[].obs;


Future<void> fetchWithdraws() async {
  try {
    isLoading.value = true;
    final fetched = await EssOvertimeWithdrawService.getAllWithdraw();
    withdrawRequests.assignAll(fetched);
  } catch (e) {
    Get.snackbar("Error", "Gagal mengambil data withdraw: $e");
  } finally {
    isLoading.value = false;
  }
}

Future<void> withdrawOvertime(String overtimeId) async {
  try {
    isLoading.value = true;
    await EssOvertimeWithdrawService.withdraw(overtimeId); // PATCH
    Get.snackbar("Success", "Overtime berhasil ditarik!");
    fetchWithdraws(); // refresh list withdraw
  } catch (e) {
    Get.snackbar("Error", "Gagal menarik lembur: $e");
  } finally {
    isLoading.value = false;
  }
}


}
