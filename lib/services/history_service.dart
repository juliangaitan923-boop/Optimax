import 'dart:collection';
import '../models/cpu_info.dart';
import '../models/ram_info.dart';
import '../models/battery_info.dart';

class DataPoint {
  final double value;
  final DateTime time;

  DataPoint(this.value, this.time);
}

class HistoryService {
  static const int _maxPoints = 60;

  final List<DataPoint> _cpuHistory = [];
  final List<DataPoint> _ramHistory = [];
  final List<DataPoint> _batteryHistory = [];

  UnmodifiableListView<DataPoint> get cpuHistory => UnmodifiableListView(_cpuHistory);
  UnmodifiableListView<DataPoint> get ramHistory => UnmodifiableListView(_ramHistory);
  UnmodifiableListView<DataPoint> get batteryHistory => UnmodifiableListView(_batteryHistory);

  void recordCpu(CpuInfo info) {
    _cpuHistory.add(DataPoint(info.usagePercent.toDouble(), DateTime.now()));
    if (_cpuHistory.length > _maxPoints) _cpuHistory.removeAt(0);
  }

  void recordRam(RamInfo info) {
    _ramHistory.add(DataPoint(info.usagePercent.toDouble(), DateTime.now()));
    if (_ramHistory.length > _maxPoints) _ramHistory.removeAt(0);
  }

  void recordBattery(BatteryInfo info) {
    _batteryHistory.add(DataPoint(info.percent.toDouble(), DateTime.now()));
    if (_batteryHistory.length > _maxPoints) _batteryHistory.removeAt(0);
  }

  void clear() {
    _cpuHistory.clear();
    _ramHistory.clear();
    _batteryHistory.clear();
  }
}
