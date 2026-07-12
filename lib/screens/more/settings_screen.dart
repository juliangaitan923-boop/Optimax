import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers/system_providers.dart';
import '../../services/app_settings.dart';
import '../../services/update_service.dart';
import '../../services/app_info.dart';
import '../../widgets/glass_card.dart';

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
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _updateTile() {
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
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Buscar actualizaciones', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                  Text('Tocar para buscar nueva versión', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  void _checkForUpdate() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _UpdateCheckDialog(),
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
    _showUpdateDialog(info);
  }

  void _showUpdateDialog(UpdateInfo info) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.system_update, color: AppColors.primary, size: 28),
            SizedBox(width: 12),
            Text('Actualización disponible', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versión: ${info.version}',
              style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              info.changelog,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Más tarde', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _downloadAndInstall(info);
            },
            child: const Text('Actualizar ahora'),
          ),
        ],
      ),
    );
  }

  void _downloadAndInstall(UpdateInfo info) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _UpdateProgressDialog(),
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

class _UpdateCheckDialog extends StatelessWidget {
  const _UpdateCheckDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        padding: const EdgeInsets.all(32),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Buscando actualizaciones...',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdateProgressDialog extends StatelessWidget {
  const _UpdateProgressDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        padding: const EdgeInsets.all(32),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Descargando actualización...',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
