import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cpu_info.dart';
import '../models/ram_info.dart';
import '../models/storage_info.dart';
import '../models/battery_info.dart';
import '../models/process_info.dart';
import '../services/device_service.dart';
import '../services/mock_service.dart';
import '../services/history_service.dart';
import '../services/app_settings.dart';
import '../services/storage_analyzer_service.dart';

final deviceServiceProvider = Provider<DeviceService>((ref) => DeviceService());

final historyServiceProvider = Provider<HistoryService>((ref) {
  final service = HistoryService();
  ref.onDispose(() => service.clear());
  return service;
});

final cpuInfoProvider = StreamProvider<CpuInfo>((ref) {
  final history = ref.read(historyServiceProvider);
  return Stream.periodic(const Duration(seconds: 1), (_) => null).asyncMap((_) async {
    try {
      final service = ref.read(deviceServiceProvider);
      final info = await service.getCpuInfo();
      history.recordCpu(info);
      return info;
    } catch (_) {
      final info = await MockService.getCpuInfo();
      history.recordCpu(info);
      return info;
    }
  });
});

final ramInfoProvider = StreamProvider<RamInfo>((ref) {
  final history = ref.read(historyServiceProvider);
  return Stream.periodic(const Duration(seconds: 1), (_) => null).asyncMap((_) async {
    try {
      final service = ref.read(deviceServiceProvider);
      final info = await service.getRamInfo();
      history.recordRam(info);
      return info;
    } catch (_) {
      final info = await MockService.getRamInfo();
      history.recordRam(info);
      return info;
    }
  });
});

final storageInfoProvider = StreamProvider<StorageInfo>((ref) {
  return Stream.periodic(const Duration(seconds: 2), (_) => null).asyncMap((_) async {
    try {
      final service = ref.read(deviceServiceProvider);
      return await service.getStorageInfo();
    } catch (_) {
      return await MockService.getStorageInfo();
    }
  });
});

final batteryInfoProvider = StreamProvider<BatteryInfo>((ref) {
  final history = ref.read(historyServiceProvider);
  return Stream.periodic(const Duration(seconds: 2), (_) => null).asyncMap((_) async {
    try {
      final service = ref.read(deviceServiceProvider);
      final info = await service.getBatteryInfo();
      history.recordBattery(info);
      return info;
    } catch (_) {
      final info = await MockService.getBatteryInfo();
      history.recordBattery(info);
      return info;
    }
  });
});

final processListProvider = FutureProvider<List<ProcessInfo>>((ref) async {
  try {
    final service = ref.read(deviceServiceProvider);
    return await service.getProcessList();
  } catch (_) {
    return await MockService.getProcessList();
  }
});

final topAppsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final service = ref.read(deviceServiceProvider);
    return await service.getTopCpuApps();
  } catch (_) {
    return await MockService.getTopCpuApps();
  }
});

final healthScoreProvider = Provider<int>((ref) {
  final cpuAsync = ref.watch(cpuInfoProvider);
  final ramAsync = ref.watch(ramInfoProvider);
  final storageAsync = ref.watch(storageInfoProvider);
  final batteryAsync = ref.watch(batteryInfoProvider);

  int score = 100;

  final cpu = cpuAsync.valueOrNull;
  final ram = ramAsync.valueOrNull;
  final storage = storageAsync.valueOrNull;
  final battery = batteryAsync.valueOrNull;

  if (cpu != null) {
    if (cpu.usagePercent > 80) {
      score -= 20;
    } else if (cpu.usagePercent > 60) {
      score -= 10;
    } else if (cpu.usagePercent > 40) {
      score -= 5;
    }
  }

  if (ram != null) {
    if (ram.usagePercent > 85) {
      score -= 20;
    } else if (ram.usagePercent > 70) {
      score -= 10;
    } else if (ram.usagePercent > 55) {
      score -= 5;
    }
  }

  if (storage != null) {
    if (storage.usagePercent > 85) {
      score -= 15;
    } else if (storage.usagePercent > 70) {
      score -= 8;
    } else if (storage.usagePercent > 55) {
      score -= 4;
    }
  }

  if (battery != null) {
    if (battery.temperature > 45) {
      score -= 15;
    } else if (battery.temperature > 40) {
      score -= 8;
    }
    if (battery.percent < 15) {
      score -= 10;
    } else if (battery.percent < 30) {
      score -= 5;
    }
  }

  return score.clamp(0, 100);
});

final gameModeProvider = StateProvider<bool>((ref) {
  return AppSettings.instance.getBool('gameMode', defaultValue: false);
});

final performanceProfileProvider = StateProvider<String>((ref) {
  return AppSettings.instance.getString('performanceProfile', defaultValue: 'normal');
});

final isBoostingProvider = StateProvider<bool>((ref) => false);

final tabIndexProvider = StateProvider<int>((ref) => 0);

final boostResultProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final isBoosting = ref.watch(isBoostingProvider);
  if (!isBoosting) throw Exception('Not boosting');

  try {
    final service = ref.read(deviceServiceProvider);
    return await service.boost();
  } catch (_) {
    return await MockService.cleanCache();
  }
});

final storageAnalyzerProvider = Provider<StorageAnalyzerService>((ref) => StorageAnalyzerService());
