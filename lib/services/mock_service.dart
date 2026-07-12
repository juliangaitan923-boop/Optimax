import 'dart:math';
import '../models/cpu_info.dart';
import '../models/ram_info.dart';
import '../models/storage_info.dart';
import '../models/battery_info.dart';
import '../models/process_info.dart';

class MockService {
  static final _random = Random();

  static Future<CpuInfo> getCpuInfo() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return CpuInfo(
      usagePercent: 30 + _random.nextInt(50),
      cores: 8,
      temperature: 38 + _random.nextDouble() * 12,
      frequency: 1800 + _random.nextInt(1000),
    );
  }

  static Future<RamInfo> getRamInfo() async {
    await Future.delayed(const Duration(milliseconds: 150));
    const total = 8 * 1024 * 1024 * 1024;
    final available = (3 + _random.nextDouble() * 2) * 1024 * 1024 * 1024;
    final used = total - available.toInt();
    return RamInfo(
      total: total,
      used: used,
      available: available.toInt(),
      usagePercent: ((used.toDouble() / total) * 100).toInt(),
    );
  }

  static Future<StorageInfo> getStorageInfo() async {
    await Future.delayed(const Duration(milliseconds: 100));
    const total = 64 * 1024 * 1024 * 1024;
    final used = (32 + _random.nextInt(10)) * 1024 * 1024 * 1024;
    return StorageInfo(
      total: total,
      used: used,
      available: total - used,
      usagePercent: ((used.toDouble() / total) * 100).toInt(),
    );
  }

  static Future<BatteryInfo> getBatteryInfo() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return BatteryInfo(
      level: 50 + _random.nextInt(50),
      percent: 50 + _random.nextInt(50),
      temperature: 35 + _random.nextDouble() * 8,
      voltage: 3800 + _random.nextInt(400),
      isCharging: _random.nextBool(),
      health: 3 + _random.nextInt(2),
      status: _random.nextBool() ? 2 : 3,
    );
  }

  static Future<List<ProcessInfo>> getProcessList() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final apps = [
      'Chrome', 'WhatsApp', 'Instagram', 'Spotify', 'YouTube', 'Gmail',
      'Sistema Android', 'Play Services', 'Twitter', 'Telegram',
      'Facebook', 'Maps', 'Drive', 'Photos', 'Calendar', 'Calculator',
      'Clock', 'Contacts', 'Files', 'Messages',
    ];
    return List.generate(
      _random.nextInt(8) + 10,
      (i) => ProcessInfo(
        name: apps[i % apps.length],
        pid: 1000 + _random.nextInt(9000),
        importance: i < 3 ? 100 : _random.nextInt(400),
        packageName: 'com.${apps[i % apps.length].toLowerCase()}',
      ),
    );
  }

  static Future<List<Map<String, dynamic>>> getTopCpuApps() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final apps = ['Chrome', 'WhatsApp', 'YouTube', 'Instagram', 'Spotify'];
    final usageTimes = [5400, 3600, 2400, 1800, 900];
    return List.generate(
      5,
      (i) => {
        'name': apps[i],
        'packageName': 'com.${apps[i].toLowerCase()}',
        'usageTime': usageTimes[i],
        'lastUsed': DateTime.now().millisecondsSinceEpoch - _random.nextInt(3600000),
      },
    );
  }

  static Future<Map<String, dynamic>> cleanCache() async {
    await Future.delayed(const Duration(seconds: 2));
    return {
      'before': 1500000000,
      'after': 200000000,
      'freed': 1300000000,
      'success': true,
    };
  }

  static Future<bool> killProcess(int pid) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _random.nextBool();
  }

  static Future<Map<String, dynamic>> ramBoost() async {
    await Future.delayed(const Duration(seconds: 2));
    final ramFreed = 300 + _random.nextInt(900);
    return {
      'ramFreed': ramFreed * 1024 * 1024,
      'processesKilled': 3 + _random.nextInt(6),
      'success': true,
    };
  }

  static Future<List<Map<String, dynamic>>> getBatteryUsageStats(String period) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final daily = period == 'daily';
    final apps = [
      {'name': 'YouTube', 'packageName': 'com.google.android.youtube', 'usageTime': 0, 'batteryPercent': 0, 'lastUsed': 0},
      {'name': 'WhatsApp', 'packageName': 'com.whatsapp', 'usageTime': 0, 'batteryPercent': 0, 'lastUsed': 0},
      {'name': 'Instagram', 'packageName': 'com.instagram.android', 'usageTime': 0, 'batteryPercent': 0, 'lastUsed': 0},
      {'name': 'Chrome', 'packageName': 'com.android.chrome', 'usageTime': 0, 'batteryPercent': 0, 'lastUsed': 0},
      {'name': 'Spotify', 'packageName': 'com.spotify.music', 'usageTime': 0, 'batteryPercent': 0, 'lastUsed': 0},
      {'name': 'Facebook', 'packageName': 'com.facebook.katana', 'usageTime': 0, 'batteryPercent': 0, 'lastUsed': 0},
      {'name': 'Telegram', 'packageName': 'org.telegram.messenger', 'usageTime': 0, 'batteryPercent': 0, 'lastUsed': 0},
      {'name': 'Gmail', 'packageName': 'com.google.android.gm', 'usageTime': 0, 'batteryPercent': 0, 'lastUsed': 0},
      {'name': 'Maps', 'packageName': 'com.google.android.apps.maps', 'usageTime': 0, 'batteryPercent': 0, 'lastUsed': 0},
      {'name': 'Twitter', 'packageName': 'com.twitter.android', 'usageTime': 0, 'batteryPercent': 0, 'lastUsed': 0},
    ];

    final baseTimeDaily = [2400, 1800, 1200, 900, 600, 450, 300, 200, 150, 100];
    final baseTimeWeekly = [14400, 10800, 7200, 5400, 3600, 2700, 1800, 1200, 900, 600];
    final baseTimes = daily ? baseTimeDaily : baseTimeWeekly;

    int totalTime = 0;
    for (int i = 0; i < apps.length; i++) {
      final time = baseTimes[i] + _random.nextInt(baseTimes[i] ~/ 3);
      apps[i]['usageTime'] = time;
      apps[i]['lastUsed'] = DateTime.now().millisecondsSinceEpoch - _random.nextInt(3600000);
      totalTime += time;
    }

    if (totalTime == 0) totalTime = 1;
    for (int i = 0; i < apps.length; i++) {
      final time = apps[i]['usageTime'] as int;
      apps[i]['batteryPercent'] = ((time / totalTime) * 100).round().clamp(1, 100);
    }

    return apps;
  }

  static Future<List<Map<String, dynamic>>> getInstalledApps() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {'name': 'Free Fire', 'packageName': 'com.dts.freefireth', 'isGame': true},
      {'name': 'PUBG Mobile', 'packageName': 'com.tencent.ig', 'isGame': true},
      {'name': 'Call of Duty Mobile', 'packageName': 'com.activision.callofduty.shooter', 'isGame': true},
      {'name': 'Clash Royale', 'packageName': 'com.supercell.clashroyale', 'isGame': true},
      {'name': 'Asphalt 9', 'packageName': 'com.gameloft.android.ANMP.GloftA9HM', 'isGame': true},
      {'name': 'Minecraft', 'packageName': 'com.mojang.minecraftpe', 'isGame': true},
      {'name': 'WhatsApp', 'packageName': 'com.whatsapp', 'isGame': false},
      {'name': 'Instagram', 'packageName': 'com.instagram.android', 'isGame': false},
      {'name': 'Telegram', 'packageName': 'org.telegram.messenger', 'isGame': false},
      {'name': 'Spotify', 'packageName': 'com.spotify.music', 'isGame': false},
      {'name': 'YouTube', 'packageName': 'com.google.android.youtube', 'isGame': false},
      {'name': 'Gmail', 'packageName': 'com.google.android.gm', 'isGame': false},
      {'name': 'Chrome', 'packageName': 'com.android.chrome', 'isGame': false},
      {'name': 'Twitter', 'packageName': 'com.twitter.android', 'isGame': false},
      {'name': 'Facebook', 'packageName': 'com.facebook.katana', 'isGame': false},
    ];
  }
}
