import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ess_reason_ot_controller.dart';
import '../models/ess_reason_ot.dart';

class UpdateReasonPage extends StatelessWidget {
  final EssReasonOT reason;
  final controller = Get.find<EssReasonOTController>();
  final TextEditingController kodeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  UpdateReasonPage({super.key, required this.reason}) {
    kodeController.text = reason.kodeReason;
    nameController.text = reason.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Update Reason",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: kodeController,
                decoration: InputDecoration(
                  labelText: "Kode Reason",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.vpn_key),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Nama Reason",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 30),
              Obx(
                () => ElevatedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          controller.updateReason(
                            reason.reasonId!,
                            kodeController.text,
                            nameController.text,
                          );
                          Get.back();
                        },
                  icon: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    controller.isLoading.value ? "Memproses..." : "Update",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}