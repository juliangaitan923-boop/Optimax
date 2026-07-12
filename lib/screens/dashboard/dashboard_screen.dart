import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers/system_providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/progress_indicators.dart';
import '../../widgets/alert_card.dart';
import '../../widgets/boost_overlay.dart';
import '../../widgets/history_chart.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final cpuAsync = ref.watch(cpuInfoProvider);
    final ramAsync = ref.watch(ramInfoProvider);
    final storageAsync = ref.watch(storageInfoProvider);
    final batteryAsync = ref.watch(batteryInfoProvider);
    final healthScore = ref.watch(healthScoreProvider);
    final isBoosting = ref.watch(isBoostingProvider);
    final history = ref.watch(historyServiceProvider);

    final cpu = cpuAsync.valueOrNull;
    final ram = ramAsync.valueOrNull;
    final storage = storageAsync.valueOrNull;
    final battery = batteryAsync.valueOrNull;

    final cpuSpots = history.cpuHistory.map((p) => FlSpot(p.time.millisecondsSinceEpoch.toDouble(), p.value)).toList();
    final ramSpots = history.ramHistory.map((p) => FlSpot(p.time.millisecondsSinceEpoch.toDouble(), p.value)).toList();
    final batterySpots = history.batteryHistory.map((p) => FlSpot(p.time.millisecondsSinceEpoch.toDouble(), p.value)).toList();

    // Normalize timestamps to relative seconds for better display
    final now = DateTime.now().millisecondsSinceEpoch.toDouble();
    final cpuSpotsNorm = cpuSpots.map((s) => FlSpot((s.x - now) / 1000, s.y)).toList();
    final ramSpotsNorm = ramSpots.map((s) => FlSpot((s.x - now) / 1000, s.y)).toList();
    final batterySpotsNorm = batterySpots.map((s) => FlSpot((s.x - now) / 1000, s.y)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: const Icon(Icons.speed, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('OptiMax', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: -0.5)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceCardBorder.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => ref.invalidate(cpuInfoProvider),
              color: AppColors.textMuted,
              iconSize: 20,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(cpuInfoProvider);
          ref.invalidate(ramInfoProvider);
          ref.invalidate(storageInfoProvider);
          ref.invalidate(batteryInfoProvider);
          ref.invalidate(healthScoreProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Health Score
              GlassCard(
                child: Column(
                  children: [
                    const Text(AppStrings.healthScore, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    const SizedBox(height: 12),
                    AnimatedCircularScore(score: healthScore),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Resource Cards with sparklines
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ResourceBar(
                            label: AppStrings.cpu,
                            percent: cpu?.usagePercent ?? 0,
                            value: cpu != null ? '${cpu.usagePercent}% · ${cpu.tempFormatted}' : '--',
                            icon: Icons.memory,
                          ),
                        ),
                        const SizedBox(width: 8),
                        MiniSparkline(spots: cpuSpotsNorm, color: AppColors.primary),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ResourceBar(
                            label: AppStrings.ram,
                            percent: ram?.usagePercent ?? 0,
                            value: ram != null ? '${ram.usedFormatted} / ${ram.totalFormatted}' : '--',
                            icon: Icons.data_usage,
                          ),
                        ),
                        const SizedBox(width: 8),
                        MiniSparkline(spots: ramSpotsNorm, color: AppColors.secondary),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ResourceBar(
                      label: AppStrings.storage,
                      percent: storage?.usagePercent ?? 0,
                      value: storage != null ? '${storage.usedFormatted} / ${storage.totalFormatted}' : '--',
                      icon: Icons.storage,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ResourceBar(
                            label: AppStrings.battery,
                            percent: battery?.percent ?? 0,
                            value: battery != null ? '${battery.percent}% · ${battery.tempFormatted}' : '--',
                            icon: Icons.battery_std,
                            color: battery?.isCharging == true ? AppColors.success : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        MiniSparkline(spots: batterySpotsNorm, color: AppColors.warning),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Alerts
              if (ram != null && ram.usagePercent > 70)
                AlertCard(
                  message: '${AppStrings.ram} al ${ram.usagePercent}% — considera liberar memoria',
                  actionLabel: 'Liberar',
                  icon: Icons.memory,
                  onAction: () => _startBoost(context, ref),
                ),
              if (storage != null && storage.usagePercent > 70)
                AlertCard(
                  message: '${AppStrings.storage} al ${storage.usagePercent}% — archivos innecesarios ocupando espacio',
                  actionLabel: 'Limpiar',
                  icon: Icons.storage,
                  color: const Color(0xFFFF8E8E),
                  onAction: () async {
                    final service = ref.read(deviceServiceProvider);
                    await service.cleanCache();
                    ref.invalidate(storageInfoProvider);
                  },
                ),
              if (battery != null && battery.temperature > 40)
                AlertCard(
                  message: 'Batería a ${battery.tempFormatted} — evitar uso intensivo',
                  actionLabel: 'Ver',
                  icon: Icons.thermostat,
                  color: Colors.orange,
                  onAction: () => _goToBattery(context, ref),
                ),

              const SizedBox(height: 16),

              // Boost button
              GradientButton(
                label: AppStrings.boost,
                icon: Icons.bolt,
                isLoading: isBoosting,
                onPressed: isBoosting ? null : () => _startBoost(context, ref),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _goToBattery(BuildContext context, WidgetRef ref) {
    ref.read(tabIndexProvider.notifier).state = 2;
  }

  void _startBoost(BuildContext context, WidgetRef ref) {
    ref.read(isBoostingProvider.notifier).state = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const StepBoostOverlay(),
    );

    ref.read(boostResultProvider.future).then((result) {
      ref.read(isBoostingProvider.notifier).state = false;
      Navigator.of(context).pop();
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => BoostOverlay(result: result),
        );
      }
    }).catchError((_) {
      ref.read(isBoostingProvider.notifier).state = false;
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    });
  }
}
