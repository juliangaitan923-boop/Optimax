import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:optimax/app.dart';
import 'package:optimax/core/theme.dart';
import 'package:optimax/core/constants.dart';
import 'package:optimax/services/update_service.dart';

void main() {
  testWidgets('App renders without crashing', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: OptiMaxApp()));
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Dark theme has correct brightness', (tester) async {
    final theme = AppTheme.darkTheme;
    expect(theme.brightness, Brightness.dark);
  });

  testWidgets('Light theme has correct brightness', (tester) async {
    final theme = AppTheme.lightTheme;
    expect(theme.brightness, Brightness.light);
  });

  test('AppColors primary is defined', () {
    expect(AppColors.primary, isNotNull);
  });

  test('AppDurations are positive', () {
    expect(AppDurations.animationDuration.inMilliseconds, greaterThan(0));
    expect(AppDurations.refreshInterval.inSeconds, greaterThan(0));
  });

  test('UpdateInfo from valid JSON', () {
    final json = {
      'version': '1.0.5',
      'url': 'https://example.com/app.apk',
      'changelog': 'Test release',
    };
    final info = UpdateInfo.fromJson(json);
    expect(info.version, '1.0.5');
    expect(info.url, 'https://example.com/app.apk');
    expect(info.changelog, 'Test release');
    expect(info.isValid, isTrue);
  });

  test('UpdateInfo from empty JSON is invalid', () {
    final json = {'version': '', 'url': ''};
    final info = UpdateInfo.fromJson(json);
    expect(info.isValid, isFalse);
  });

  group('Navigation labels', () {
    const labels = ['Dashboard', 'Limpiar', 'Batería', 'Más'];
    test('has 4 tabs', () {
      expect(labels.length, 4);
    });
  });
}
