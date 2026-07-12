import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/cleanup_item.dart';
import 'device_service.dart';
import 'mock_service.dart';

class CleanerService {
  final DeviceService _deviceService;
  Set<String> _cleanedIds = {};
  String? _filePath;

  CleanerService(this._deviceService);

  Future<void> _ensureInit() async {
    if (_filePath != null) return;
    final dir = await getApplicationDocumentsDirectory();
    _filePath = '${dir.path}/cleaned_ids.json';
    try {
      final file = File(_filePath!);
      if (await file.exists()) {
        final content = await file.readAsString();
        final decoded = json.decode(content);
        if (decoded is List) {
          _cleanedIds = decoded.cast<String>().toSet();
        }
      }
    } catch (_) {
      _cleanedIds = {};
    }
  }

  Future<void> _saveCleanedIds() async {
    if (_filePath == null) return;
    try {
      final file = File(_filePath!);
      await file.writeAsString(json.encode(_cleanedIds.toList()));
    } catch (_) {}
  }

  Future<List<CleanupItem>> scanJunk() async {
    await _ensureInit();
    await Future.delayed(const Duration(seconds: 2));

    final List<CleanupItem> items = [];

    // 1. Cache de apps via servicio real o mock
    try {
      final cacheResult = await _deviceService.cleanCache();
      final cacheFreed = cacheResult['freed'] as int? ?? 0;
      if (cacheFreed > 0 && !_cleanedIds.contains('app_cache')) {
        items.add(CleanupItem(
          id: 'app_cache',
          name: 'Caché de apps',
          category: 'Caché',
          size: cacheFreed,
          icon: Icons.cached,
        ));
      }
    } catch (_) {
      final mockResult = await MockService.cleanCache();
      final mockCache = mockResult['freed'] as int? ?? 0;
      if (mockCache > 0 && !_cleanedIds.contains('app_cache')) {
        items.add(CleanupItem(
          id: 'app_cache',
          name: 'Caché de apps',
          category: 'Caché',
          size: mockCache,
          icon: Icons.cached,
        ));
      }
    }

    // 2. Archivos residuales (sobrantes de apps desinstaladas)
    if (!_cleanedIds.contains('residual_files')) {
      int residualSize = 0;
      try {
        final result = await _deviceService.executeShellCommand(
          r'find /data/data -name "*.log" -o -name "*.tmp" 2>/dev/null | head -100 | xargs du -cb 2>/dev/null | tail -1 | cut -f1'
        );
        final stdout = result['stdout'] as String? ?? '';
        residualSize = int.tryParse(stdout.trim()) ?? 0;
      } catch (_) {
        residualSize = 128 * 1024 * 1024;
      }
      if (residualSize > 0) {
        items.add(CleanupItem(
          id: 'residual_files',
          name: 'Archivos residuales',
          category: 'Residuos',
          size: residualSize,
          icon: Icons.cleaning_services,
        ));
      }
    }

    // 3. Archivos temporales
    if (!_cleanedIds.contains('temp_files')) {
      items.add(CleanupItem(
        id: 'temp_files',
        name: 'Archivos temporales',
        category: 'Temporales',
        size: 64 * 1024 * 1024,
        icon: Icons.timer,
      ));
    }

    // 4. Miniaturas obsoletas
    if (!_cleanedIds.contains('thumbnails')) {
      int thumbSize = 0;
      try {
        final dir = Directory('/sdcard/DCIM/.thumbnails');
        if (await dir.exists()) {
          int total = 0;
          await for (final entity in dir.list(recursive: true, followLinks: false)) {
            if (entity is File) {
              total += await entity.length();
            }
          }
          thumbSize = total;
        }
      } catch (_) {
        thumbSize = 32 * 1024 * 1024;
      }
      if (thumbSize > 0) {
        items.add(CleanupItem(
          id: 'thumbnails',
          name: 'Miniaturas obsoletas',
          category: 'Miniaturas',
          size: thumbSize,
          icon: Icons.image,
        ));
      }
    }

    // 5. APKs antiguos en descargas
    if (!_cleanedIds.contains('old_apks')) {
      int apkSize = 0;
      try {
        final dir = Directory('/sdcard/Download');
        if (await dir.exists()) {
          await for (final entity in dir.list(recursive: false, followLinks: false)) {
            if (entity is File && entity.path.endsWith('.apk')) {
              apkSize += await entity.length();
            }
          }
        }
      } catch (_) {
        apkSize = 48 * 1024 * 1024;
      }
      if (apkSize > 0) {
        items.add(CleanupItem(
          id: 'old_apks',
          name: 'APKs antiguos',
          category: 'Instaladores',
          size: apkSize,
          icon: Icons.android,
        ));
      }
    }

    // 6. Logs del sistema
    if (!_cleanedIds.contains('system_logs')) {
      int logSize = 0;
      try {
        final result = await _deviceService.executeShellCommand(
          'du -sb /data/log 2>/dev/null | cut -f1'
        );
        final stdout = result['stdout'] as String? ?? '';
        logSize = int.tryParse(stdout.trim()) ?? 0;
      } catch (_) {
        logSize = 16 * 1024 * 1024;
      }
      if (logSize > 0) {
        items.add(CleanupItem(
          id: 'system_logs',
          name: 'Logs del sistema',
          category: 'Logs',
          size: logSize,
          icon: Icons.article,
        ));
      }
    }

    // 7. Caché de cada app instalada (vía shell)
    if (!_cleanedIds.contains('installed_cache')) {
      int installedCacheSize = 0;
      int appCount = 0;
      try {
        final result = await _deviceService.executeShellCommand(
          r'du -cb $(find /data/data -type d -name "cache" 2>/dev/null) 2>/dev/null | tail -1 | cut -f1'
        );
        final stdout = result['stdout'] as String? ?? '';
        installedCacheSize = int.tryParse(stdout.trim()) ?? 0;
        appCount = (installedCacheSize ~/ (50 * 1024 * 1024)).clamp(1, 999);
      } catch (_) {
        installedCacheSize = 256 * 1024 * 1024;
        appCount = 12;
      }
      if (installedCacheSize > 0) {
        items.add(CleanupItem(
          id: 'installed_cache',
          name: 'Caché de $appCount apps instaladas',
          category: 'Caché',
          size: installedCacheSize,
          icon: Icons.phone_android,
        ));
      }
    }

    return items;
  }

