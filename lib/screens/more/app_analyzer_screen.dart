import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers/system_providers.dart';
import '../../widgets/glass_card.dart';

class AppAnalyzerScreen extends ConsumerWidget {
  const AppAnalyzerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final processesAsync = ref.watch(processListProvider);
    final topAppsAsync = ref.watch(topAppsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analizador de Apps', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.timeline, color: AppColors.primary, size: 18),
                      SizedBox(width: 8),
                      Text('Apps más usadas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  topAppsAsync.when(
                    data: (apps) => Column(
                      children: apps.asMap().entries.map((entry) {
                        final rank = entry.key + 1;
                        final app = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: rank <= 3 ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text('$rank', style: TextStyle(
                                    color: rank <= 3 ? AppColors.primary : AppColors.textMuted,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  )),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceCardLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.android, color: AppColors.textMuted, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(app['name'] as String? ?? '', style: const TextStyle(color: Colors.white, fontSize: 14)),
                              ),
                              Text(
                                _formatDuration((app['usageTime'] as int?) ?? 0),
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    error: (_, __) => const Text('No disponible', style: TextStyle(color: AppColors.textMuted)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.settings_applications, color: AppColors.info, size: 18),
                      SizedBox(width: 8),
                      Text('Procesos activos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  processesAsync.when(
                    data: (processes) {
                      if (processes.isEmpty) {
                        return const Text('Sin datos', style: TextStyle(color: AppColors.textMuted));
                      }
                      return Column(
                        children: processes.map((p) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: p.isSystem ? AppColors.warning : AppColors.success,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 13)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceCardLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  p.importanceLabel,
                                  style: TextStyle(
                                    color: p.isSystem ? AppColors.warning : AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      );
                    },
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

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${seconds ~/ 60}m';
    return '${seconds ~/ 3600}h ${(seconds % 3600) ~/ 60}m';
  }
}
