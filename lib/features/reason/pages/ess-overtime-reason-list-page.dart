import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ess-overtime-reason-controller.dart';
import '../models/ess-overtime-reason.dart';
import '../../../routes/app_routes.dart';

class ReasonListPage extends StatelessWidget {
  const ReasonListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final EssReasonOTController controller = Get.put(EssReasonOTController());

    // Fungsi untuk memicu refresh data
    Future<void> _onRefresh() async {
      await controller.fetchReasons();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Daftar Reason OT",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.reasons.isEmpty) {
          return Center(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                children: const [
                  SizedBox(height: 100), // Memberikan ruang di atas
                  Center(
                    child: Text(
                      "Belum ada alasan",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            itemCount: controller.reasons.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemBuilder: (context, index) {
              final EssReasonOT reason = controller.reasons[index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Icon(Icons.note_alt, color: Colors.blue[900]),
                  ),
                  title: Text(
                    reason.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "Kode: ${reason.kodeReason}",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Get.toNamed(AppRoutes.updateReason, arguments: reason);
                        },
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          Get.dialog(
                            AlertDialog(
                              title: const Text('Hapus Reason', style: TextStyle(fontWeight: FontWeight.bold)),
                              content: Text(
                                'Apakah Anda yakin ingin menghapus reason "${reason.name}"?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    controller.deleteReason(reason.reasonId!);
                                    Get.back();
                                  },
                                  child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        tooltip: 'Hapus',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.createReason),
        label: const Text('Tambah Reason'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blue[900],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}