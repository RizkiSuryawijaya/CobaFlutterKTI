import 'app_routes.dart';
import 'package:get/get.dart';
import '../features/auth/pages/login_page.dart';
import '../features/auth/pages/admin_dashboard_page.dart';
import '../features/auth/pages/karyawan_dashboard_page.dart';
import '../features/overtime/pages/overtime_list_page.dart';
import '../features/overtime/pages/apply_overtime_page.dart';
import '../features/overtime/controllers/ess_overtime_request_controller.dart';
import '../features/reason/controllers/ess_reason_ot_controller.dart';
import '../features/reason/models/ess_reason_ot.dart';
import '../features/overtime/pages/update_overtime_page.dart';
import '../features/reason/pages/reason_list_page.dart';
import '../features/reason/pages/update_reason_page.dart';
import '../features/reason/pages/create_reason_page.dart';

import '../features/overtime/pages/overtime_history_page.dart';

import '../features/overtime/pages/overtime_withdraw_page.dart';

import '../features/overtime/pages/config-overtime-page/config_list_page.dart';
import '../features/overtime/pages/config-overtime-page/config_create_page.dart';
import '../features/overtime/pages/config-overtime-page/config_update_page.dart';
import '../features/overtime/pages/overtime_history_detail_page.dart';

import '../features/overtime/pages/overtime_detail_page.dart';

class AppPages {
  static final routes = [
    // Auth
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),

    // Dashboard
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardPage(),
    ),
    GetPage(
      name: AppRoutes.karyawanDashboard,
      page: () => const EmployeeDashboardPage(),
    ),

    // Overtime
    GetPage(
      name: AppRoutes.overtimeList,
      page: () => const OvertimeListPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EssOvertimeRequestController>(
          () => EssOvertimeRequestController(),
        );
        Get.lazyPut<EssReasonOTController>(() => EssReasonOTController());
      }),
    ),

    // Overtime Detail
    GetPage(
      name: AppRoutes.overtimeDetail,
      page: () {
        final lembur = Get.arguments; // data lembur dilempar lewat arguments
        return OvertimeDetailPage(overtime: lembur);
      },
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EssOvertimeRequestController());
      }),
    ),

    // / Apply Overtime
    GetPage(
      name: AppRoutes.applyOvertime,
      page: () => const ApplyOvertimePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EssOvertimeRequestController>(
          () => EssOvertimeRequestController(),
        );
        Get.lazyPut<EssReasonOTController>(() => EssReasonOTController());
      }),
    ),
    GetPage(
      name: AppRoutes.updateOvertime,
      page: () {
        final lembur = Get.arguments;
        return UpdateOvertimePage(lembur: lembur);
      },
    ),

    // Reason
    GetPage(
      name: AppRoutes.createReason,
      page: () => CreateReasonPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EssReasonOTController>(() => EssReasonOTController());
      }),
    ),

    GetPage(
      name: AppRoutes.reasonList,
      page: () => ReasonListPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EssReasonOTController>(() => EssReasonOTController());
      }),
    ),
    GetPage(
      name: AppRoutes.updateReason,
      page: () {
        final reason = Get.arguments as EssReasonOT;
        return UpdateReasonPage(reason: reason);
      },
    ),
    // History
    GetPage(
      name: AppRoutes.overtimeHistory,
      page: () => const OvertimeHistoryPage(),
    ),

    // History Detail   ini
    GetPage(
      name: AppRoutes.overtimeHistoryDetail,
      page: () {
        final lembur = Get.arguments;
        return OvertimeHistoryDetailPage(lembur: lembur);
      },
    ),

    GetPage(
      name: AppRoutes.overtimewithdraw,
      page: () => const OvertimeWithdrawPage(),
    ),

    // Route untuk Config Overtime
    GetPage(name: AppRoutes.configOvertimeList, page: () => ConfigListPage()),
    GetPage(
      name: AppRoutes.configOvertimeCreate,
      page: () => ConfigCreatePage(),
    ),
    GetPage(
      name: AppRoutes.configOvertimeUpdate,
      page: () => ConfigUpdatePage(),
    ),
  ];
}
