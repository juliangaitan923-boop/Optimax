import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class UpdateInfo {
  final String version;
  final String url;
  final String changelog;

  UpdateInfo({
    required this.version,
    required this.url,
    required this.changelog,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      version: json['version'] as String? ?? '',
      url: json['url'] as String? ?? '',
      changelog: json['changelog'] as String? ?? '',
    );
  }

  bool get isValid => version.isNotEmpty && url.isNotEmpty;
}

class UpdateService {
  static const _channel = MethodChannel('com.optimax.app/performance');
  static const _updateUrl = 'https://raw.githubusercontent.com/juliangaitan923-boop/Optimax/main/update.json';

  static String get updateUrl => _updateUrl;

  static Future<UpdateInfo?> checkForUpdate(String currentVersion) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final request = await client.getUrl(Uri.parse(_updateUrl));
      final response = await request.close();
      if (response.statusCode != 200) return null;
      final body = await response.transform(utf8.decoder).join();
      client.close();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final info = UpdateInfo.fromJson(json);
      if (!info.isValid || info.version == currentVersion) return null;
      return info;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> downloadAndInstall(UpdateInfo info) async {
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/optimax_update.apk';
      final file = File(filePath);
      if (file.existsSync()) await file.delete();

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 60);
      client.userAgent = 'OptiMax-Update/1.0';
      final request = await client.getUrl(Uri.parse(info.url));
      final response = await request.close();
      if (response.statusCode != 200) {
        client.close();
        return false;
      }

      final sink = file.openWrite();
      await response.pipe(sink);
      await sink.close();
      client.close();

      final result = await _channel.invokeMethod<bool>('installApk', {'path': filePath});
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}
