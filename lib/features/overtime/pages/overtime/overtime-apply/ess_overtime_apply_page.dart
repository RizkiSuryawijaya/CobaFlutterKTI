import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/ess_overtime_request_controller.dart';
import '../../../../reason/controllers/ess-overtime-reason-controller.dart';
import '../../../../reason/models/ess-overtime-reason.dart';

import '../widgets/ess_overtime_step_indicator.dart';
import '../dialogs/ess_overtime_reason_picker_dialog.dart';
import 'ess_overtime_confirm_page.dart';


import '../../dummyapproved/dummy_shift_page.dart';

class ApplyOvertimePage extends StatefulWidget {
  const ApplyOvertimePage({super.key});

  @override
  State<ApplyOvertimePage> createState() => _ApplyOvertimeFormPageState();
}

class _ApplyOvertimeFormPageState extends State<ApplyOvertimePage> {
  late final EssOvertimeRequestController controller;
  late final EssReasonOTController reasonController;

  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  EssReasonOT? _selectedReason;

  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _reasonController = TextEditingController();
  final _remarksController = TextEditingController();

  bool _isNextDay = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<EssOvertimeRequestController>();
    reasonController = Get.find<EssReasonOTController>();
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

  void _updateIsNextDay() {
    if (_startTime != null && _endTime != null) {
      final start = _startTime!.hour * 60 + _startTime!.minute;
      final end = _endTime!.hour * 60 + _endTime!.minute;
      setState(() => _isNextDay = end < start);
    }
  }

  String _calculateOvertimeDuration() {
    if (_startTime == null || _endTime == null) return '0j 0m';
    final now = DateTime.now();
    DateTime start = DateTime(
      now.year,
      now.month,
      now.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    DateTime end = DateTime(
      now.year,
      now.month,
      now.day,
      _endTime!.hour,
      _endTime!.minute,
    );
    if (_isNextDay) end = end.add(const Duration(days: 1));
    final diff = end.difference(start);
    return '${diff.inHours}j ${diff.inMinutes.remainder(60)}m';
  }

  DateTime? get _endDate {
    if (_selectedDate == null) return null;
    return _isNextDay
        ? _selectedDate!.add(const Duration(days: 1))
        : _selectedDate;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.blue[900]!,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd (E)').format(picked);
      });
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? _startTime ?? TimeOfDay.now()
          : _endTime ?? TimeOfDay.now(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      final formatted = DateFormat(
        'HH:mm',
      ).format(DateTime(0, 1, 1, picked.hour, picked.minute));
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
      builder: (context) => ReasonPickerDialog(
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

  void _goToConfirmation() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null ||
          _startTime == null ||
          _endTime == null ||
          _selectedReason == null) {
        Get.snackbar(
          "Error",
          "Harap lengkapi semua data!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[800],
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      Get.to(
        () => ApplyOvertimeConfirmPage(
          date: _selectedDate!,
          endDate: _endDate,
          startTime: _startTimeController.text,
          endTime: _endTimeController.text,
          duration: _calculateOvertimeDuration(),
          reason: _selectedReason!,
          remarks: _remarksController.text,
          isNextDay: _isNextDay,
        ),
      );
    }
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    String hintText,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: ctrl,
            readOnly: true,
            onTap: onTap,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[400]),
              suffixIcon: Icon(icon, color: Colors.grey[600]),
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
                borderSide: BorderSide(color: Colors.blue[900]!, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
          ),
        ],
      ),
    );
  }

  Widget _buildNextDayWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
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
              'Lembur sampai keesokan hari',
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
          "Ajukan Lembur",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, 
          ),
        ),

        centerTitle: true,
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 2,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const StepIndicator(currentStep: 1),
            
              if (_selectedDate != null)
                _buildRequestHeader(_selectedDate!, _endDate, _isNextDay),
               
           
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildField(
                      _dateController,
                      "Tanggal Lembur",
                      "Pilih Tanggal",
                      Icons.calendar_today,
                      _selectDate,
                      

                    ),
                     const DummyShiftCard(),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            _startTimeController,
                            "Waktu Mulai",
                            "Mulai",
                            Icons.access_time,
                            () => _selectTime(true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildField(
                            _endTimeController,
                            "Waktu Selesai",
                            "Selesai",
                            Icons.access_time,
                            () => _selectTime(false),
                          ),
                        ),
                      ],
                    ),
                    if (_isNextDay) _buildNextDayWarning(),
                    _buildField(
                      _reasonController,
                      "Alasan Lembur",
                      "Pilih alasan",
                      Icons.arrow_drop_down,
                      _showReasonPicker,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _remarksController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Keterangan",
                        hintText: "Tambahkan keterangan tambahan...",
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
                          borderSide: BorderSide(
                            color: Colors.blue[900]!,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _goToConfirmation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    "Lanjut ke Konfirmasi",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
