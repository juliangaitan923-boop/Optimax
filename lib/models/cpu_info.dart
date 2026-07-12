class CpuInfo {
  final int usagePercent;
  final int cores;
  final double temperature;
  final int frequency;

  CpuInfo({
    this.usagePercent = 0,
    this.cores = 0,
    this.temperature = 0,
    this.frequency = 0,
  });

  factory CpuInfo.fromMap(Map<String, dynamic> map) {
    return CpuInfo(
      usagePercent: (map['usage'] ?? 0) as int,
      cores: (map['cores'] ?? 0) as int,
      temperature: (map['temperature'] ?? 0.0).toDouble(),
      frequency: (map['frequency'] ?? 0) as int,
    );
  }

  String get tempFormatted => '${temperature.toStringAsFixed(1)}°C';
  String get freqFormatted => '${(frequency / 1000).toStringAsFixed(1)} GHz';
}
