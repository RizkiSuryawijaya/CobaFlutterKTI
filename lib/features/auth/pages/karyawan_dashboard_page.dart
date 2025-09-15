// 📂 pages/employee_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import '../controllers/auth_controller.dart';
import '../../overtime/controllers/ess_overtime_total_controller.dart';
import '../../overtime/controllers/overtime_summary_controller.dart';
import '../../../routes/app_routes.dart';
import '';

class EmployeeDashboardPage extends StatelessWidget {
  const EmployeeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final overtimeTotalController = Get.put(EssOvertimeTotalController());
    final summaryController = Get.put(OvertimeSummaryController());

    final user = authController.currentUser.value;

    // 🔹 Fetch summary khusus user
    summaryController.fetchUserSummary();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Employee Dashboard"),
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            _buildHeader(user),
            const SizedBox(height: 24),
            Obx(() => _buildStats(overtimeTotalController)),
            const SizedBox(height: 24),
            Obx(() => _buildSummaryStatus(summaryController)),
            const SizedBox(height: 24),
            _buildInfoCard(),
            const SizedBox(height: 28),
            _buildMenuGrid(),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 48,
              color: Colors.blue[900],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'Employee',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Role: ${user?.role ?? '-'}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ================= STATISTIK =================
  Widget _buildStats(EssOvertimeTotalController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _StatCard(
              title: 'Total Lembur Anda Bulan Ini',
              value: controller.isLoading.value ? "..." : controller.totalFormatted,
              icon: Icons.access_time,
            ),
          ),
        ],
      ),
    );
  }

  // ================= SUMMARY STATUS =================
  Widget _buildSummaryStatus(OvertimeSummaryController controller) {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    final summary = controller.summary.value;
    if (summary == null) {
      return const Text("Summary status tidak tersedia");
    }

    final Map<String, int> summaryData = {
      'Approved': summary.approved,
      'Pending': summary.pending,
      'Rejected': summary.rejected,
      'Cancel': summary.cancel,
      'Withdraw': summary.withdraw,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Summary Status Lembur Anda",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // 🔹 Pie Chart
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
                        radius: 50,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 🔹 Legends
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatusChip(label: "Approved", count: summary.approved, color: Colors.green),
                  _StatusChip(label: "Pending", count: summary.pending, color: Colors.orange),
                  _StatusChip(label: "Rejected", count: summary.rejected, color: Colors.red),
                  _StatusChip(label: "Cancel", count: summary.cancel, color: Colors.grey),
                  _StatusChip(label: "Withdraw", count: summary.withdraw, color: Colors.blueGrey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Warna status
  static Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Rejected':
        return Colors.red;
      case 'Cancel':
        return Colors.grey;
      case 'Withdraw':
        return Colors.blueGrey;
      default:
        return Colors.blue;
    }
  }

  // ================= INFO CARD =================
  Widget _buildInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Ajukan lembur sesuai kebutuhan.\nPantau status pengajuan Anda secara berkala.',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }

  // ================= MENU GRID =================
  Widget _buildMenuGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        children: [
          _MenuCard(
            title: "Overtime History",
            icon: Icons.history,
            color: Colors.blue[700]!,
            onTap: () => Get.toNamed(AppRoutes.overtimeHistory),
          ),
          _MenuCard(
            title: "Ajukan Lembur",
            icon: Icons.add,
            color: Colors.green[700]!,
            onTap: () => Get.toNamed(AppRoutes.applyOvertime),
          ),
        ],
      ),
    );
  }
}

// ================= STAT CARD =================
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
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blue[900], size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ================= MENU CARD =================
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
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.9), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
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

// ================= STATUS CHIP =================
class _StatusChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text("$label: $count"),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }
}
