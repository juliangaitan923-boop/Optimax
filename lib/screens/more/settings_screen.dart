import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers/system_providers.dart';
import '../../providers/theme_provider.dart';
import '../../services/app_settings.dart';
import '../../services/update_service.dart';
import '../../services/app_info.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/update_dialogs.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _settings = AppSettings.instance;
  late bool _autoClean;
  late bool _backgroundMonitor;
  late bool _notifications;

  @override
  void initState() {
    super.initState();
    _autoClean = _settings.getBool('autoClean', defaultValue: true);
    _backgroundMonitor = _settings.getBool('backgroundMonitor', defaultValue: true);
    _notifications = _settings.getBool('notifications', defaultValue: false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _sectionHeader('Apariencia'),
            const SizedBox(height: 8),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: _themeSelector(isDark),
            ),
            const SizedBox(height: 24),
            _sectionHeader('General'),
            const SizedBox(height: 8),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  _switchTile(Icons.auto_delete, 'Limpieza automática', 'Limpiar caché cada 24h', _autoClean, (v) async {
                    setState(() => _autoClean = v);
                    await _settings.setBool('autoClean', v);
                    if (v) {
                      final service = ref.read(deviceServiceProvider);
                      await service.cleanCache();
                    }
                  }),
                  const Divider(color: Colors.white10, height: 1, indent: 50),
                  _switchTile(Icons.monitor_heart, 'Monitor en segundo plano', 'Actualizar datos periódicamente', _backgroundMonitor, (v) async {
                    setState(() => _backgroundMonitor = v);
                    await _settings.setBool('backgroundMonitor', v);
                    if (v) {
                      ref.invalidate(cpuInfoProvider);
                      ref.invalidate(ramInfoProvider);
                      ref.invalidate(storageInfoProvider);
                      ref.invalidate(batteryInfoProvider);
                    }
                  }),
                  const Divider(color: Colors.white10, height: 1, indent: 50),
                  _switchTile(Icons.notifications, 'Notificaciones', 'Alertas de rendimiento y sugerencias', _notifications, (v) async {
                    setState(() => _notifications = v);
                    await _settings.setBool('notifications', v);
                  }),
                  const Divider(color: Colors.white10, height: 1, indent: 50),
                  _switchTile(Icons.sports_esports, 'Modo juego', 'Optimizar al abrir juegos', ref.watch(gameModeProvider), (v) async {
                    final service = ref.read(deviceServiceProvider);
                    if (v) {
                      await service.enableGameMode();
                    } else {
                      await service.disableGameMode();
                    }
                    ref.read(gameModeProvider.notifier).state = v;
                    await _settings.setBool('gameMode', v);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _sectionHeader('Información'),
            const SizedBox(height: 8),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _infoTile('Versión', AppInfo.version),
                  const Divider(color: Colors.white10, height: 16, indent: 100),
                  _infoTile('Desarrollador', 'OptiMax Team'),
                  const Divider(color: Colors.white10, height: 16, indent: 100),
                  _infoTile('Política de privacidad', 'Sin recolección de datos'),
                  const Divider(color: Colors.white10, height: 16, indent: 100),
                  _updateTile(),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _themeSelector(bool isDark) {
    final currentTheme = ref.watch(themeProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              currentTheme == AppThemeMode.light
                  ? Icons.light_mode
                  : currentTheme == AppThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.brightness_auto,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Tema',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          DropdownButton<AppThemeMode>(
            value: currentTheme,
            dropdownColor: AppColors.surfaceCard,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: AppThemeMode.dark, child: Text('Oscuro')),
              DropdownMenuItem(value: AppThemeMode.light, child: Text('Claro')),
              DropdownMenuItem(value: AppThemeMode.system, child: Text('Sistema')),
            ],
            onChanged: (mode) {
              if (mode != null) {
                ref.read(themeProvider.notifier).setTheme(mode);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _switchTile(IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isDark ? Colors.white : AppColors.lightText, fontSize: 14, fontWeight: FontWeight.w500)),
                Text(subtitle, style: TextStyle(color: isDark ? AppColors.textMuted : AppColors.lightTextSecondary, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.4),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary, fontSize: 14)),
          Text(value, style: TextStyle(color: isDark ? Colors.white : AppColors.lightText, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _updateTile() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: _checkForUpdate,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.system_update, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Buscar actualizaciones', style: TextStyle(color: isDark ? Colors.white : AppColors.lightText, fontSize: 14, fontWeight: FontWeight.w500)),
                  Text('Tocar para buscar nueva versión', style: TextStyle(color: isDark ? AppColors.textMuted : AppColors.lightTextSecondary, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: isDark ? AppColors.textMuted : AppColors.lightTextSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  void _checkForUpdate() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const UpdateCheckDialog(),
    );

    final info = await UpdateService.checkForUpdate(AppInfo.version);

    if (!mounted) return;
    Navigator.of(context).pop();

    if (info == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya tienes la última versión'),
          backgroundColor: AppColors.success,
        ),
      );
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => UpdateAvailableDialog(
        info: info,
        onDownload: () {
          Navigator.pop(ctx);
          _downloadAndInstall(info);
        },
        onSkip: () {
          UpdateService.skipVersion(info.version);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Versión saltada'),
                backgroundColor: AppColors.textMuted,
              ),
            );
          }
        },
      ),
    );
  }

  void _downloadAndInstall(UpdateInfo info) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const UpdateProgressDialog(),
    );

    final success = await UpdateService.downloadAndInstall(info);

    if (!mounted) return;
    Navigator.of(context).pop();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Instalando actualización...'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al descargar la actualización'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }
}
