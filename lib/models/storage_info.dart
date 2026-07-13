import '../core/utils.dart';

class StorageInfo {
  final int total;
  final int used;
  final int available;
  final int usagePercent;
  final int internalTotal;
  final int internalAvailable;
  final int internalUsed;

  StorageInfo({
    this.total = 0,
    this.used = 0,
    this.available = 0,
    this.usagePercent = 0,
    this.internalTotal = 0,
    this.internalAvailable = 0,
    this.internalUsed = 0,
  });

  factory StorageInfo.fromMap(Map<String, dynamic> map) {
    return StorageInfo(
      total: (map['total'] ?? 0) as int,
      used: (map['used'] ?? 0) as int,
      available: (map['available'] ?? 0) as int,
      usagePercent: (map['usagePercent'] ?? 0) as int,
      internalTotal: (map['internalTotal'] ?? 0) as int,
      internalAvailable: (map['internalAvailable'] ?? 0) as int,
      internalUsed: (map['internalUsed'] ?? 0) as int,
    );
  }

  String get totalFormatted => formatBytes(total);
  String get usedFormatted => formatBytes(used);
  String get availableFormatted => formatBytes(available);
}
