import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../../core/theme_colors.dart';

class PermissionGuideScreen extends ConsumerStatefulWidget {
  final VoidCallback? onCompleted;
  const PermissionGuideScreen({super.key, this.onCompleted});

  @override
  ConsumerState<PermissionGuideScreen> createState() => _PermissionGuideScreenState();
}

class _PermissionGuideScreenState extends ConsumerState<PermissionGuideScreen> {
  final _permissions = <_PermissionItem>[
    _PermissionItem(
      icon: Icons.list_alt,
      title: 'Acceso a estadísticas de uso',
      desc: 'Permite medir qué apps consumen más recursos. Debes activarlo manualmente en Ajustes.',
    ),
    _PermissionItem(
      icon: Icons.install_mobile,
      title: 'Instalar actualizaciones',
      desc: 'Permite instalar automáticamente las nuevas versiones.',
    ),
    _PermissionItem(
      icon: Icons.notifications,
      title: 'Notificaciones',
      desc: 'Recibe alertas de rendimiento y sugerencias.',
    ),
  ];

  final _granted = <int>{};

  @override
  void initState() {
    super.initState();
    _checkAll();
  }

  Future<void> _checkAll() async {
    final notif = await ph.Permission.notification.status;
    final install = await ph.Permission.requestInstallPackages.status;
    if (mounted) {
      setState(() {
        if (notif.isGranted) _granted.add(2);
        if (install.isGranted) _granted.add(1);
      });
    }
  }

  Future<void> _request(int index) async {
    if (index == 0) {
      await ph.openAppSettings();
    } else if (index == 1) {
      final status = await ph.Permission.requestInstallPackages.request();
      if (status.isGranted && mounted) setState(() => _granted.add(index));
    } else {
      final status = await ph.Permission.notification.request();
      if (status.isGranted && mounted) setState(() => _granted.add(index));
    }
    await _checkAll();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('permissions_guided', true);
    if (mounted) {
      widget.onCompleted?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context;
    return Scaffold(
      backgroundColor: c.surfaceDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Permisos necesarios',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Concede estos permisos para que OptiMax funcione correctamente',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: _permissions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final item = _permissions[i];
                    final done = _granted.contains(i);
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: c.surfaceCard,
                        border: Border.all(
                          color: done ? AppColors.success.withOpacity(0.3) : c.surfaceCardBorder.withOpacity(0.3),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: done ? AppColors.success.withOpacity(0.15) : AppColors.primary.withOpacity(0.12),
                              ),
                              child: Icon(
                                done ? Icons.check : item.icon,
                                color: done ? AppColors.success : AppColors.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.title, style: TextStyle(color: c.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(item.desc, style: TextStyle(color: c.textMuted, fontSize: 12)),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: done ? null : () => _request(i),
                              style: TextButton.styleFrom(
                                foregroundColor: done ? AppColors.success : AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              child: Text(done ? 'Hecho' : 'Conceder'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _finish,
                  child: const Text('Comenzar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionItem {
  final IconData icon;
  final String title;
  final String desc;
  const _PermissionItem({required this.icon, required this.title, required this.desc});
}
