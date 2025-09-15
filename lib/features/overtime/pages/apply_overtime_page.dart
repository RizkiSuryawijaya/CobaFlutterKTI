// File: pages/apply_overtime_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/ess_overtime_request_controller.dart';
import '../../reason/controllers/ess_reason_ot_controller.dart';
import '../../reason/models/ess_reason_ot.dart';

class ApplyOvertimePage extends StatefulWidget {
  const ApplyOvertimePage({super.key});

  @override
  State<ApplyOvertimePage> createState() => _ApplyOvertimePageState();
}

class _ApplyOvertimePageState extends State<ApplyOvertimePage> {
  final EssOvertimeRequestController controller =
      Get.put(EssOvertimeRequestController());
  final EssReasonOTController reasonController =
      Get.put(EssReasonOTController());

  final _formKeyStep1 = GlobalKey<FormState>();

  int _currentStep = 1;

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  EssReasonOT? _selectedReason;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  bool _isNextDay = false;

  @override
  void dispose() {
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _reasonController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _updateIsNextDay() {
    if (_startTime != null && _endTime != null) {
      final startInMinutes = _startTime!.hour * 60 + _startTime!.minute;
      final endInMinutes = _endTime!.hour * 60 + _endTime!.minute;
      setState(() {
        _isNextDay = endInMinutes < startInMinutes;
      });
    }
  }

  String _calculateOvertimeDuration() {
    if (_startTime == null || _endTime == null) {
      return '0 jam';
    }

    final now = DateTime.now();
    DateTime startDateTime =
        DateTime(now.year, now.month, now.day, _startTime!.hour, _startTime!.minute);
    DateTime endDateTime =
        DateTime(now.year, now.month, now.day, _endTime!.hour, _endTime!.minute);

    if (_isNextDay) {
      endDateTime = endDateTime.add(const Duration(days: 1));
    }

    final duration = endDateTime.difference(startDateTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return '${hours}j ${minutes}m';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd (E)').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? _startTime ?? TimeOfDay.now()
          : _endTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = DateFormat('HH:mm').format(
        DateTime(0, 1, 1, picked.hour, picked.minute),
      );
      setState(() {
        if (isStart) {
          _startTime = picked;
          _startTimeController.text = formatted;
        } else {
          _endTime = picked;
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

  void _nextStep() {
    if (_currentStep == 1) {
      if (_formKeyStep1.currentState!.validate()) {
        if (_selectedDate == null ||
            _startTime == null ||
            _endTime == null ||
            _selectedReason == null) {
          Get.snackbar(
            "Error",
            "Harap lengkapi semua data yang diperlukan.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[800],
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
          return;
        }
        setState(() {
          _currentStep = 2;
        });
      }
    } else if (_currentStep == 2) {
      setState(() {
        _currentStep = 3;
      });
    } else if (_currentStep == 3) {
      _submitForm();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    } else {
      Get.back();
    }
  }

  void _submitForm() {
    final data = {
      'overtime_date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'start_time': _startTimeController.text + ':00',
      'end_time': _endTimeController.text + ':00',
      'reason_id': _selectedReason!.reasonId,
      'is_next_day': _isNextDay,
      'remarks': _remarksController.text,
    };
    controller.createOvertime(data);
  }

  Widget _buildStepIndicator() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStepItem(1, "Form"),
          _buildStepDivider(),
          _buildStepItem(2, "Konfirmasi"),
          _buildStepDivider(),
          _buildStepItem(3, "Kirim"),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String label) {
    final bool isActive = _currentStep >= step;
    final color = isActive ? Colors.blue[900] : Colors.grey[400];
    return Column(
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: color,
          child: Text(
            '$step',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider() {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: _currentStep > 1 ? Colors.blue[900] : Colors.grey[400],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Ajukan Lembur",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: _previousStep,
        ),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStepIndicator(),
            const SizedBox(height: 24),
            Expanded(
              child: IndexedStack(
                index: _currentStep - 1,
                children: [
                  _buildStep1Form(),
                  _buildStep2Confirmation(),
                  _buildStep3Remarks(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Obx(() {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : (_currentStep == 3 ? _submitForm : _nextStep),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 4,
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_currentStep == 3 ? "Kirim" : "Selanjutnya",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1Form() {
    return SingleChildScrollView(
      child: Form(
        key: _formKeyStep1,
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                      value == null || value.isEmpty ? 'Tanggal wajib diisi' : null,
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
                _buildTextFormField(
                  controller: _reasonController,
                  hintText: "-- Pilih alasan --",
                  icon: Icons.arrow_drop_down,
                  onTap: _showReasonPicker,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Alasan wajib diisi' : null,
                ),
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
              ],
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Lembur Anda sampai keesokan harinya.',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNextDayWarningSummary() {
    final nextDay = _selectedDate!.add(const Duration(days: 1));
    final formattedNextDay = DateFormat('yyyy-MM-dd (E)').format(nextDay);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lembur sampai keesokan harinya ($formattedNextDay)',
                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStep2Confirmation() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryRow("Tanggal", _dateController.text),
                  const Divider(height: 24),
                  _buildSummaryRow("Waktu Mulai", _startTimeController.text),
                  const Divider(height: 24),
                  _buildSummaryRow("Waktu Selesai", _endTimeController.text),
                  const Divider(height: 24),
                  if (_isNextDay) _buildNextDayWarningSummary(),
                  _buildSummaryRow("Total Durasi", _calculateOvertimeDuration()),
                  const Divider(height: 24),
                  _buildSummaryRow("Alasan", _selectedReason?.name ?? '-'),
                  const Divider(height: 24),
                  _buildSummaryRow("Keterangan", _remarksController.text.isEmpty ? '-' : _remarksController.text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Remarks() {
    // This step is now unused since remarks were moved to step 1.
    // It is kept for structural integrity but can be adapted or removed.
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 100, color: Colors.blue[900]),
          const SizedBox(height: 16),
          const Text(
            "Data Lengkap",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tekan Kirim untuk mengirimkan pengajuan lembur.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
        ),
      ],
    );
  }
}

class _ReasonPickerDialog extends StatefulWidget {
  final List<EssReasonOT> reasons;
  final EssReasonOT? initialSelected;

  const _ReasonPickerDialog({
    required this.reasons,
    this.initialSelected,
  });

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Alasan",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
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
                  ? const Center(child: Text("Tidak ada alasan yang ditemukan."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _filteredReasons.length,
                      itemBuilder: (context, index) {
                        final reason = _filteredReasons[index];
                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          color: reason.reasonId == widget.initialSelected?.reasonId
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Center(
                  child: Text("-- Silahkan Pilih --", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}