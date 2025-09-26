// File: widgets/overtime_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../../../models/ess_overtime_request.dart';
import '../../../../../routes/app_routes.dart';

class OvertimeCard extends StatelessWidget {
  final EssOvertimeRequest overtime;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final bool showActions;
  final bool showUserInfo;

  const OvertimeCard({
    super.key,
    required this.overtime,
    this.onEdit,
    this.onDelete,
    this.onTap,
    this.showActions = true,
    this.showUserInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    final startDate = DateFormat("dd MMM yyyy")
        .format(DateTime.parse(overtime.overtimeDate));
    final endDate = overtime.endDate != null
        ? DateFormat("dd MMM yyyy").format(DateTime.parse(overtime.endDate!))
        : "-";

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Info User (tanpa status chip)
              if (showUserInfo)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nama: ${overtime.user?.name ?? '-'}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "NIK: ${overtime.user?.nik ?? '-'}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),

              if (showUserInfo) const SizedBox(height: 8),

              // 🔹 Tanggal
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: Colors.black54),
                  const SizedBox(width: 8),
                  Text(
                    "$startDate - $endDate",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 🔹 Jam + Durasi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Jam mulai
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Jam Mulai",
                          style:
                              TextStyle(fontSize: 11, color: Colors.black54)),
                      const SizedBox(height: 4),
                      Text(
                        overtime.startTime ?? '-',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  // Durasi
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "${overtime.totalDuration ?? '-'} ",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                        const Icon(Icons.arrow_forward,
                            size: 16, color: Colors.black54),
                      ],
                    ),
                  ),

                  // Jam selesai
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Jam Selesai",
                          style:
                              TextStyle(fontSize: 11, color: Colors.black54)),
                      const SizedBox(height: 4),
                      Text(
                        overtime.endTime ?? '-',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 🔹 Alasan
              Text(
                "Alasan: ${overtime.reason?.name ?? '-'}",
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 8),

              // 🔹 Aksi
              if (showActions)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: onEdit,
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: onDelete,
                      ),
                    TextButton(
                      onPressed: () => Get.toNamed(
                        AppRoutes.overtimeDetail,
                        arguments: overtime,
                      ),
                      child: const Text("Detail"),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
