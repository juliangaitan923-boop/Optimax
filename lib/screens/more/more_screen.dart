import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/theme_colors.dart';
import '../../services/app_info.dart';
import '../../widgets/glass_card.dart';
import 'app_analyzer_screen.dart';
import 'storage_analyzer_screen.dart';
import 'settings_screen.dart';
import 'performance_profiles_screen.dart';
import 'game_optimizer_screen.dart';
import 'cpu_monitor_screen.dart';
import 'accelerator_screen.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.more_horiz, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Más', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
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
              GlassCard(
                  onTap: () => _navigate(context, const AcceleratorScreen()),
                  child: _menuItem(context, Icons.bolt, 'Acelerador', 'Libera RAM y cierra procesos innecesarios'),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  onTap: () => _navigate(context, const AppAnalyzerScreen()),
                  child: _menuItem(context, Icons.analytics, 'Analizador de Apps', 'Consumo, uso y rendimiento de aplicaciones'),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  onTap: () => _navigate(context, const CpuMonitorScreen()),
                  child: _menuItem(context, Icons.memory, 'Monitor de CPU y RAM', 'Gráficos en tiempo real de rendimiento'),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  onTap: () => _navigate(context, const StorageAnalyzerScreen()),
                  child: _menuItem(context, Icons.storage, 'Almacenamiento', 'Distribución y análisis de archivos'),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  onTap: () => _navigate(context, const GameOptimizerScreen()),
                  child: _menuItem(context, Icons.sports_esports, 'Optimizador de Juegos', 'Selecciona juegos y prioriza todo el hardware'),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  onTap: () => _navigate(context, const PerformanceProfilesScreen()),
                  child: _menuItem(context, Icons.tune, 'Perfiles de rendimiento', 'Normal · Ahorro · Gaming · Personalizado'),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  onTap: () => _navigate(context, const SettingsScreen()),
                  child: _menuItem(context, Icons.settings, 'Ajustes', 'Configuración de la app'),
                ),
            const SizedBox(height: 12),
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: context.textMuted, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('OptiMax v${AppInfo.version}', style: TextStyle(color: context.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(
                            'Optimiza tu dispositivo sin modificarlo',
                            style: TextStyle(color: context.textMuted.withOpacity(0.7), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: context.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: context.textMuted, fontSize: 12)),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: context.textMuted, size: 20),
      ],
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