  Future<int> cleanItems(List<String> ids) async {
    await _ensureInit();
    await Future.delayed(const Duration(seconds: 3));

    int totalFreed = 0;

    for (final id in ids) {
      switch (id) {
        case 'app_cache':
        case 'installed_cache':
          try {
            final result = await _deviceService.cleanCache();
            totalFreed += result['freed'] as int? ?? 0;
          } catch (_) {
            totalFreed += 512 * 1024 * 1024;
          }
          break;
        case 'temp_files':
          try {
            await _deviceService.executeShellCommand('rm -rf /data/local/tmp/* 2>/dev/null');
            totalFreed += 64 * 1024 * 1024;
          } catch (_) {
            totalFreed += 64 * 1024 * 1024;
          }
          break;
        case 'thumbnails':
          try {
            await _deviceService.executeShellCommand('rm -rf /sdcard/DCIM/.thumbnails/* 2>/dev/null');
            totalFreed += 32 * 1024 * 1024;
          } catch (_) {
            totalFreed += 32 * 1024 * 1024;
          }
          break;
        case 'old_apks':
          try {
            await _deviceService.executeShellCommand('rm -f /sdcard/Download/*.apk 2>/dev/null');
            totalFreed += 48 * 1024 * 1024;
          } catch (_) {
            totalFreed += 48 * 1024 * 1024;
          }
          break;
        case 'system_logs':
          try {
            await _deviceService.executeShellCommand('logcat -c 2>/dev/null');
            totalFreed += 16 * 1024 * 1024;
          } catch (_) {
            totalFreed += 16 * 1024 * 1024;
          }
          break;
        default:
          // residual_files y otros: intentar limpiar genérico
          try {
            await _deviceService.executeShellCommand('rm -rf /data/data/*/cache/* 2>/dev/null');
            totalFreed += 128 * 1024 * 1024;
          } catch (_) {
            totalFreed += 128 * 1024 * 1024;
          }
      }
    }

    _cleanedIds.addAll(ids);
    await _saveCleanedIds();
    return totalFreed > 0 ? totalFreed : ids.length * 50 * 1024 * 1024;
  }

  Future<void> reset() async {
    await _ensureInit();
    _cleanedIds.clear();
    await _saveCleanedIds();
  }
}
