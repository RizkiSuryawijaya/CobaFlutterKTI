// File: export_csv_helper.dart
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

import '/features/overtime/helper/storage_helper.dart';
import '/features/overtime/models/ess_overtime_request.dart';

class ExportCSVHelper {
  /// Hanya buat file CSV → kembalikan File
  static Future<File> createCSVFile(List<EssOvertimeRequest> list) async {
    final dir = await StorageHelper.getDownloadDirectory();
    final path = "${dir.path}/riwayat_lembur.csv";
    final file = File(path);

    final buf = StringBuffer();
    // 🔹 Kolom dipisah: Alasan & Remarks
    buf.writeln("Tanggal Mulai,Tanggal Berakhir,Jam Mulai,Jam Selesai,Durasi,Status,Alasan,Catatan");

    for (final e in list) {
      buf.writeln([
        e.overtimeDate ?? "-",
        e.endDate ?? "-",
        e.startTime ?? "-",
        e.endTime ?? "-",
        e.totalDuration ?? "-",
        e.status ?? "-",
        (e.reason?.name ?? "-").toString().replaceAll(",", " "),
        (e.remarks ?? "-").toString().replaceAll(",", " "),
      ].join(","));
    }

    await file.writeAsString(buf.toString(), flush: true);
    return file;
  }

  /// Export CSV → buka otomatis setelah unduh
  static Future<File> exportToCSV(List<EssOvertimeRequest> list) async {
    final file = await createCSVFile(list);
    await OpenFilex.open(file.path); // buka otomatis
    return file;
  }

  /// Share CSV → tidak membuka file
  static Future<void> shareCSV(List<EssOvertimeRequest> list) async {
    final file = await createCSVFile(list);
    await Share.shareXFiles([XFile(file.path)], text: "Riwayat Lembur (CSV)");
  }
}
