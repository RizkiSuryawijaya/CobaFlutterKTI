// 📂 pages/employee_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import '../controllers/auth_controller.dart';
import '../../overtime/controllers/ess_overtime_total_controller.dart';
import '../../overtime/controllers/ess_overtime_summary_controller.dart';
import '../../../routes/app_routes.dart';

class EmployeeDashboardPage extends StatefulWidget {
  const EmployeeDashboardPage({super.key});

  @override
  State<EmployeeDashboardPage> createState() => _EmployeeDashboardPageState();
}

class _EmployeeDashboardPageState extends State<EmployeeDashboardPage> {
  // Inisialisasi controller hanya sekali di state
  final AuthController _authController = Get.find();
  final EssOvertimeTotalController _overtimeTotalController =
      Get.put(EssOvertimeTotalController());
  final OvertimeSummaryController _summaryController =
      Get.put(OvertimeSummaryController());

  @override
  void initState() {
    super.initState();
    // Memuat data saat halaman pertama kali dibuat
    _overtimeTotalController.fetchTotalOvertime();
    _summaryController.fetchUserSummary();
  }

  // Fungsi untuk memuat ulang data saat pull-to-refresh
  Future<void> _refreshData() async {
    await _overtimeTotalController.fetchTotalOvertime();
    await _summaryController.fetchUserSummary();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authController.currentUser.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text(
          "Dasbor Karyawan",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1976D2),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _authController.logout(),
          ),
        ],
        elevation: 0,
      ),
      // Menggunakan RefreshIndicator untuk fitur pull-to-refresh
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              _buildHeader(user),
              const SizedBox(height: 20),
              Obx(() => _buildStats(_overtimeTotalController)),
              const SizedBox(height: 20),
              Obx(() => _buildSummaryStatus(_summaryController)),
              const SizedBox(height: 20),
              _buildMenuGrid(),
              const SizedBox(height: 20),
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== WIDGET HEADER ====================
  Widget _buildHeader(user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1976D2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 36,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'Karyawan',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Jabatan: ${user?.role ?? '-'}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== WIDGET STATISTIK ====================
  Widget _buildStats(EssOvertimeTotalController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Lembur Anda Bulan Ini",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : Text(
                          controller.totalFormatted,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                ],
              ),
              const Icon(
                Icons.access_time_filled,
                size: 40,
                color: Color(0xFF1976D2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== WIDGET RINGKASAN STATUS ====================
  Widget _buildSummaryStatus(OvertimeSummaryController controller) {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    final summary = controller.summary.value;
    if (summary == null) {
      return const Text("Ringkasan status tidak tersedia");
    }

    // Mengganti label status ke Bahasa Indonesia
    final Map<String, int> summaryData = {
      'Disetujui': summary.approved,
      'Menunggu': summary.pending,
      'Ditolak': summary.rejected,
      'Dibatalkan': summary.cancel,
      'Ditarik': summary.withdraw,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ringkasan Status Lembur Anda",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: summaryData.entries.map((e) {
                      final sectionColor = _statusColor(e.key);
                      return PieChartSectionData(
                        value: e.value.toDouble(),
                        title: e.value > 0 ? "${e.value}" : "",
                        color: sectionColor,
                        radius: 60,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                    sectionsSpace: 3,
                    centerSpaceRadius: 50,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: summaryData.entries.map((e) {
                  final sectionColor = _statusColor(e.key);
                  return _StatusLegend(
                    label: e.key,
                    count: e.value,
                    color: sectionColor,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk menentukan warna berdasarkan status
  static Color _statusColor(String status) {
    switch (status) {
      case 'Disetujui':
        return const Color(0xFF4CAF50);
      case 'Menunggu':
        return const Color(0xFFFFA000);
      case 'Ditolak':
        return const Color(0xFFD32F2F);
      case 'Dibatalkan':
        return const Color(0xFF9E9E9E);
      case 'Ditarik':
        return const Color(0xFF546E7A);
      default:
        return const Color(0xFF2196F3);
    }
  }

  // ==================== WIDGET INFO CARD ====================
  Widget _buildInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
        color: const Color(0xFFE3F2FD),
        child: const Padding(
          padding: EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF1976D2), size: 30),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Ajukan lembur sesuai kebutuhan. Pantau status pengajuan Anda secara berkala.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== WIDGET MENU GRID ====================
  Widget _buildMenuGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        children: [
          _MenuCard(
            title: "Riwayat Lembur",
            icon: Icons.history,
            color: const Color(0xFF29B6F6),
            onTap: () => Get.toNamed(AppRoutes.overtimeHistory),
          ),
          _MenuCard(
            title: "Ajukan Lembur",
            icon: Icons.add_circle,
            color: const Color(0xFF4CAF50),
            onTap: () => Get.toNamed(AppRoutes.applyOvertime),
          ),
        ],
      ),
    );
  }
}

// ==================== STAT CARD ====================
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF1976D2), size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ==================== MENU CARD ====================
class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: color,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== STATUS LEGEND ====================
class _StatusLegend extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatusLegend({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "$label ($count)",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}