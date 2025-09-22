// File: pages/overtime_list_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/ess_overtime_request_controller.dart';
import '../../../models/ess_overtime_request.dart';
import '../../../../../routes/app_routes.dart';
import '../widgets/ess-overtime_card.dart';
import '../widgets/status_badge.dart';

class OvertimeListPage extends StatefulWidget {
  const OvertimeListPage({super.key});

  @override
  State<OvertimeListPage> createState() => _OvertimeListPageState();
}

class _OvertimeListPageState extends State<OvertimeListPage> {
  final EssOvertimeRequestController controller =
      Get.put(EssOvertimeRequestController());

  String _searchText = "";
  String? _selectedYear;
  String? _selectedMonth;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  String _nikFilter = "";

  @override
  void initState() {
    super.initState();
    controller.fetchOvertimeRequests();
  }

  Future<void> _onRefresh() async {
    await controller.fetchOvertimeRequests();
  }

  List<String> _getAvailableYears() {
    final years = controller.overtimeRequests
        .map((e) => DateTime.tryParse(e.overtimeDate)?.year.toString())
        .where((y) => y != null)
        .cast<String>()
        .toSet()
        .toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  List<String> _getAvailableMonths() {
    final months = controller.overtimeRequests
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
    return controller.overtimeRequests
        .map((e) => e.status)
        .where((s) => s != null)
        .cast<String>()
        .toSet()
        .toList();
  }

  List<EssOvertimeRequest> _applyFilters() {
    var list = controller.overtimeRequests.toList();

    if (_searchText.isNotEmpty) {
      final q = _searchText.toLowerCase();
      list = list.where((e) {
        final reason = e.reason?.name?.toLowerCase() ?? "";
        final remarks = e.remarks?.toLowerCase() ?? "";
        final status = e.status?.toLowerCase() ?? "";
        return reason.contains(q) || remarks.contains(q) || status.contains(q);
      }).toList();
    }

    if (_nikFilter.isNotEmpty) {
      final q = _nikFilter.toLowerCase();
      list = list.where((e) {
        final nik = e.user?.nik?.toString().toLowerCase() ?? "";
        return nik.contains(q);
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
      _nikFilter = "";
      _selectedYear = null;
      _selectedMonth = null;
      _selectedStatus = null;
      _startDate = null;
      _endDate = null;
    });
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, String overtimeId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus pengajuan ini?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            onPressed: () {
              controller.deleteOvertime(overtimeId);
              Navigator.of(context).pop();
            },
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
          "Daftar Pengajuan Overtime",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        actions: [
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
            // 🔹 Filter NIK
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person, color: Colors.blueGrey),
                  hintText: "Cari berdasarkan NIK...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() => _nikFilter = value),
              ),
            ),

            // 🔹 Filter Dropdown + Periode
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Obx(() {
                final years = _getAvailableYears();
                final months = _getAvailableMonths();
                final statuses = _getAvailableStatuses();

                return Column(
                  children: [
                    Row(
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
                            items: years
                                .map((y) =>
                                    DropdownMenuItem(value: y, child: Text(y)))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedYear = value),
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
                            items: months
                                .map((m) =>
                                    DropdownMenuItem(value: m, child: Text(m)))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedMonth = value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
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
                            items: statuses
                                .map((s) =>
                                    DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedStatus = value),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.date_range),
                            label: Text(
                              _startDate == null
                                  ? "Pilih Periode"
                                  : "${DateFormat('dd/MM/yy').format(_startDate!)} - ${DateFormat('dd/MM/yy').format(_endDate!)}",
                            ),
                            onPressed: _pickDateRange,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),

            // 🔹 List Data
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = _applyFilters();
                if (list.isEmpty) {
                  return const Center(
                    child: Text("Tidak ada data pengajuan lembur"),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final overtime = list[index];

                      return Stack(
                        children: [
                          OvertimeCard(
                            overtime: overtime,
                            onTap: () => Get.toNamed(
                              AppRoutes.overtimeDetail,
                              arguments: overtime,
                            ),
                            onEdit: () => Get.toNamed(
                              AppRoutes.updateOvertime,
                              arguments: overtime,
                            ),
                            onDelete: () {
                              if (overtime.overtimeId != null) {
                                _showDeleteConfirmationDialog(
                                  context,
                                  overtime.overtimeId!,
                                );
                              }
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
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
