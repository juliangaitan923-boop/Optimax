import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'logger_service.dart';

class AppSettings {
  static AppSettings? _instance;
  Map<String, dynamic> _data = {};
  late String _filePath;

  AppSettings._();

  static AppSettings get instance {
    _instance ??= AppSettings._();
    return _instance!;
  }

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _filePath = '${dir.path}/settings.json';
    try {
      final file = File(_filePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        _data = json.decode(content) as Map<String, dynamic>;
      }
    } catch (e) {
      log.w('AppSettings.init failed', e);
      _data = {};
    }
  }

  Future<void> _save() async {
    try {
      final file = File(_filePath);
      await file.writeAsString(json.encode(_data));
    } catch (e) {
      log.w('AppSettings._save failed', e);
    }
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _data[key] as bool? ?? defaultValue;
  }

  Future<void> setBool(String key, bool value) async {
    _data[key] = value;
    await _save();
  }

  String getString(String key, {String defaultValue = ''}) {
    return _data[key] as String? ?? defaultValue;
  }

  Future<void> setString(String key, String value) async {
    _data[key] = value;
    await _save();
  }

  int getInt(String key, {int defaultValue = 0}) {
    return _data[key] as int? ?? defaultValue;
  }

  Future<void> setInt(String key, int value) async {
    _data[key] = value;
    await _save();
  }

  List<String> getStringList(String key) {
    final list = _data[key];
    if (list is List) return list.cast<String>();
    return [];
  }

  Future<void> setStringList(String key, List<String> value) async {
    _data[key] = value;
    await _save();
  }
}
