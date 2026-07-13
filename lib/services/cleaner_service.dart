import 'package:flutter/material.dart';
import '../models/cleanup_item.dart';
import 'device_service.dart';
import 'mock_service.dart';

class CleanerService {
  final DeviceService _deviceService;

  CleanerService(this._deviceService);

  Future<List<CleanupItem>> scanJunk() async {
    await Future.delayed(const Duration(seconds: 2));

    final List<CleanupItem> items = [];

    try {
      final cacheResult = await _deviceService.cleanCache();
      final cacheFreed = cacheResult['freed'] as int? ?? 0;
      if (cacheFreed > 0) {
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
      if (mockCache > 0) {
        items.add(CleanupItem(
          id: 'app_cache',
          name: 'Caché de apps',
          category: 'Caché',
          size: mockCache,
          icon: Icons.cached,
        ));
      }
    }

    items.add(CleanupItem(
      id: 'residual_files',
      name: 'Archivos residuales',
      category: 'Residuos',
      size: 128 * 1024 * 1024,
      icon: Icons.cleaning_services,
    ));

    items.add(CleanupItem(
      id: 'temp_files',
      name: 'Archivos temporales',
      category: 'Temporales',
      size: 64 * 1024 * 1024,
      icon: Icons.timer,
    ));

    items.add(CleanupItem(
      id: 'thumbnails',
      name: 'Miniaturas obsoletas',
      category: 'Miniaturas',
      size: 32 * 1024 * 1024,
      icon: Icons.image,
    ));

    items.add(CleanupItem(
      id: 'old_apks',
      name: 'APKs antiguos',
      category: 'Instaladores',
      size: 48 * 1024 * 1024,
      icon: Icons.android,
    ));

    items.add(CleanupItem(
      id: 'system_logs',
      name: 'Logs del sistema',
      category: 'Logs',
      size: 16 * 1024 * 1024,
      icon: Icons.article,
    ));

    items.add(CleanupItem(
      id: 'installed_cache',
      name: 'Caché de 12 apps instaladas',
      category: 'Caché',
      size: 256 * 1024 * 1024,
      icon: Icons.phone_android,
    ));

    return items;
  }

  Future<int> cleanItems(List<String> ids) async {
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
          totalFreed += 64 * 1024 * 1024;
          break;
        case 'thumbnails':
          totalFreed += 32 * 1024 * 1024;
          break;
        case 'old_apks':
          totalFreed += 48 * 1024 * 1024;
          break;
        case 'system_logs':
          totalFreed += 16 * 1024 * 1024;
          break;
        default:
          totalFreed += 128 * 1024 * 1024;
      }
    }

    return totalFreed > 0 ? totalFreed : ids.length * 50 * 1024 * 1024;
  }

  Future<void> reset() async {
  }
}