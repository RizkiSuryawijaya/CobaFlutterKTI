// File: export_pdf_helper.dart
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

import '/features/overtime/helper/storage_helper.dart';
import '/features/overtime/models/ess_overtime_request.dart';

class ExportPDFHelper {
  /// Export PDF → langsung buka setelah selesai
  static Future<File> exportToPDF(List<EssOvertimeRequest> list) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Center(
            child: pw.Text(
              "Riwayat Lembur",
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headers: const [
              "Tanggal Mulai",
              "Tanggal Berakhir",
              "Jam Mulai",
              "Jam Selesai",
              "Durasi",
              "Status",
              "Alasan",
              "Catatan",
            ],
            data: list.map((e) {
              return [
                e.overtimeDate ?? "-",
                e.endDate ?? "-",
                e.startTime ?? "-",
                e.endTime ?? "-",
                (e.totalDuration != null) ? "${e.totalDuration} jam" : "-",
                e.status ?? "-",
                e.reason?.name ?? "-",
                e.remarks ?? "-",
              ];
            }).toList(),
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellPadding: const pw.EdgeInsets.symmetric(
              vertical: 6,
              horizontal: 4,
            ),
          ),
        ],
      ),
    );

    final dir = await StorageHelper.getDownloadDirectory();
    final path = "${dir.path}/riwayat_lembur.pdf";
    final file = File(path);
    await file.writeAsBytes(await pdf.save(), flush: true);

    // Buka otomatis hanya untuk export/download
    await OpenFilex.open(file.path);

    return file;
  }

  /// Buat PDF → langsung share tanpa membuka
  static Future<void> sharePDF(List<EssOvertimeRequest> list) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Center(
            child: pw.Text(
              "Riwayat Lembur",
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headers: const [
              "Tanggal Mulai",
              "Tanggal Berakhir",
              "Jam Mulai",
              "Jam Selesai",
              "Durasi",
              "Status",
              "Alasan",
              "Catatan",
            ],
            data: list.map((e) {
              return [
                e.overtimeDate ?? "-",
                e.endDate ?? "-",
                e.startTime ?? "-",
                e.endTime ?? "-",
                (e.totalDuration != null) ? "${e.totalDuration} jam" : "-",
                e.status ?? "-",
                e.reason?.name ?? "-",
                e.remarks ?? "-",
              ];
            }).toList(),
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellPadding: const pw.EdgeInsets.symmetric(
              vertical: 6,
              horizontal: 4,
            ),
          ),
        ],
      ),
    );

    final dir = await StorageHelper.getDownloadDirectory();
    final path = "${dir.path}/riwayat_lembur_share.pdf";
    final file = File(path);
    await file.writeAsBytes(await pdf.save(), flush: true);

    // **Jangan buka**, langsung share
    await Share.shareXFiles([XFile(file.path)], text: "Riwayat Lembur (PDF)");
  }
}
