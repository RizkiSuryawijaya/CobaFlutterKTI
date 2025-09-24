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
  final AuthController _authController = Get.find();
  final EssOvertimeTotalController _overtimeTotalController = Get.put(
    EssOvertimeTotalController(),
  );
  final OvertimeSummaryController _summaryController = Get.put(
    OvertimeSummaryController(),
  );

  @override
  void initState() {
    super.initState();
    _overtimeTotalController.fetchTotalOvertime();
    _summaryController.fetchUserSummary();
  }

  Future<void> _refreshData() async {
    await _overtimeTotalController.fetchTotalOvertime();
    await _summaryController.fetchUserSummary();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authController.currentUser.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC), // Warna latar belakang diserasi
      appBar: AppBar(
        title: const Text(
          "Dasbor Karyawan",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1C2B5D), // Warna AppBar diserasi
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _authController.logout(),
          ),
        ],
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: const Color(0xFF1C2B5D), // Warna refresh indicator diserasi
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              _buildHeader(user),
              const SizedBox(height: 20),
              Obx(
                () => _buildStatsCard(_overtimeTotalController),
              ), // Ganti nama fungsi
              const SizedBox(height: 20),
              Obx(
                () => _buildSummaryStatusCard(_summaryController),
              ), // Ganti nama fungsi
              const SizedBox(height: 20),
              _buildMenuGrid(),
              const SizedBox(height: 20),
              _buildInfoAlert(), // Ganti nama fungsi
              const SizedBox(height: 20),
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
      padding: const EdgeInsets.symmetric(
        vertical: 32,
        horizontal: 24,
      ), // Padding diserasi
      decoration: const BoxDecoration(
        color: Color(0xFF1C2B5D), // Warna header diserasi
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15, // Blur diserasi
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32, // Ukuran avatar diserasi
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 40, // Ukuran ikon diserasi
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Halo, ${user?.name ?? 'Karyawan'}!",
                    style: const TextStyle(
                      fontSize: 24, // Ukuran font diserasi
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

  // --- WIDGET CARD STATISTIK DISERASI ---
  Widget _buildStatsCard(EssOvertimeTotalController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 8,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: const LinearGradient(
              colors: [Color(0xFF425A8B), Color(0xFF1C2B5D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
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
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    controller.isLoading.value
                        ? const SizedBox(
                            height: 30,
                            width: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            controller.totalFormatted,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ],
                ),
                const Icon(
                  Icons.access_time_filled,
                  size: 50,
                  color: Colors.white54,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET CARD RINGKASAN STATUS DISERASI ---
  Widget _buildSummaryStatusCard(OvertimeSummaryController controller) {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    final summary = controller.summary.value;
    if (summary == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "Ringkasan status tidak tersedia",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final Map<String, int> summaryData = {
      'Disetujui': summary.approved,
      'Menunggu': summary.pending,
      'Ditolak': summary.rejected,
      'Dibatalkan': summary.cancel,
      'Ditarik': summary.withdraw,
    };

    final totalRequests =
        summary.approved +
        summary.pending +
        summary.rejected +
        summary.cancel +
        summary.withdraw;
    if (totalRequests == 0) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "Belum ada data lembur yang diajukan bulan ini.",
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: const Text(
                  "Ringkasan Status Lembur Anda",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24), // Jarak diserasi
              Center(
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: summaryData.entries.map((e) {
                        Color sectionColor;
                        switch (e.key) {
                          case 'Disetujui':
                            sectionColor = const Color(0xFF4CAF50);
                            break;
                          case 'Menunggu':
                            sectionColor = const Color(0xFFFFA000);
                            break;
                          case 'Ditolak':
                            sectionColor = const Color(0xFFD32F2F);
                            break;
                          case 'Dibatalkan':
                            sectionColor = const Color(0xFF9E9E9E);
                            break;
                          case 'Ditarik':
                            sectionColor = const Color(0xFF546E7A);
                            break;
                          default:
                            sectionColor = const Color(0xFF2196F3);
                            break;
                        }
                        return PieChartSectionData(
                          value: e.value.toDouble(),
                          title: e.value > 0 ? "${e.value}" : "",
                          color: sectionColor,
                          radius: 70, // Ukuran radius diserasi
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        );
                      }).toList(),
                      sectionsSpace: 4, // Jarak antar potongan diserasi
                      centerSpaceRadius: 60, // Ruang tengah diserasi
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20, // Spasi diserasi
                  runSpacing: 16, // Spasi diserasi
                  children: summaryData.entries.map((e) {
                    Color sectionColor;
                    switch (e.key) {
                      case 'Disetujui':
                        sectionColor = const Color(0xFF4CAF50);
                        break;
                      case 'Menunggu':
                        sectionColor = const Color(0xFFFFA000);
                        break;
                      case 'Ditolak':
                        sectionColor = const Color(0xFFD32F2F);
                        break;
                      case 'Dibatalkan':
                        sectionColor = const Color(0xFF9E9E9E);
                        break;
                      case 'Ditarik':
                        sectionColor = const Color(0xFF546E7A);
                        break;
                      default:
                        sectionColor = const Color(0xFF2196F3);
                        break;
                    }
                    return _StatusLegend(
                      label: e.key,
                      count: e.value,
                      color: sectionColor,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET GRID MENU DISERASI ---
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
            color: const Color(0xFF388E3C), // Warna diserasi
            onTap: () => Get.toNamed(AppRoutes.overtimeHistory),
          ),
          _MenuCard(
            title: "Ajukan Lembur",
            icon: Icons.add_circle,
            color: const Color(0xFF0288D1), // Warna diserasi
            onTap: () => Get.toNamed(AppRoutes.applyOvertime),
          ),
          // Tambahkan Menu Card lainnya sesuai kebutuhan
        ],
      ),
    );
  }

  // --- WIDGET INFO CARD DISERASI ---
  Widget _buildInfoAlert() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        color: const Color(0xFFE3F2FD),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF1C2B5D),
                size: 30,
              ), // Warna ikon diserasi
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Ajukan lembur sesuai kebutuhan. Pantau status pengajuan Anda secara berkala.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[900], // Warna teks diserasi
                    fontWeight: FontWeight.w500,
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

// =================== KOMPONEN KARTU MENU DISERASI ===================
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
    return InkWell(
      onTap: onTap,
      splashColor: Colors.white.withOpacity(0.3),
      borderRadius: BorderRadius.circular(20),
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

// =================== KOMPONEN LEGEND STATUS DISERASI ===================
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
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
