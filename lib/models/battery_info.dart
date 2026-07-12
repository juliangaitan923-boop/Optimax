class BatteryInfo {
  final int level;
  final int percent;
  final double temperature;
  final int voltage;
  final bool isCharging;
  final int health;
  final int status;

  BatteryInfo({
    this.level = 0,
    this.percent = 0,
    this.temperature = 0,
    this.voltage = 0,
    this.isCharging = false,
    this.health = 0,
    this.status = 0,
  });

  factory BatteryInfo.fromMap(Map<String, dynamic> map) {
    return BatteryInfo(
      level: (map['level'] ?? 0) as int,
      percent: (map['percent'] ?? 0) as int,
      temperature: (map['temperature'] ?? 0.0).toDouble(),
      voltage: (map['voltage'] ?? 0) as int,
      isCharging: (map['isCharging'] ?? false) as bool,
      health: (map['health'] ?? 0) as int,
      status: (map['status'] ?? 0) as int,
    );
  }

  String get tempFormatted => '${temperature.toStringAsFixed(1)}°C';
  String get voltageFormatted => '${(voltage / 1000).toStringAsFixed(2)}V';

  String get healthLabel {
    switch (health) {
      case 1: return 'Mala';
      case 2: return 'Debajo de lo normal';
      case 3: return 'Normal';
      case 4: return 'Buena';
      case 5: return 'Excelente';
      default: return 'Desconocido';
    }
  }
}
