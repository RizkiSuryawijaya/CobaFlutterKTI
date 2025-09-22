// File: pages/overtime_history_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/ess_overtime_history_controller.dart';
import '../../controllers/ess_overtime_withdraw_controller.dart';
import '../../models/ess_overtime_request.dart';
import '../overtime/overtime-apply/ess_overtime_apply_page.dart';
import 'ess_overtime_history_detail_page.dart';
import '../overtime/widgets/ess-overtime_card.dart';
import '../overtime/widgets/status_badge.dart';

class OvertimeHistoryPage extends StatefulWidget {
  const OvertimeHistoryPage({super.key});

  @override
  State<OvertimeHistoryPage> createState() => _OvertimeHistoryPageState();
}

class _OvertimeHistoryPageState extends State<OvertimeHistoryPage> {
  final EssOvertimeHistoryController controller = Get.put(
    EssOvertimeHistoryController(),
  );
  final EssOvertimeWithdrawController withdrawController = Get.put(
    EssOvertimeWithdrawController(),
  );

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

  Future<void> _handleRefresh() async {
    _resetFilters();
    await controller.fetchHistory();
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
    return controller.historyRequests
        .map((e) => e.status)
        .where((s) => s != null)
        .cast<String>()
        .toSet()
        .toList();
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
      list = list.where((e) => e.status == _selectedStatus).toList();
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
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _resetFilters,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🔎 Search
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
            // 🔽 Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Obx(() {
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
                        ),
                        value: _selectedYear,
                        items: _getAvailableYears()
                            .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedYear = v),
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
                        ),
                        value: _selectedMonth,
                        items: _getAvailableMonths()
                            .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedMonth = v),
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
                        ),
                        value: _selectedStatus,
                        items: _getAvailableStatuses()
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedStatus = v),
                      ),
                    ),
                  ],
                );
              }),
            ),
            // 📅 Periode filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.date_range, size: 20),
                  label: Text(
                    _startDate == null
                        ? "Pilih Periode"
                        : "${DateFormat('dd/MM/yy').format(_startDate!)} - ${DateFormat('dd/MM/yy').format(_endDate!)}",
                  ),
                  onPressed: _pickDateRange,
                ),
              ),
            ),
            // 📋 List History
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final list = _applyFilters();
                  if (list.isEmpty) {
                    return const Center(
                      child: Text(
                        "Tidak ada riwayat lembur",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final overtime = list[i];

                      return Stack(
                        children: [
                          OvertimeCard(
                            overtime: overtime,
                            showActions: false,
                            showUserInfo: false,
                            onTap: () {
                              Get.to(() => OvertimeHistoryDetailPage(lembur: overtime));
                            },
                          ),
                          Positioned(
                            top: 16,
                            right: 20,
                            child: StatusBadge(status: overtime.status),
                          ),
                        ],
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
