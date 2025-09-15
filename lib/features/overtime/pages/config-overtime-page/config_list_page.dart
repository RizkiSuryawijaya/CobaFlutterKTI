import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/ess_config_overtime_controller.dart';
import '../../../../routes/app_routes.dart';

class ConfigListPage extends StatelessWidget {
  final controller = Get.put(ConfigOvertimeController());

  ConfigListPage({super.key});

  String formatHoursMinutes(double hours) {
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    return "$h jam ${m} menit";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50, // Latar belakang lembut
      appBar: AppBar(
        title: const Text(
          "Pengaturan Lembur Karyawan",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          );
        }

        if (controller.configs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.settings_overscan,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  "Belum ada pengaturan lembur",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 18,
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
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.configs.length,
          itemBuilder: (context, index) {
            final config = controller.configs[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Edit ketika card di tap
                      Get.toNamed(AppRoutes.configOvertimeUpdate, arguments: config);
                    },
                    splashColor: Colors.blue.shade100,
                    highlightColor: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Icon jam
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.watch_later_outlined,
                              color: Colors.blue.shade700,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Batas Lembur",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${formatHoursMinutes(config.monthlyTotalDurationHours)} / bulan",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Waktu Istirahat",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${config.restTimeMinutes} menit",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Tombol Edit
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.green.shade400, size: 28),
                            tooltip: 'Ubah Pengaturan',
                            onPressed: () {
                              Get.toNamed(AppRoutes.configOvertimeUpdate, arguments: config);
                            },
                          ),
                          // Tombol Hapus
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 28),
                            tooltip: 'Hapus Pengaturan',
                            onPressed: () {
                              Get.defaultDialog(
                                title: "Konfirmasi Hapus",
                                middleText: "Anda yakin ingin menghapus pengaturan ini?",
                                backgroundColor: Colors.white,
                                titleStyle: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                                middleTextStyle: const TextStyle(color: Colors.black87),
                                confirmTextColor: Colors.white,
                                buttonColor: Colors.red,
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
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(AppRoutes.configOvertimeCreate);
        },
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
