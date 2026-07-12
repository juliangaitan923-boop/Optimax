import 'package:flutter/foundation.dart';
import 'logger_service.dart';

class ErrorHandler {
  static void init() {
    FlutterError.onError = (details) {
      log.e(
        'Flutter error: ${details.exception}',
        details.exception,
        details.stack,
      );
      FlutterError.presentError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      log.e('Platform error', error, stack);
      return true;
    };
  }
}
