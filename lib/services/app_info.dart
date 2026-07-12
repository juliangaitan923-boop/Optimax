import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  static late final PackageInfo _info;

  static Future<void> init() async {
    _info = await PackageInfo.fromPlatform();
  }

  static String get version => _info.version;
}
