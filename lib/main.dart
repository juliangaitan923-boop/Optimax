import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/app_settings.dart';
import 'services/app_info.dart';
import 'services/error_handler.dart';
import 'services/logger_service.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorHandler.init();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  try {
    await AppSettings.instance.init();
    await AppInfo.init();
  } catch (e) {
    log.e('Init error', e);
  }
  final container = ProviderContainer();
  await container.read(themeProvider.notifier).init();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const OptiMaxApp(),
    ),
  );
}
