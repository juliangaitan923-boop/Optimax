import '../core/utils.dart';

class RamInfo {
  final int total;
  final int used;
  final int available;
  final int usagePercent;

  RamInfo({
    this.total = 0,
    this.used = 0,
    this.available = 0,
    this.usagePercent = 0,
  });

  factory RamInfo.fromMap(Map<String, dynamic> map) {
    return RamInfo(
      total: (map['total'] ?? 0) as int,
      used: (map['used'] ?? 0) as int,
      available: (map['available'] ?? 0) as int,
      usagePercent: (map['usagePercent'] ?? 0) as int,
    );
  }

  String get totalFormatted => formatBytes(total);
  String get usedFormatted => formatBytes(used);
  String get availableFormatted => formatBytes(available);
}
