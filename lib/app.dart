import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/cleaner/cleaner_screen.dart';
import 'screens/battery/battery_screen.dart';
import 'screens/more/more_screen.dart';
import 'providers/system_providers.dart';
import 'services/update_service.dart';
import 'services/app_info.dart';
import 'widgets/glass_card.dart';

class OptiMaxApp extends ConsumerWidget {
  const OptiMaxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'OptiMax',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainShell(),
    );
  }
}

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  bool _updateChecked = false;

  final List<Widget> _screens = const [
    DashboardScreen(),
    CleanerScreen(),
    BatteryScreen(),
    MoreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkUpdate();
  }

  void _checkUpdate() async {
    if (_updateChecked) return;
    _updateChecked = true;
    try {
      final info = await UpdateService.checkForUpdate(AppInfo.version);
      if (info != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nueva versión ${info.version} disponible'),
            action: SnackBarAction(
              label: 'Actualizar',
              textColor: AppColors.primary,
              onPressed: () => _showUpdateDialog(info),
            ),
            backgroundColor: AppColors.surfaceCard,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } catch (_) {}
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
            Text('Versión: ${info.version}', style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(info.changelog, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              UpdateService.skipVersion(info.version);
            },
            child: const Text('Saltar versión', style: TextStyle(color: AppColors.textMuted)),
          ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Instalando actualización...' : 'Error al descargar'),
        backgroundColor: success ? AppColors.success : AppColors.warning,
      ),
    );
  }

  @override
  void dispose() {
    _updateChecked = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(tabIndexProvider);
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: KeyedSubtree(
          key: ValueKey(currentIndex),
          child: _screens[currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              AppColors.surfaceCard.withOpacity(0.92),
              AppColors.surfaceDark.withOpacity(0.88),
            ],
          ),
          border: Border.all(color: AppColors.surfaceCardBorder.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) => ref.read(tabIndexProvider.notifier).state = index,
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppTheme.primary,
            unselectedItemColor: AppTheme.textMuted,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            items: List.generate(4, (i) {
              final isSelected = currentIndex == i;
              return BottomNavigationBarItem(
                icon: _NavIcon(i, isSelected: false),
                activeIcon: _NavIcon(i, isSelected: true),
                label: _navLabels[i],
              );
            }),
          ),
        ),
      ),
    );
  }
}

const _navIcons = [
  Icons.speed,
  Icons.cleaning_services_outlined,
  Icons.battery_std_outlined,
  Icons.more_horiz_outlined,
];

const _navLabels = ['Dashboard', 'Limpiar', 'Batería', 'Más'];

class _NavIcon extends StatelessWidget {
  final int index;
  final bool isSelected;
  const _NavIcon(this.index, {required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: isSelected
          ? BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            )
          : null,
      child: Icon(
        _navIcons[index],
        size: 22,
        color: isSelected ? Colors.white : null,
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
