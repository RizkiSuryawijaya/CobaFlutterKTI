abstract class AppRoutes {
  // Auth
  static const login = '/';

  // Dashboard
  static const adminDashboard = '/admin';
  static const karyawanDashboard = '/karyawan';

  // Overtime
  static const overtimeList = '/listlembur';
  static const overtimeDetail = '/detail-lembur';

  
  static const applyOvertime = '/apply-overtime';
  static const updateOvertime = '/update-overtime';

  // History
  static const overtimeHistory = '/overtime-history';
  static const overtimeHistoryDetail = '/overtime-history-detail';

  // Reason
  static const  createReason = '/reason-create';
  static const reasonList = '/reason-list';
  static const updateReason = '/reason-update';





  // Tambahan untuk Config Overtime

  static const configMenu = '/config-menu';


  static const configOvertimeTimeList = '/config-overtime';
  static const configOvertimeTimeCreate = '/config-overtime/create';
  static const configOvertimeTimeUpdate = '/config-overtime/update';


   static const splash = '/splash';

}
