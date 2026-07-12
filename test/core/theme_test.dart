import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optimax/core/theme.dart';
import 'package:optimax/core/constants.dart';

void main() {
  group('AppTheme', () {
    test('dark theme is dark', () {
      expect(AppTheme.darkTheme.brightness, Brightness.dark);
    });

    test('light theme is light', () {
      expect(AppTheme.lightTheme.brightness, Brightness.light);
    });

    test('dark theme uses Material 3', () {
      expect(AppTheme.darkTheme.useMaterial3, isTrue);
    });

    test('light theme uses Material 3', () {
      expect(AppTheme.lightTheme.useMaterial3, isTrue);
    });

    test('dark theme has primary color seed', () {
      final scheme = AppTheme.darkTheme.colorScheme;
      expect(scheme.primary, isNotNull);
    });
  });

  group('AppColors', () {
    test('all colors are non-null', () {
      expect(AppColors.primary, isNotNull);
      expect(AppColors.secondary, isNotNull);
      expect(AppColors.warning, isNotNull);
      expect(AppColors.success, isNotNull);
      expect(AppColors.info, isNotNull);
      expect(AppColors.surfaceDark, isNotNull);
      expect(AppColors.surfaceCard, isNotNull);
    });
  });

  group('AppDurations', () {
    test('durations are positive', () {
      expect(AppDurations.animationDuration.inMilliseconds, greaterThan(0));
      expect(AppDurations.refreshInterval.inMilliseconds, greaterThan(0));
      expect(AppDurations.scanDuration.inMilliseconds, greaterThan(0));
      expect(AppDurations.boostDuration.inMilliseconds, greaterThan(0));
    });
  });
}
