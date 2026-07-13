import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceInfoProvider = FutureProvider<String>((ref) async {
  final plugin = DeviceInfoPlugin();
  final info = await plugin.androidInfo;
  final model = info.model;
  final brand = info.brand;
  final sdk = "${info.version.sdkInt ?? 0}";
  return "$brand $model · Android $sdk";
});
