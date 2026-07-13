import 'package:flutter/services.dart';
import '../models/cpu_info.dart';
import '../models/ram_info.dart';
import '../models/storage_info.dart';
import '../models/battery_info.dart';
import '../models/process_info.dart';
import 'logger_service.dart';
import 'mock_service.dart';

class DeviceService {
  static const _channel = MethodChannel('com.optimax.app/performance');

  Future<CpuInfo> getCpuInfo() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getCpuInfo');
      if (result != null) {
        return CpuInfo.fromMap(Map<String, dynamic>.from(result));
      }
    } catch (e) {
      log.w('getCpuInfo failed', e);
    }
    return CpuInfo();
  }

  Future<RamInfo> getRamInfo() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getRamInfo');
      if (result != null) {
        return RamInfo.fromMap(Map<String, dynamic>.from(result));
      }
    } catch (e) {
      log.w('getRamInfo failed', e);
    }
    return RamInfo();
  }

  Future<StorageInfo> getStorageInfo() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getStorageInfo');
      if (result != null) {
        return StorageInfo.fromMap(Map<String, dynamic>.from(result));
      }
    } catch (e) {
      log.w('getStorageInfo failed', e);
    }
    return StorageInfo();
  }

  Future<BatteryInfo> getBatteryInfo() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getBatteryInfo');
      if (result != null) {
        return BatteryInfo.fromMap(Map<String, dynamic>.from(result));
      }
    } catch (e) {
      log.w('getBatteryInfo failed', e);
    }
    return BatteryInfo();
  }

  Future<List<ProcessInfo>> getProcessList() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getProcessList');
      if (result != null) {
        return result.map((e) => ProcessInfo.fromMap(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      log.w('getProcessList failed', e);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getTopCpuApps() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getTopCpuApps');
      if (result != null) {
        return result.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      log.w('getTopCpuApps failed', e);
    }
    return [];
  }

  Future<Map<String, dynamic>> cleanCache() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('cleanCache');
      if (result != null) {
        return Map<String, dynamic>.from(result);
      }
    } catch (e) {
      log.w('cleanCache failed', e);
    }
    return {'success': false};
  }

  Future<bool> killProcess(int pid) async {
    try {
      final result = await _channel.invokeMethod<bool>('killProcess', {'pid': pid});
      return result ?? false;
    } catch (e) {
      log.w('killProcess failed', e);
      return false;
    }
  }

  Future<bool> enableGameMode() async {
    try {
      final result = await _channel.invokeMethod<bool>('enableGameMode');
      return result ?? false;
    } catch (e) {
      log.w('enableGameMode failed', e);
      return false;
    }
  }

  Future<bool> disableGameMode() async {
    try {
      final result = await _channel.invokeMethod<bool>('disableGameMode');
      return result ?? false;
    } catch (e) {
      log.w('disableGameMode failed', e);
      return false;
    }
  }

  Future<bool> isGameModeActive() async {
    try {
      final result = await _channel.invokeMethod<bool>('isGameModeActive');
      return result ?? false;
    } catch (e) {
      log.w('isGameModeActive failed', e);
      return false;
    }
  }

  Future<bool> setPerformanceProfile(String profile) async {
    try {
      final result = await _channel.invokeMethod<bool>('setPerformanceProfile', {'profile': profile});
      return result ?? false;
    } catch (e) {
      log.w('setPerformanceProfile failed', e);
      return false;
    }
  }

  Future<String> getCurrentProfile() async {
    try {
      final result = await _channel.invokeMethod<String>('getCurrentProfile');
      return result ?? 'normal';
    } catch (e) {
      log.w('getCurrentProfile failed', e);
      return 'normal';
    }
  }

  Future<bool> openDisplaySettings() async {
    try {
      final result = await _channel.invokeMethod<bool>('openDisplaySettings');
      return result ?? false;
    } catch (e) {
      log.w('openDisplaySettings failed', e);
      return false;
    }
  }

  Future<bool> openWifiSettings() async {
    try {
      final result = await _channel.invokeMethod<bool>('openWifiSettings');
      return result ?? false;
    } catch (e) {
      log.w('openWifiSettings failed', e);
      return false;
    }
  }

  Future<bool> openBatterySaverSettings() async {
    try {
      final result = await _channel.invokeMethod<bool>('openBatterySaverSettings');
      return result ?? false;
    } catch (e) {
      log.w('openBatterySaverSettings failed', e);
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getInstalledApps() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getInstalledApps');
      if (result != null) {
        return result.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      log.w('getInstalledApps failed', e);
    }
    return await MockService.getInstalledApps();
  }

  Future<bool> killPackage(String packageName) async {
    try {
      final result = await _channel.invokeMethod<bool>('killPackage', {'package': packageName});
      return result ?? false;
    } catch (e) {
      log.w('killPackage failed', e);
      return false;
    }
  }

  Future<Map<String, dynamic>> boost() async {
    int ramFreed = 0;
    int cacheFreed = 0;
    int processesKilled = 0;

    try {
      final cacheResult = await cleanCache();
      if (cacheResult['success'] == true) {
        cacheFreed = (cacheResult['freed'] ?? 0) as int;
      }

      final processes = await getProcessList();
      int killed = 0;
      for (final proc in processes) {
        if (!proc.isSystem && proc.importance < 200) {
          final success = await killProcess(proc.pid);
          if (success) killed++;
        }
      }
      processesKilled = killed;

      final ramBefore = await getRamInfo();

      await Future.delayed(const Duration(seconds: 1));

      final ramAfter = await getRamInfo();
      ramFreed = ramAfter.available - ramBefore.available;

    } catch (e) {
      log.w('boost failed', e);
    }

    return {
      'ramFreed': ramFreed < 0 ? 0 : ramFreed,
      'cacheFreed': cacheFreed,
      'processesKilled': processesKilled,
      'success': true,
    };
  }

  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getDeviceInfo');
      if (result != null) {
        return Map<String, dynamic>.from(result);
      }
    } catch (e) {
      log.w('getDeviceInfo failed', e);
    }
    return {'error': 'No disponible'};
  }

  Future<Map<String, dynamic>> executeShellCommand(String command) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('executeShellCommand', {'command': command});
      if (result != null) {
        return Map<String, dynamic>.from(result);
      }
    } catch (e) {
      log.w('executeShellCommand failed', e);
    }
    return {'success': false, 'error': 'No disponible'};
  }

  Future<Map<String, dynamic>> applyExtremeOptimizations() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('applyExtremeOptimizations');
      if (result != null) {
        return Map<String, dynamic>.from(result);
      }
    } catch (e) {
      log.w('applyExtremeOptimizations failed', e);
    }
    return {'success': false, 'error': 'No disponible'};
  }

  Future<Map<String, dynamic>> revertExtremeOptimizations() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('revertExtremeOptimizations');
      if (result != null) {
        return Map<String, dynamic>.from(result);
      }
    } catch (e) {
      log.w('revertExtremeOptimizations failed', e);
    }
    return {'success': false, 'error': 'No disponible'};
  }

  Future<Map<String, dynamic>> deepBoost() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('deepBoost');
      if (result != null) {
        return Map<String, dynamic>.from(result);
      }
    } catch (e) {
      log.w('deepBoost failed', e);
    }
    return {'success': false, 'error': 'No disponible'};
  }

  Future<List<Map<String, dynamic>>> getBatteryUsageStats(String period) async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getBatteryUsageStats', {'period': period});
      if (result != null) {
        return result.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      log.w('getBatteryUsageStats failed', e);
    }
    return await MockService.getBatteryUsageStats(period);
  }
}