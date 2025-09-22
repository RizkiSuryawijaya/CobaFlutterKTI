import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/ess_overtime_config_controller.dart';
import '../../../../routes/app_routes.dart';

class ConfigListPage extends StatelessWidget {
  final controller = Get.put(ConfigOvertimeController());

  ConfigListPage({super.key});

  String formatHoursMinutes(double hours) {
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    return "${h} jam ${m} menit";
  }

  Future<void> _refreshData() async {
    await controller.fetchConfigs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Ganti background yang lebih soft
      appBar: AppBar(
        title: const Text(
          "Pengaturan Lembur Karyawan",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF0056D2), // Warna biru yang lebih deep
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: const Color(0xFF0056D2),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0056D2)),
              ),
            );
          }

          if (controller.configs.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.work_off_outlined, // Ganti ikon yang lebih relevan
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Belum ada pengaturan lembur",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tekan '+' untuk menambah yang baru.",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: controller.configs.length,
            itemBuilder: (context, index) {
              final config = controller.configs[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                elevation: 1, // Turunkan sedikit elevasi
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFE3F2FD), // Warna avatar yang lebih soft
                        radius: 28,
                        child: Icon(
                          Icons.timer_outlined, // Ganti ikon yang lebih modern
                          color: const Color(0xFF1976D2),
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${formatHoursMinutes(config.monthlyTotalDurationHours)} / bulan",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1976D2), // Warna teks yang lebih menyala
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Waktu istirahat: ${config.restTimeMinutes} menit",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit,
                                color: const Color(0xFF64B5F6), size: 24), // Warna ikon edit
                            tooltip: 'Ubah Pengaturan',
                            onPressed: () {
                              Get.toNamed(AppRoutes.configOvertimeUpdate,
                                  arguments: config);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_forever_outlined,
                                color: Colors.red.shade400, size: 24), // Warna ikon delete
                            tooltip: 'Hapus Pengaturan',
                            onPressed: () {
                              Get.defaultDialog(
                                title: "Konfirmasi Hapus",
                                middleText:
                                    "Anda yakin ingin menghapus pengaturan ini?",
                                backgroundColor: Colors.white,
                                titleStyle: TextStyle(
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.bold),
                                middleTextStyle:
                                    const TextStyle(color: Colors.black87),
                                confirmTextColor: Colors.white,
                                buttonColor: Colors.red.shade600,
                                textConfirm: "Hapus",
                                textCancel: "Batal",
                                cancelTextColor: Colors.grey.shade700,
                                onConfirm: () {
                                  controller.deleteConfig(config.id);
                                  Get.back();
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(AppRoutes.configOvertimeCreate);
        },
        backgroundColor: const Color(0xFF0056D2),
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Sudut yang sedikit lebih besar
        ),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}