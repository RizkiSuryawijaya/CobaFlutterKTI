import 'package:get/get.dart';
import '../services/ess_overtime_total_service.dart';

class EssOvertimeTotalController extends GetxController {
  var isLoading = false.obs;
  var total = 0.0.obs;

  @override
  void onInit() {
    fetchTotalOvertime();
    super.onInit();
  }

  Future<void> fetchTotalOvertime() async {
    try {
      isLoading.value = true;
      final result = await EssOvertimeTotalService.fetchTotal();
      total.value = result;
    } catch (e) {
      Get.snackbar("Error", "Gagal ambil total lembur: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// convert jadi format jam & menit
  String get totalFormatted {
    final jam = total.value.floor();
    final menit = ((total.value - jam) * 60).round();
    if (jam > 0 && menit > 0) return "$jam jam $menit menit";
    if (jam > 0) return "$jam jam";
    return "$menit menit";
  }
}
