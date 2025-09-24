import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/ess_overtime_request_controller.dart';
import '../../../../reason/models/ess-overtime-reason.dart';
import '../widgets/ess_overtime_step_indicator.dart';
import '../../dummyapproved/dummy_approved.dart';
import '../../dummyapproved/dummy_shift_page.dart';

class ApplyOvertimeConfirmPage extends StatelessWidget {
  final DateTime date;
  final DateTime? endDate;
  final String startTime, endTime, duration, remarks;
  final EssReasonOT reason;
  final bool isNextDay;

  ApplyOvertimeConfirmPage({
    super.key,
    required this.date,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.remarks,
    required this.reason,
    required this.isNextDay,
  });

  final EssOvertimeRequestController controller = Get.find();

  void _submit() {
    final data = {
      'overtime_date': DateFormat('yyyy-MM-dd').format(date),
      'end_date': isNextDay && endDate != null
          ? DateFormat('yyyy-MM-dd').format(endDate!)
          : null,
      'start_time': "$startTime:00",
      'end_time': "$endTime:00",
      'reason_id': reason.reasonId,
      'is_next_day': isNextDay,
      'remarks': remarks,
    };
    controller.createOvertime(data);
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.blueAccent, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextDayWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Lembur ini melewati hari berikutnya',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestHeader(DateTime start, DateTime? end, bool isNextDay) {
    final startStr = DateFormat('yyyy-MM-dd (E)').format(start);
    final endStr = isNextDay && end != null
        ? DateFormat('yyyy-MM-dd (E)').format(end)
        : null;

    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Text(
        endStr != null
            ? "OT Request untuk tanggal $startStr → $endStr"
            : "OT Request untuk tanggal $startStr",
        style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Konfirmasi Lembur",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 2,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const StepIndicator(currentStep: 2),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildRequestHeader(date, endDate, isNextDay),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _buildSummaryRow(
                              "Tanggal Mulai",
                              DateFormat('yyyy-MM-dd (E)').format(date),
                              
                            ),
                            const DummyShiftCard(),
                            if (isNextDay && endDate != null)
                              _buildSummaryRow(
                                "Tanggal Selesai",
                                DateFormat('yyyy-MM-dd (E)').format(endDate!),
                              ),
                            const Divider(),
                            _buildSummaryRow("Waktu Mulai", startTime),
                            const Divider(),
                            _buildSummaryRow("Waktu Selesai", endTime),
                            const Divider(),
                            _buildSummaryRow("Total Durasi", duration),
                            const Divider(),
                            _buildSummaryRow("Alasan", reason.name),
                            const Divider(),
                            _buildSummaryRow(
                              "Keterangan",
                              remarks.isEmpty ? "-" : remarks,
                            ),
                            if (isNextDay) _buildNextDayWarning(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 👇 Tambahin Approver Section di sini
                      const DummyApprovedSection(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Kirim",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
