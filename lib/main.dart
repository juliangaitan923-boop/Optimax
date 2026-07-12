import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/app_settings.dart';
import 'services/app_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.instance.init();
  await AppInfo.init();
  runApp(const ProviderScope(child: OptiMaxApp()));
}
