// file: lib/pages/config_create_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/ess_overtime_config_time_controller.dart';
import '../../models/ess_overtime_config.dart';

class ConfigCreatePage extends StatelessWidget {
  final controller = Get.find<ConfigOvertimeController>();
  final _formKey = GlobalKey<FormState>();
  final _hourCtrl = TextEditingController();
  final _minuteCtrl = TextEditingController();
  final _restCtrl = TextEditingController();

  ConfigCreatePage({super.key});

  // Konversi jam + menit ke double jam
  double _convertHourMinuteToDouble(String hourText, String minuteText) {
    final hours = int.tryParse(hourText) ?? 0;
    // Otomatis atur menit ke 0 jika string kosong
    final minutes = int.tryParse(minuteText.isEmpty ? '0' : minuteText) ?? 0;
    return hours + minutes / 60;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Tambah Pengaturan Lembur",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Judul untuk input gabungan jam dan menit
              _buildInputTitle(
                label: "Batas Lembur Bulanan",
                icon: Icons.access_time,
              ),
              const SizedBox(height: 12),

              // Input jam dan menit dalam satu baris
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hourCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _buildInputDecoration(
                        label: "Jam",
                        hint: "Contoh: 56",
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Jam wajib diisi";
                        if (int.tryParse(v) == null) return "Masukkan angka valid";
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _minuteCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _buildInputDecoration(
                        label: "Menit (Opsional)",
                        hint: "Contoh: 30",
                      ),
                      validator: (v) {
                        if (v != null && v.isNotEmpty) {
                          final minutes = int.tryParse(v);
                          if (minutes == null || minutes < 0 || minutes > 59) {
                            return "Menit 0-59";
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Input waktu istirahat
              _buildInputField(
                controller: _restCtrl,
                label: "Waktu Istirahat (Menit)",
                hint: "Contoh: 30",
                icon: Icons.free_breakfast,
                isOptional: true,
              ),
              const SizedBox(height: 40),

              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final config = EssConfigOvertime(
                      id: '',
                      monthlyTotalDurationHours: _convertHourMinuteToDouble(
                        _hourCtrl.text,
                        _minuteCtrl.text,
                      ),
                      restTimeMinutes: _restCtrl.text.isEmpty ? 0 : int.parse(_restCtrl.text),
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );
                    controller.createConfig(config);
                  }
                },
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                label: const Text(
                  "Tambah Pengaturan",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pembantu untuk judul input field
  Widget _buildInputTitle({required String label, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade700),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // Widget pembantu untuk input field tunggal (seperti waktu istirahat)
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade300, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        prefixIcon: Icon(icon, color: Colors.blue.shade700),
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: Colors.grey.shade700),
        hintStyle: TextStyle(color: Colors.grey.shade500),
      ),
      validator: (v) {
        if (isOptional && (v == null || v.isEmpty)) return null;
        if (v == null || v.isEmpty) return "$label wajib diisi";
        if (int.tryParse(v) == null) return "Masukkan angka yang valid";
        return null;
      },
    );
  }

  // Widget pembantu untuk dekorasi input field dalam Row
  InputDecoration _buildInputDecoration({
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.blue.shade300, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(color: Colors.grey.shade700),
      hintStyle: TextStyle(color: Colors.grey.shade500),
    );
  }
}
