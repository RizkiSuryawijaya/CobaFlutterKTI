import 'package:get/get.dart';
import '../models/ess_config_overtime.dart';
import '../services/ess_config_overtime_service.dart';

class ConfigOvertimeController extends GetxController {
  var configs = <EssConfigOvertime>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchConfigs();
    super.onInit();
  }

  Future<void> fetchConfigs() async {
    try {
      isLoading.value = true;
      configs.value = await ConfigOvertimeService.fetchAll();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createConfig(EssConfigOvertime config) async {
    try {
      final newConfig = await ConfigOvertimeService.create(config);
      configs.add(newConfig);
      Get.back();
      Get.snackbar("Success", "Config berhasil dibuat");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> updateConfig(String id, EssConfigOvertime config) async {
    try {
      final updated = await ConfigOvertimeService.update(id, config);
      int index = configs.indexWhere((c) => c.id == id);
      if (index != -1) configs[index] = updated;
      Get.back();
      Get.snackbar("Success", "Config berhasil diupdate");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> deleteConfig(String id) async {
    try {
      await ConfigOvertimeService.delete(id);
      configs.removeWhere((c) => c.id == id);
      Get.snackbar("Success", "Config berhasil dihapus");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}
