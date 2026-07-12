import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers/system_providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/history_chart.dart';

class CpuMonitorScreen extends ConsumerWidget {
  const CpuMonitorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cpuAsync = ref.watch(cpuInfoProvider);
    final ramAsync = ref.watch(ramInfoProvider);
    final topAppsAsync = ref.watch(topAppsProvider);
    final history = ref.watch(historyServiceProvider);

    final cpu = cpuAsync.valueOrNull;
    final ram = ramAsync.valueOrNull;

    final cpuSpots = history.cpuHistory.map((p) {
      return FlSpot(p.time.millisecondsSinceEpoch.toDouble(), p.value);
    }).toList();
    final ramSpots = history.ramHistory.map((p) {
      return FlSpot(p.time.millisecondsSinceEpoch.toDouble(), p.value);
    }).toList();
    final now = DateTime.now().millisecondsSinceEpoch.toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitor de CPU y RAM', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // CPU Card
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.memory, color: AppColors.primary, size: 22),
                      SizedBox(width: 8),
                      Text('CPU', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _metricTile('Uso', '${cpu?.usagePercent ?? 0}%', AppColors.primary),
                      _metricTile('Temp', cpu?.tempFormatted ?? '--', AppColors.warning),
                      _metricTile('Frec', cpu?.freqFormatted ?? '--', AppColors.info),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 140,
                    child: HistoryLineChart(
                      spots: cpuSpots.map((s) => FlSpot((s.x - now) / 1000, s.y)).toList(),
                      color: AppColors.primary,
                      label: 'CPU %',
                      minY: 0,
                      maxY: 100,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // RAM Card
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.data_usage, color: AppColors.secondary, size: 22),
                      SizedBox(width: 8),
                      Text('RAM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _metricTile('Uso', '${ram?.usagePercent ?? 0}%', AppColors.secondary),
                      _metricTile('Usado', ram?.usedFormatted ?? '--', AppColors.warning),
                      _metricTile('Disponible', ram?.availableFormatted ?? '--', AppColors.info),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 140,
                    child: HistoryLineChart(
                      spots: ramSpots.map((s) => FlSpot((s.x - now) / 1000, s.y)).toList(),
                      color: AppColors.secondary,
                      label: 'RAM %',
                      minY: 0,
                      maxY: 100,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Top Apps
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.apps, color: AppColors.info, size: 18),
                      SizedBox(width: 8),
                      Text('Apps con mayor consumo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  topAppsAsync.when(
                    data: (apps) => Column(
                      children: apps.map((app) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.android, color: AppColors.primary, size: 16),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(app['name'] as String? ?? '', style: const TextStyle(color: Colors.white, fontSize: 13)),
                            ),
                            Text(
                              _formatDuration((app['usageTime'] as int?) ?? 0),
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    error: (_, __) => const Text('No disponible', style: TextStyle(color: AppColors.textMuted)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _metricTile(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${seconds ~/ 60}m';
    return '${seconds ~/ 3600}h ${(seconds % 3600) ~/ 60}m';
  }
}
