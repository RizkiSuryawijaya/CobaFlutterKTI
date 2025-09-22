import 'package:get/get.dart';

// Auth
import '../features/auth/pages/login_page.dart';
import '../features/auth/pages/admin_dashboard_page.dart';
import '../features/auth/pages/karyawan_dashboard_page.dart';

// Overtime
import '../features/overtime/controllers/ess_overtime_request_controller.dart';
import '../features/overtime/pages/overtime/overtime-list/ess_overtime_list_page.dart';
import '../features/overtime/pages/overtime/overtime-apply/ess_overtime_apply_page.dart';
import '../features/overtime/pages/overtime/overtime-list/ess_overtime_update_page.dart';
import '../features/overtime/pages/overtime/overtime-list/ess_overtime_detail_page.dart';

// Overtime History
import '../features/overtime/pages/overtime_history/ess_overtime_history_page.dart';
import '../features/overtime/pages/overtime_history/ess_overtime_history_detail_page.dart';

// Config Overtime
import '../features/overtime/pages/config-overtime-page/ess_overtime_config_list_page.dart';
import '../features/overtime/pages/config-overtime-page/ess_overtime_config_create_page.dart';
import '../features/overtime/pages/config-overtime-page/ess_overtime_config_update_page.dart';

// Reason (submodule of Overtime)
import '../features/reason/controllers/ess-overtime-reason-controller.dart';
import '../features/reason/models/ess-overtime-reason.dart';
import '../features/reason/pages/ess-overtime-reason-list-page.dart';
import '../features/reason/pages/ess-overtime-reason-create-page.dart';
import '../features/reason/pages/ess-overtime-reason-update-page.dart';

// Routes
import 'app_routes.dart';



class AppPages {
  static final routes = [

    // ================= AUTH =================
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),

    // Dashboard
    GetPage(name: AppRoutes.adminDashboard, page: () => const AdminDashboardPage()),
    GetPage(name: AppRoutes.karyawanDashboard, page: () => const EmployeeDashboardPage()),

    // ================= OVERTIME =================
    GetPage(
      name: AppRoutes.overtimeList,
      page: () => const OvertimeListPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EssOvertimeRequestController());
        Get.lazyPut(() => EssReasonOTController());
      }),
    ),

    GetPage(
      name: AppRoutes.overtimeDetail,
      page: () {
        final lembur = Get.arguments;
        return OvertimeDetailPage(overtime: lembur);
      },
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EssOvertimeRequestController());
      }),
    ),

    GetPage(
      name: AppRoutes.applyOvertime,
      page: () => const ApplyOvertimePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EssOvertimeRequestController());
        Get.lazyPut(() => EssReasonOTController());
      }),
    ),

    GetPage(
      name: AppRoutes.updateOvertime,
      page: () {
        final lembur = Get.arguments;
        return UpdateOvertimePage(lembur: lembur);
      },
    ),

    // ================= REASON =================
    GetPage(
      name: AppRoutes.createReason,
      page: () => CreateReasonPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EssReasonOTController());
      }),
    ),

    GetPage(
      name: AppRoutes.reasonList,
      page: () => const ReasonListPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EssReasonOTController());
      }),
    ),

    GetPage(
      name: AppRoutes.updateReason,
      page: () {
        final reason = Get.arguments as EssReasonOT;
        return UpdateReasonPage(reason: reason);
      },
    ),

    // ================= HISTORY =================
    GetPage(name: AppRoutes.overtimeHistory, page: () => const OvertimeHistoryPage()),

    GetPage(
      name: AppRoutes.overtimeHistoryDetail,
      page: () {
        final lembur = Get.arguments;
        return OvertimeHistoryDetailPage(lembur: lembur);
      },
    ),

    // ================= CONFIG OVERTIME =================
    GetPage(name: AppRoutes.configOvertimeList, page: () =>  ConfigListPage()),
    GetPage(name: AppRoutes.configOvertimeCreate, page: () =>  ConfigCreatePage()),
    GetPage(name: AppRoutes.configOvertimeUpdate, page: () =>  ConfigUpdatePage()),

    // ================= SPLASH =================
  ];
}
