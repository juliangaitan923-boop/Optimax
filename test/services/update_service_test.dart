import 'package:flutter_test/flutter_test.dart';
import 'package:optimax/services/update_service.dart';

void main() {
  group('UpdateInfo', () {
    test('fromJson creates valid UpdateInfo', () {
      final info = UpdateInfo.fromJson({
        'version': '1.0.5',
        'url': 'https://example.com/app.apk',
        'changelog': 'Test',
      });
      expect(info.version, '1.0.5');
      expect(info.url, 'https://example.com/app.apk');
      expect(info.isValid, isTrue);
    });

    test('fromJson with empty version is invalid', () {
      final info = UpdateInfo.fromJson({
        'version': '',
        'url': 'https://example.com/app.apk',
        'changelog': '',
      });
      expect(info.isValid, isFalse);
    });

    test('fromJson with empty url is invalid', () {
      final info = UpdateInfo.fromJson({
        'version': '1.0.5',
        'url': '',
        'changelog': '',
      });
      expect(info.isValid, isFalse);
    });

    test('fromJson handles missing fields', () {
      final info = UpdateInfo.fromJson({});
      expect(info.version, '');
      expect(info.url, '');
      expect(info.isValid, isFalse);
    });
  });

  group('Version comparison', () {
    test('equal versions return 0', () async {
      final result = await UpdateService.checkForUpdate('1.0.5');
      expect(result, isNull);
    });

    test('older local version returns update info', () {
      final result = UpdateService.compareVersions('1.0.5', '1.0.4');
      expect(result, greaterThan(0));
    });

    test('newer local version returns negative', () {
      final result = UpdateService.compareVersions('1.0.3', '1.0.5');
      expect(result, lessThan(0));
    });

    test('same version returns 0', () {
      final result = UpdateService.compareVersions('1.0.5', '1.0.5');
      expect(result, 0);
    });

    test('multi-digit versions compare correctly', () {
      final result = UpdateService.compareVersions('1.10.0', '1.9.0');
      expect(result, greaterThan(0));
    });
  });
}
