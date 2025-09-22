// File: models/ess_overtime_request.dart

import 'package:intl/intl.dart';
import '../../reason/models/ess-overtime-reason.dart';
import '../../auth/models/user.dart';

class EssOvertimeRequest {
  final String? overtimeId;
  final int? nik;
  final String overtimeDate;
  final String? endDate;
  final String startTime;
  final String endTime;
  final String? status;
  final String? remarks;
  final EssReasonOT? reason;
  final User? user;
  final String? totalDuration;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isNextDay; // Properti baru untuk menyimpan status next day

  EssOvertimeRequest({
    this.overtimeId,
    this.nik,
    required this.overtimeDate,
    this.endDate,
    required this.startTime,
    required this.endTime,
    this.status,
    this.remarks,
    this.reason,
    this.user,
    this.totalDuration,
    this.createdAt,
    this.updatedAt,
    this.isNextDay, // Tambahkan di sini
  });

  factory EssOvertimeRequest.fromJson(Map<String, dynamic> json) {
    // Logika untuk menentukan `isNextDay` dari data yang diterima
    bool? isNextDayValue;
    if (json['start_time'] != null && json['end_time'] != null) {
      final start = DateFormat('HH:mm:ss').parse(json['start_time']);
      final end = DateFormat('HH:mm:ss').parse(json['end_time']);
      isNextDayValue = end.isBefore(start);
    }

    return EssOvertimeRequest(
      overtimeId: json['overtime_id'],
      nik: json['nik'],
      overtimeDate: json['overtime_date'],
      endDate: json['end_date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      status: json['status'],
      remarks: json['remarks'],
      reason: json['reason'] != null ? EssReasonOT.fromJson(json['reason']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      totalDuration: json['total_duration'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isNextDay: isNextDayValue, // Gunakan nilai yang dihitung
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overtime_date': overtimeDate,
      'start_time': startTime, // Backend Anda menerima format HH:mm:ss, jadi kirim saja
      'end_time': endTime,
      'reason_id': reason?.reasonId,
      'remarks': remarks,
      'is_next_day': isNextDay,
    
    };
  }
}