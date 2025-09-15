// File: overtime_history_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../overtime/controllers/ess_overtime_history_controller.dart';
import '../../overtime/controllers/ess_overtime_withdraw_controller.dart';
import '../../overtime/models/ess_overtime_request.dart';
import '../../overtime/pages/apply_overtime_page.dart';
import '../../overtime/pages/overtime_withdraw_page.dart';
import 'overtime_history_detail_page.dart';

class OvertimeHistoryPage extends StatefulWidget {
  const OvertimeHistoryPage({super.key});

  @override
  State<OvertimeHistoryPage> createState() => _OvertimeHistoryPageState();
}

class _OvertimeHistoryPageState extends State<OvertimeHistoryPage> {
  final EssOvertimeHistoryController controller =
      Get.put(EssOvertimeHistoryController());
  final EssOvertimeWithdrawController withdrawController =
      Get.put(EssOvertimeWithdrawController());

  String _searchText = "";
  String? _selectedYear;
  String? _selectedMonth;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    controller.fetchHistory();
  }

  List<String> _getAvailableYears() {
    final years = controller.historyRequests
        .map((e) => DateTime.tryParse(e.overtimeDate)?.year.toString())
        .where((y) => y != null)
        .cast<String>()
        .toSet()
        .toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  List<String> _getAvailableMonths() {
    final months = controller.historyRequests
        .where((e) {
          final date = DateTime.tryParse(e.overtimeDate);
          if (date == null) return false;
          return _selectedYear == null || date.year.toString() == _selectedYear;
        })
        .map((e) => DateFormat("MMMM").format(DateTime.parse(e.overtimeDate)))
        .toSet()
        .toList();
    months.sort((a, b) {
      final monthA = DateFormat("MMMM").parse(a).month;
      final monthB = DateFormat("MMMM").parse(b).month;
      return monthA.compareTo(monthB);
    });
    return months;
  }

  List<String> _getAvailableStatuses() {
    final statuses = controller.historyRequests
        .map((e) => e.status)
        .where((s) => s != null)
        .cast<String>()
        .toSet()
        .toList();
    return statuses;
  }

  List<EssOvertimeRequest> _applyFilters() {
    var list = controller.historyRequests.toList();

    if (_searchText.isNotEmpty) {
      final q = _searchText.toLowerCase();
      list = list.where((e) {
        final reason = e.reason?.name?.toLowerCase() ?? "";
        final remarks = e.remarks?.toLowerCase() ?? "";
        final status = e.status?.toLowerCase() ?? "";
        return reason.contains(q) || remarks.contains(q) || status.contains(q);
      }).toList();
    }

    if (_selectedYear != null) {
      list = list.where((e) {
        final year = DateTime.tryParse(e.overtimeDate)?.year.toString();
        return year == _selectedYear;
      }).toList();
    }
    
    if (_selectedMonth != null) {
      list = list.where((e) {
        final month = DateFormat("MMMM").format(DateTime.parse(e.overtimeDate));
        return month == _selectedMonth;
      }).toList();
    }
    
    if (_selectedStatus != null) {
      list = list.where((e) {
        return e.status == _selectedStatus;
      }).toList();
    }

    if (_startDate != null && _endDate != null) {
      list = list.where((e) {
        final date = DateTime.tryParse(e.overtimeDate);
        if (date == null) return false;
        return date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
            date.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }
    return list;
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF0D47A1),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D47A1),
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedYear = null;
        _selectedMonth = null;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _searchText = "";
      _selectedYear = null;
      _selectedMonth = null;
      _selectedStatus = null;
      _startDate = null;
      _endDate = null;
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
        title: const Text(
          "Riwayat Lembur",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task, color: Colors.white),
            onPressed: () => Get.to(() => const ApplyOvertimePage()),
            tooltip: "Ajukan Lembur",
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => Get.to(() => const OvertimeWithdrawPage()),
            tooltip: "Withdraw List",
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _resetFilters,
            tooltip: "Reset Filter",
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.blueGrey),
                  hintText: "Cari alasan, remark, atau status...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                ),
                onChanged: (value) => setState(() => _searchText = value),
              ),
            ),
            // Filter Tahun, Bulan, Status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Obx(() {
                final years = _getAvailableYears();
                final months = _getAvailableMonths();
                final statuses = _getAvailableStatuses();
                return Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: "Tahun",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        value: _selectedYear,
                        items: years
                            .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                            .toList(),
                        onChanged: (value) => setState(() => _selectedYear = value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: "Bulan",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        value: _selectedMonth,
                        items: months
                            .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                            .toList(),
                        onChanged: (value) => setState(() => _selectedMonth = value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: "Status",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        value: _selectedStatus,
                        items: statuses
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (value) => setState(() => _selectedStatus = value),
                      ),
                    ),
                  ],
                );
              }),
            ),
            // Filter Periode
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0D47A1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: Color(0xFF0D47A1)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.date_range, size: 20),
                  label: Text(
                    _startDate == null
                        ? "Pilih Periode"
                        : "${DateFormat('dd/MM/yy').format(_startDate!)} - ${DateFormat('dd/MM/yy').format(_endDate!)}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  onPressed: _pickDateRange,
                ),
              ),
            ),
            // List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = _applyFilters();
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.watch_later_outlined,
                          size: 80,
                          color: Colors.black26,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Tidak ada riwayat lembur",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final lembur = list[index];
                    
                    final startDate = DateFormat("dd MMM yyyy").format(
                      DateTime.parse(lembur.overtimeDate),
                    );
                    final endDate = lembur.endDate != null
                        ? DateFormat("dd MMM yyyy").format(DateTime.parse(lembur.endDate!))
                        : "-";

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tanggal + Status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "$startDate - $endDate",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    lembur.status ?? "Pending",
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                  backgroundColor: _getStatusColor(lembur.status),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Jam & Durasi
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Jam Mulai",
                                      style: TextStyle(fontSize: 11, color: Colors.black54),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      lembur.startTime ?? '-',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        "${lembur.totalDuration ?? '-'} jam",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54),
                                      ),
                                      const Icon(Icons.arrow_forward, size: 16, color: Colors.black54),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      "Jam Selesai",
                                      style: TextStyle(fontSize: 11, color: Colors.black54),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      lembur.endTime ?? '-',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Alasan + Tombol Detail
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Alasan: ${lembur.reason?.name ?? '-'}",
                                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D47A1),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                  ),
                                  onPressed: () {
                                    Get.to(() => OvertimeHistoryDetailPage(lembur: lembur));
                                  },
                                  child: const Text("Detail"),
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
          ],
        ),
      ),
    );
  }
}