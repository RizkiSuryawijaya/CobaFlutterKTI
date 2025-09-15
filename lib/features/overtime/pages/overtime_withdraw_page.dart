// File: pages/overtime_withdraw_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/ess_overtime_withdraw_controller.dart';
import '../models/ess_overtime_request.dart';

class OvertimeWithdrawPage extends StatefulWidget {
  const OvertimeWithdrawPage({super.key});

  @override
  State<OvertimeWithdrawPage> createState() => _OvertimeWithdrawPageState();
}

class _OvertimeWithdrawPageState extends State<OvertimeWithdrawPage> {
  final EssOvertimeWithdrawController controller =
      Get.put(EssOvertimeWithdrawController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchWithdraws();
    });
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey.shade400;
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green.shade700;
      case 'rejected':
        return Colors.red.shade700;
      case 'pending':
        return Colors.orange.shade700;
      default:
        return Colors.blue.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Withdraw Overtime"),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.withdrawRequests.isEmpty) {
          return const Center(
            child: Text(
              "Belum ada data withdraw overtime",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.withdrawRequests.length,
          itemBuilder: (context, index) {
            final EssOvertimeRequest lembur = controller.withdrawRequests[index];
            final statusColor = _getStatusColor(lembur.status);

            return Card(
              elevation: 5,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: tanggal & status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(
                                icon: Icons.event,
                                label: "Tanggal Mulai",
                                value: DateFormat("dd MMM yyyy").format(
                                  DateTime.parse(lembur.overtimeDate),
                                ),
                              ),
                              if (lembur.endDate != null)
                                _buildDetailRow(
                                  icon: Icons.calendar_today,
                                  label: "Tanggal Berakhir",
                                  value: DateFormat("dd MMM yyyy").format(
                                    DateTime.parse(lembur.endDate!),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Chip(
                          label: Text(
                            lembur.status ?? "Pending",
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: statusColor,
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Detail waktu & durasi
                    _buildDetailRow(
                      icon: Icons.access_time,
                      label: "Jam",
                      value: "${lembur.startTime} - ${lembur.endTime ?? 'N/A'}",
                    ),
                    _buildDetailRow(
                      icon: Icons.timer,
                      label: "Durasi",
                      value: lembur.totalDuration ?? "-",
                    ),

                    // Alasan & Remarks
                    _buildDetailRow(
                      icon: Icons.assignment,
                      label: "Alasan",
                      value: lembur.reason?.name ?? 'Tidak ada',
                    ),
                    _buildDetailRow(
                      icon: Icons.notes,
                      label: "Catatan",
                      value: lembur.remarks?.isNotEmpty == true
                          ? lembur.remarks!
                          : '-',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF0D47A1)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
