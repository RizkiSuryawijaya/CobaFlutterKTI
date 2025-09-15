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


  // Withdraw Overtime
  static const overtimewithdraw = '/overtime-withdraw'; 



  // Tambahan untuk Config Overtime

  static const configOvertimeList = '/config-overtime';
  static const configOvertimeCreate = '/config-overtime/create';
  static const configOvertimeUpdate = '/config-overtime/update';



}
