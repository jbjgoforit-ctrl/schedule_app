import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class UpdateInfo {
  final String version, url, changelog;
  final int versionCode;
  const UpdateInfo({required this.version, required this.url, required this.changelog, required this.versionCode});
  factory UpdateInfo.fromJson(Map<String, dynamic> j) => UpdateInfo(version: j['version'] ?? '', url: j['url'] ?? '', changelog: j['changelog'] ?? '', versionCode: j['versionCode'] ?? 0);
}

class UpdateService {
  static const String _updateUrl = 'https://raw.fastgit.org/jbjgoforit-ctrl/schedule_app/main/update.json';

  static Future<UpdateInfo?> checkUpdate() async {
    final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10)));
    final resp = await dio.get(_updateUrl);
    if (resp.statusCode == 200) {
      final info = UpdateInfo.fromJson(resp.data);
      if (info.versionCode > 1) return info;
    }
    return null;
  }

  static Future<String?> downloadApk(String url, {void Function(double)? onProgress}) async {
    try {
      final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/schedule_app_update.apk');
      final dio = Dio();
      await dio.download(url, file.path, onReceiveProgress: (received, total) {
        if (total > 0 && onProgress != null) onProgress(received / total);
      });
      return file.path;
    } catch (_) {
      return null;
    }
  }

  static Future<void> installApk(String path) async {
    await OpenFilex.open(path);
  }
}
