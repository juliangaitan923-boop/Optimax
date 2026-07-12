import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers/system_providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/history_chart.dart';

class BatteryScreen extends ConsumerStatefulWidget {
  const BatteryScreen({super.key});

  @override
  ConsumerState<BatteryScreen> createState() => _BatteryScreenState();
}

class _BatteryScreenState extends ConsumerState<BatteryScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final batteryAsync = ref.watch(batteryInfoProvider);
    final battery = batteryAsync.valueOrNull;
    final history = ref.watch(historyServiceProvider);

    final batterySpots = history.batteryHistory.map((p) {
      return FlSpot(p.time.millisecondsSinceEpoch.toDouble(), p.value);
    }).toList();
    final now = DateTime.now().millisecondsSinceEpoch.toDouble();
    final batterySpotsNorm = batterySpots.map((s) => FlSpot((s.x - now) / 1000, s.y)).toList();

    final period = _tabIndex == 0 ? 'daily' : 'weekly';
    final batteryUsageAsync = ref.watch(batteryUsageProvider(period));

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.battery_std, color: AppColors.secondary),
            SizedBox(width: 8),
            Text('Batería', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Battery circle + info
            GlassCard(
              child: Column(
                children: [
                  SizedBox(
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 120, height: 120,
                          child: CircularProgressIndicator(
                            value: (battery?.percent ?? 0) / 100.0,
                            strokeWidth: 10,
                            backgroundColor: Colors.white.withOpacity(0.05),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              battery?.percent != null && battery!.percent > 20
                                  ? AppColors.success : AppColors.warning,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${battery?.percent ?? 0}%',
                              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text(battery?.isCharging == true ? 'Cargando' : 'Descargando',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Temperatura', battery?.tempFormatted ?? '--'),
                  _buildInfoRow('Voltaje', battery?.voltageFormatted ?? '--'),
                  _buildInfoRow('Estado', battery?.healthLabel ?? '--'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Battery history chart
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.timeline, color: AppColors.primary, size: 18),
                      SizedBox(width: 8),
                      Text('Historial de batería',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: HistoryLineChart(
                      spots: batterySpotsNorm,
                      color: battery?.percent != null && battery!.percent > 20
                          ? AppColors.success : AppColors.warning,
                      minY: 0, maxY: 100,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Recommendations
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recomendaciones',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(height: 12),
                  _suggestionTile(Icons.brightness_low, 'Reducir brillo de pantalla',
                    'La pantalla consume hasta el 40% de la batería',
                    () => _openSetting(context, ref, 'display')),
                  const Divider(color: Colors.white10, height: 20),
                  _suggestionTile(Icons.wifi_off, 'Desactivar WiFi/BT no usados',
                    'Las conexiones activas consumen batería en segundo plano',
                    () => _openSetting(context, ref, 'wifi')),
                  const Divider(color: Colors.white10, height: 20),
                  _suggestionTile(Icons.power_settings_new, 'Activar ahorro de energía',
                    'Limita procesos en segundo plano para extender batería',
                    () => _openSetting(context, ref, 'battery_saver')),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Apps with battery usage - tabs daily/weekly
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.battery_charging_full, color: AppColors.warning, size: 18),
                      const SizedBox(width: 8),
                      const Text('Apps con más consumo de batería',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCardLight.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _tabButton('Diario', 0),
                        _tabButton('Semanal', 1),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  batteryUsageAsync.when(
                    data: (apps) {
                      if (apps.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: Center(child: Text('Sin datos de uso', style: TextStyle(color: AppColors.textMuted))),
                        );
                      }
                      return Column(
                        children: apps.asMap().entries.map((entry) {
                          final rank = entry.key + 1;
                          final app = entry.value;
                          final name = app['name'] as String? ?? '';
                          final batteryPercent = app['batteryPercent'] as int? ?? 0;
                          final usageTime = app['usageTime'] as int? ?? 0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 22,
                                  child: Text('$rank',
                                    style: TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.bold,
                                      color: rank <= 3 ? AppColors.warning : AppColors.textMuted,
                                    )),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    color: rank <= 3
                                        ? AppColors.warning.withOpacity(0.2)
                                        : AppColors.primary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.android,
                                    color: rank <= 3 ? AppColors.warning : AppColors.primary, size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name,
                                        style: const TextStyle(color: Colors.white, fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: batteryPercent / 100.0,
                                          minHeight: 3,
                                          backgroundColor: Colors.white.withOpacity(0.08),
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            batteryPercent > 30 ? AppColors.warning : AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text('$batteryPercent%',
                                  style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold,
                                    color: batteryPercent > 30 ? AppColors.warning : Colors.white,
                                  )),
                                const SizedBox(width: 8),
                                Text(_formatDuration(usageTime),
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    error: (_, __) => const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: Text('No disponible', style: TextStyle(color: AppColors.textMuted))),
                    ),
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

  Widget _tabButton(String label, int index) {
    final selected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withOpacity(0.3) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textMuted,
                fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _suggestionTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: AppColors.info, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                  Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  void _openSetting(BuildContext context, WidgetRef ref, String setting) {
    final service = ref.read(deviceServiceProvider);
    switch (setting) {
      case 'display':
        service.openDisplaySettings();
        break;
      case 'wifi':
        service.openWifiSettings();
        break;
      case 'battery_saver':
        service.openBatterySaverSettings();
        break;
    }
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${seconds ~/ 60}m';
    return '${seconds ~/ 3600}h ${(seconds % 3600) ~/ 60}m';
  }
}

final batteryUsageProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, period) async {
  try {
    final service = ref.read(deviceServiceProvider);
    return await service.getBatteryUsageStats(period);
  } catch (_) {
    return [];
  }
});
