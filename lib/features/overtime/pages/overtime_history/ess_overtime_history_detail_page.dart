// File: overtime_history_detail_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/ess_overtime_history_controller.dart';
import '../../controllers/ess_overtime_withdraw_controller.dart';
import '../../models/ess_overtime_request.dart';
import '../overtime/widgets/status_badge.dart';
import '../dummyapproved/dummy_approved.dart';

class OvertimeHistoryDetailPage extends StatelessWidget {
  final EssOvertimeRequest lembur;

  const OvertimeHistoryDetailPage({super.key, required this.lembur});

  void _confirmWithdraw(String id) {
    final EssOvertimeWithdrawController withdrawController =
        Get.find<EssOvertimeWithdrawController>();
    final EssOvertimeHistoryController historyController =
        Get.find<EssOvertimeHistoryController>();

    Get.dialog(
      AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Apakah kamu yakin ingin menarik lembur ini?"),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Get.back();
              await withdrawController.withdrawOvertime(id);
              await historyController.fetchHistory();
            },
            child: const Text("Ya, Tarik"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detail Lembur",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300), // kotak
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Detail Riwayat Lembur",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                  StatusBadge(status: lembur.status),
                ],
              ),
              const Divider(height: 20, thickness: 1),

              // 🔹 Detail lembur
              _buildDetailRow(
                icon: Icons.event,
                label: "Tanggal Mulai",
                value: DateFormat(
                  "dd MMM yyyy",
                ).format(DateTime.parse(lembur.overtimeDate)),
              ),
              if (lembur.endDate != null)
                _buildDetailRow(
                  icon: Icons.calendar_today,
                  label: "Tanggal Berakhir",
                  value: DateFormat(
                    "dd MMM yyyy",
                  ).format(DateTime.parse(lembur.endDate!)),
                ),
              _buildDetailRow(
                icon: Icons.access_time,
                label: "Jam",
                value: "${lembur.startTime} - ${lembur.endTime ?? 'N/A'}",
              ),
              _buildDetailRow(
                icon: Icons.timer,
                label: "Durasi",
                value: lembur.totalDuration ?? '-',
              ),
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

              // 🔹 Detail Approval
              const SizedBox(height: 10),
              Text(
                "Detail Persetujuan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              const Divider(height: 10, thickness: 1),
              // _buildDetailRow(
              //   icon: Icons.person_outline,
              //   label: "Disetujui Oleh",
              //   value: "-", // nanti diisi dari API
              // ),

              // Dummy Approved Section
              const DummyApprovedSection(), // tinggal dipanggil
              // 🔹 Tombol withdraw (kalau masih pending)
              if (lembur.status?.toLowerCase() == 'pending') ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    icon: const Icon(Icons.undo),
                    label: const Text("Withdraw"),
                    onPressed: () =>
                        _confirmWithdraw(lembur.overtimeId.toString()),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.blue.shade900),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
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
