// File: pages/overtime_detail_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/ess_overtime_request.dart';
import '../widgets/status_badge.dart';

class OvertimeDetailPage extends StatelessWidget {
  final EssOvertimeRequest overtime;

  const OvertimeDetailPage({super.key, required this.overtime});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detail Pengajuan Lembur",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300), // kotak
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const Divider(height: 32, thickness: 1, color: Colors.black12),
              _buildDetailSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nama",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              overtime.user?.name ?? 'Tidak Diketahui',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'NIK: ${overtime.user?.nik.toString() ?? 'Tidak Diketahui'}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
        StatusBadge(status: overtime.status), // ✅ pakai StatusBadge
      ],
    );
  }

  Widget _buildDetailSection() {
    final isSameDay = overtime.overtimeDate != null &&
            overtime.endDate != null
        ? DateTime.parse(overtime.overtimeDate!)
            .isAtSameMomentAs(DateTime.parse(overtime.endDate!))
        : false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tanggal Mulai
        _buildInfoRow(
          label: 'Tanggal Mulai',
          value: DateFormat('dd MMMM yyyy')
              .format(DateTime.parse(overtime.overtimeDate!)),
          icon: Icons.calendar_today,
        ),
        if (!isSameDay) ...[
          const SizedBox(height: 16),
          // Tanggal Selesai
          _buildInfoRow(
            label: 'Tanggal Selesai',
            value: DateFormat('dd MMMM yyyy')
                .format(DateTime.parse(overtime.endDate!)),
            icon: Icons.calendar_today,
          ),
        ],
        const SizedBox(height: 16),
        // Waktu Lembur
        _buildInfoRow(
          label: 'Waktu Lembur',
          value: '${overtime.startTime} - ${overtime.endTime}',
          icon: Icons.access_time,
        ),
        if (overtime.totalDuration != null) ...[
          const SizedBox(height: 16),
          _buildInfoRow(
            label: 'Durasi Total',
            value: '${overtime.totalDuration} jam',
            icon: Icons.timelapse,
          ),
        ],
        const SizedBox(height: 16),
        // Alasan
        _buildInfoRow(
          label: 'Alasan Lembur',
          value: overtime.reason?.name ?? '-',
          icon: Icons.assignment,
        ),
        const SizedBox(height: 16),
        // Catatan
        _buildInfoRow(
          label: 'Catatan',
          value: overtime.remarks ?? '-',
          icon: Icons.notes,
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Colors.blueGrey),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
