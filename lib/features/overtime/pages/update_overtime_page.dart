// File: pages/update_overtime_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/ess_overtime_request_controller.dart';
import '../../reason/controllers/ess_reason_ot_controller.dart';
import '../../reason/models/ess_reason_ot.dart';
import '../models/ess_overtime_request.dart';

class UpdateOvertimePage extends StatefulWidget {
  final EssOvertimeRequest lembur;

  const UpdateOvertimePage({super.key, required this.lembur});

  @override
  State<UpdateOvertimePage> createState() => _UpdateOvertimePageState();
}

class _UpdateOvertimePageState extends State<UpdateOvertimePage> {
  final EssOvertimeRequestController controller =
      Get.find<EssOvertimeRequestController>();
  final EssReasonOTController reasonController = Get.put(
    EssReasonOTController(),
  );

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _dateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _reasonController;
  late TextEditingController _remarksController;
  EssReasonOT? _selectedReason;
  bool _isNextDay = false;

  @override
  void initState() {
    super.initState();

    _dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd (E)')
          .format(DateTime.parse(widget.lembur.overtimeDate)),
    );

    _startTimeController = TextEditingController(
      text: widget.lembur.startTime.length >= 5
          ? widget.lembur.startTime.substring(0, 5)
          : widget.lembur.startTime,
    );

    _endTimeController = TextEditingController(
      text: widget.lembur.endTime.length >= 5
          ? widget.lembur.endTime.substring(0, 5)
          : widget.lembur.endTime,
    );

    _remarksController = TextEditingController(text: widget.lembur.remarks);
    _reasonController = TextEditingController();

    // Inisialisasi alasan lembur
    _initializeReason();

    // Gunakan ever untuk berjaga-jaga kalau data reasons belum siap
    ever(reasonController.reasons, (_) {
      _initializeReason();
    });

    _updateIsNextDay();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _reasonController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  /// Coba cari reason berdasarkan ID, kalau gagal fallback ke name
  void _initializeReason() {
    if (reasonController.reasons.isNotEmpty) {
      EssReasonOT? reason = reasonController.reasons.firstWhereOrNull(
        (r) =>
            r.reasonId.toString() ==
            widget.lembur.reason?.reasonId.toString(),
      );

      // fallback ke name kalau reasonId tidak ketemu
      reason ??= reasonController.reasons.firstWhereOrNull(
        (r) => r.name == widget.lembur.reason?.name,
      );

      if (reason != null) {
        _selectedReason = reason;
        _reasonController.text = reason.name;
      }
    }
  }

  void _updateIsNextDay() {
    if (_startTimeController.text.isNotEmpty &&
        _endTimeController.text.isNotEmpty) {
      try {
        final startParts = _startTimeController.text.split(':');
        final endParts = _endTimeController.text.split(':');
        final startInMinutes =
            int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
        final endInMinutes =
            int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
        setState(() {
          _isNextDay = endInMinutes < startInMinutes;
        });
      } catch (_) {
        _isNextDay = false;
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime.tryParse(widget.lembur.overtimeDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[900]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd (E)').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(
              (isStart
                      ? _startTimeController.text
                      : _endTimeController.text)
                  .split(':')[0],
            ) ??
            0,
        minute: int.tryParse(
              (isStart
                      ? _startTimeController.text
                      : _endTimeController.text)
                  .split(':')[1],
            ) ??
            0,
      ),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = DateFormat('HH:mm')
          .format(DateTime(0, 1, 1, picked.hour, picked.minute));
      setState(() {
        if (isStart) {
          _startTimeController.text = formatted;
        } else {
          _endTimeController.text = formatted;
        }
        _updateIsNextDay();
      });
    }
  }

  Future<void> _showReasonPicker() async {
    final selected = await showDialog<EssReasonOT>(
      context: context,
      builder: (context) => _ReasonPickerDialog(
        reasons: reasonController.reasons,
        initialSelected: _selectedReason,
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedReason = selected;
        _reasonController.text = selected.name;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'overtime_date': _dateController.text.substring(0, 10),
        'start_time': _startTimeController.text + ':00',
        'end_time': _endTimeController.text + ':00',
        'reason_id': _selectedReason?.reasonId,
        'is_next_day': _isNextDay,
        'remarks': _remarksController.text,
      };
      controller.updateOvertime(widget.lembur.overtimeId!, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Edit Lembur",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormTitle("Tanggal Lembur"),
                    _buildTextFormField(
                      controller: _dateController,
                      hintText: "Pilih Tanggal",
                      icon: Icons.calendar_today,
                      onTap: () => _selectDate(context),
                      validator: (value) =>
                          value == null || value.isEmpty
                              ? 'Tanggal wajib diisi'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    _buildFormTitle("Detail Waktu Lembur"),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextFormField(
                            controller: _startTimeController,
                            hintText: "Waktu Mulai",
                            icon: Icons.access_time,
                            onTap: () => _selectTime(context, true),
                            validator: (value) =>
                                value == null || value.isEmpty ? 'Wajib' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextFormField(
                            controller: _endTimeController,
                            hintText: "Waktu Selesai",
                            icon: Icons.access_time,
                            onTap: () => _selectTime(context, false),
                            validator: (value) =>
                                value == null || value.isEmpty ? 'Wajib' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isNextDay) _buildNextDayWarning(),
                    const SizedBox(height: 16),
                    _buildFormTitle("Alasan Lembur"),
                    Obx(() {
                      if (reasonController.isLoading.value &&
                          reasonController.reasons.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return _buildTextFormField(
                        controller: _reasonController,
                        hintText: "-- Pilih alasan --",
                        icon: Icons.arrow_drop_down,
                        onTap: _showReasonPicker,
                        validator: (value) =>
                            value == null || value.isEmpty
                                ? 'Alasan wajib diisi'
                                : null,
                      );
                    }),
                    const SizedBox(height: 16),
                    _buildFormTitle("Keterangan Pengajuan"),
                    TextFormField(
                      controller: _remarksController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "Masukkan keterangan di sini...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Obx(() {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : _submitForm,
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
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Perbarui Lembur",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required VoidCallback onTap,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      style: const TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue[900]!),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        suffixIcon: Icon(icon, color: Colors.grey[600]),
      ),
      validator: validator,
    );
  }

  Widget _buildNextDayWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
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
              'Lembur Anda sampai keesokan harinya.',
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
}

// Dialog picker alasan
class _ReasonPickerDialog extends StatefulWidget {
  final List<EssReasonOT> reasons;
  final EssReasonOT? initialSelected;

  const _ReasonPickerDialog({required this.reasons, this.initialSelected});

  @override
  State<_ReasonPickerDialog> createState() => _ReasonPickerDialogState();
}

class _ReasonPickerDialogState extends State<_ReasonPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<EssReasonOT> _filteredReasons = [];

  @override
  void initState() {
    super.initState();
    _filteredReasons = widget.reasons;
    _searchController.addListener(_filterReasons);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterReasons() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredReasons = widget.reasons
          .where((reason) => reason.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Alasan",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Cari alasan...",
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            Expanded(
              child: _filteredReasons.isEmpty
                  ? const Center(
                      child: Text("Tidak ada alasan yang ditemukan."),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _filteredReasons.length,
                      itemBuilder: (context, index) {
                        final reason = _filteredReasons[index];
                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: reason.reasonId ==
                                  widget.initialSelected?.reasonId
                              ? Colors.blue[100]
                              : Colors.white,
                          child: ListTile(
                            title: Text(reason.name),
                            onTap: () {
                              Navigator.pop(context, reason);
                            },
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "-- Silahkan Pilih --",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
