import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class StorageHelper {
  /// Minta izin storage yang sesuai versi Android.
  /// iOS otomatis true (nggak butuh permission untuk Documents dir).
  static Future<bool> requestStoragePermission() async {
    if (Platform.isIOS) return true;

    // Sudah ada izin?
    if (await Permission.manageExternalStorage.isGranted ||
        await Permission.storage.isGranted) {
      return true;
    }

    // Coba minta MANAGE_EXTERNAL_STORAGE (Android 11+)
    final manage = await Permission.manageExternalStorage.request();
    if (manage.isGranted) return true;

    // Fallback: minta storage biasa (Android 10-)
    final legacy = await Permission.storage.request();
    return legacy.isGranted;
  }

  /// Coba dapatkan folder Download (atau fallback yang bisa ditulis).
  ///
  /// Logika:
  /// - Android: coba /storage/emulated/0/Download (kalau ada akses)
  ///   Kalau gagal/ga ada → bikin "Download" di root external (sebelum /Android)
  ///   Kalau masih gagal → fallback ke getExternalStorageDirectory()
  /// - iOS: pakai Documents dir.
  static Future<Directory> getDownloadDirectory() async {
    // Pastikan izin
    final ok = await requestStoragePermission();
    if (!ok) {
      throw Exception("Izin penyimpanan ditolak");
    }

    if (Platform.isAndroid) {
      // 1) Coba folder Download standar
      final dl = Directory("/storage/emulated/0/Download");
      try {
        if (await dl.exists()) {
          // tes tulis
          final test = File("${dl.path}/.perm_test");
          await test.writeAsString("ok", flush: true);
          await test.delete();
          return dl;
        }
      } catch (_) {
        // ignore, lanjut fallback
      }

      // 2) Bangun path Download sebelum /Android dari getExternalStorageDirectory
      try {
        final ext = await getExternalStorageDirectory(); // e.g. /storage/emulated/0/Android/data/<app>/files
        if (ext != null) {
          String newPath = "";
          final parts = ext.path.split("/");
          for (int i = 1; i < parts.length; i++) {
            final folder = parts[i];
            if (folder == "Android") break; // stop sebelum /Android
            newPath += "/$folder";
          }
          newPath += "/Download";
          final alt = Directory(newPath);
          if (!await alt.exists()) {
            await alt.create(recursive: true);
          }
          // Tes tulis
          final test = File("${alt.path}/.perm_test");
          await test.writeAsString("ok", flush: true);
          await test.delete();
          return alt;
        }
      } catch (_) {
        // ignore, lanjut fallback terakhir
      }

      // 3) Fallback terakhir: folder app sendiri
      final last = await getExternalStorageDirectory();
      if (last != null) {
        if (!await last.exists()) {
          await last.create(recursive: true);
        }
        return last;
      }

      throw Exception("Gagal mendapatkan direktori Download di Android");
    }

    // iOS
    final docs = await getApplicationDocumentsDirectory();
    if (!await docs.exists()) {
      await docs.create(recursive: true);
    }
    return docs;
  }
}
