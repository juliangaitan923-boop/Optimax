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

  String get totalFormatted => _formatBytes(total);
  String get usedFormatted => _formatBytes(used);
  String get availableFormatted => _formatBytes(available);

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
