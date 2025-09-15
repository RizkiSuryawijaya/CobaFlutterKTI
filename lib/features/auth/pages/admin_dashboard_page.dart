import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart'; // 🔹 Import library untuk pie chart
import '../controllers/auth_controller.dart';
import '../../overtime/controllers/ess_overtime_total_controller.dart';
import '../../overtime/controllers/overtime_summary_controller.dart';
import '../../../routes/app_routes.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final overtimeTotalController = Get.put(EssOvertimeTotalController());
    final summaryController = Get.put(OvertimeSummaryController());
    final user = authController.currentUser.value;

    // 🔹 fetch summary admin (status lembur semua user)
    summaryController.fetchAdminSummary(authController.token.value);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
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
            // 🔹 HEADER
            _buildHeader(user),

            const SizedBox(height: 24),

            // 🔹 STATISTIK (total lembur)
            Obx(() => _buildStats(overtimeTotalController)),

            const SizedBox(height: 24),

            // 🔹 SUMMARY STATUS (dengan pie chart)
            Obx(() => _buildSummaryStatus(summaryController)),

            const SizedBox(height: 24),

            // 🔹 INFO
            _buildInfoCard(),

            const SizedBox(height: 28),

            // 🔹 MENU GRID
            _buildMenuGrid(),
          ],
        ),
      ),
    );
  }

  // =================== WIDGET HEADER ===================
  Widget _buildHeader(user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
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
              Icons.admin_panel_settings,
              size: 48,
              color: Colors.blue[900],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'Admin',
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

  // =================== WIDGET STATISTIK ===================
  Widget _buildStats(EssOvertimeTotalController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _StatCard(
              title: 'Total Lembur Anda Bulan ini',
              value: controller.isLoading.value
                  ? "..."
                  : controller.totalFormatted,
              icon: Icons.access_time,
            ),
          ),
        ],
      ),
    );
  }

  // =================== WIDGET SUMMARY STATUS (dengan Pie Chart) ===================
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
              const Text("Summary Status Lembur (All Users)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // 🔹 Pie Chart
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: summaryData.entries.map((e) {
                      Color sectionColor;
                      switch (e.key) {
                        case 'Approved':
                          sectionColor = Colors.green;
                          break;
                        case 'Pending':
                          sectionColor = Colors.orange;
                          break;
                        case 'Rejected':
                          sectionColor = Colors.red;
                          break;
                        case 'Cancel':
                          sectionColor = Colors.grey;
                          break;
                        case 'Withdraw':
                          sectionColor = Colors.blueGrey;
                          break;
                        default:
                          sectionColor = Colors.blue;
                          break;
                      }
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
              
              // 🔹 Legends (Chip)
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

  // =================== WIDGET INFO CARD ===================
  Widget _buildInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Kelola data karyawan dan lembur dengan teliti.\n'
            'Pastikan semua data valid dan selalu terupdate.',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }

  // =================== WIDGET MENU GRID ===================
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
            title: "List Lembur",
            icon: Icons.list_alt,
            color: Colors.blue[900]!,
            onTap: () => Get.toNamed(AppRoutes.overtimeList),
          ),
          _MenuCard(
            title: "Reason OT",
            icon: Icons.edit_note,
            color: Colors.blue[700]!,
            onTap: () => Get.toNamed(AppRoutes.reasonList),
          ),
          _MenuCard(
            title: "OT History",
            icon: Icons.history,
            color: Colors.blue[800]!,
            onTap: () => Get.toNamed(AppRoutes.overtimeHistory),
          ),
          _MenuCard(
            title: "Pengaturan",
            icon: Icons.settings,
            color: const Color.fromRGBO(66, 66, 66, 1)!,
            onTap: () => Get.toNamed(AppRoutes.configOvertimeList),
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

// =================== STAT CARD ===================
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
            ),
          ],
        ),
      ),
    );
  }
}

// =================== MENU CARD ===================
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

// =================== STATUS CHIP (baru) ===================
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