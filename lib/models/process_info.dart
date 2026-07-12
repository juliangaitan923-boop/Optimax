class ProcessInfo {
  final String name;
  final int pid;
  final int importance;
  final String packageName;

  ProcessInfo({
    required this.name,
    required this.pid,
    this.importance = 0,
    required this.packageName,
  });

  factory ProcessInfo.fromMap(Map<String, dynamic> map) {
    return ProcessInfo(
      name: map['name'] as String? ?? '',
      pid: (map['pid'] ?? 0) as int,
      importance: (map['importance'] ?? 0) as int,
      packageName: map['packageName'] as String? ?? '',
    );
  }

  bool get isSystem => importance <= 100;
  bool get isVisible => importance >= 200;

  String get importanceLabel {
    if (isSystem) return 'Sistema';
    if (isVisible) return 'App';
    return 'Background';
  }
}
