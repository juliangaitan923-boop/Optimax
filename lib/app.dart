import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/cleaner/cleaner_screen.dart';
import 'screens/battery/battery_screen.dart';
import 'screens/more/more_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'providers/system_providers.dart';
import 'providers/theme_provider.dart';
import 'services/update_service.dart';
import 'services/app_info.dart';
import 'services/logger_service.dart';
import 'widgets/update_dialogs.dart';

class OptiMaxApp extends ConsumerWidget {
  const OptiMaxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider).mapToThemeMode();
    return MaterialApp(
      title: 'OptiMax',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const _AppEntry(),
    );
  }
}

class _AppEntry extends ConsumerStatefulWidget {
  const _AppEntry();

  @override
  ConsumerState<_AppEntry> createState() => _AppEntryState();
}

enum _AppEntryStateEnum { loading, onboarding, main }

class _AppEntryState extends ConsumerState<_AppEntry> {
  _AppEntryStateEnum _state = _AppEntryStateEnum.loading;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool('onboarding_completed') ?? false;
      if (mounted) {
        setState(() => _state = completed ? _AppEntryStateEnum.main : _AppEntryStateEnum.onboarding);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _state = _AppEntryStateEnum.main);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case _AppEntryStateEnum.loading:
        return const SplashScreen(child: SizedBox());
      case _AppEntryStateEnum.onboarding:
        return const OnboardingScreen();
      case _AppEntryStateEnum.main:
        return const MainShell();
    }
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
    } catch (e) {
      log.e('Update check failed', e);
    }
  }

  void _showUpdateDialog(UpdateInfo info) {
    showDialog(
      context: context,
      builder: (ctx) => UpdateAvailableDialog(
        info: info,
        onDownload: () => _downloadAndInstall(info),
        onSkip: () => UpdateService.skipVersion(info.version),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Instalando actualización...' : 'Error al descargar'),
        backgroundColor: success ? AppColors.success : AppColors.warning,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(tabIndexProvider);
    final safeIndex = currentIndex.clamp(0, _screens.length - 1);
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: KeyedSubtree(
          key: ValueKey(safeIndex),
          child: _screens[safeIndex],
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
            currentIndex: safeIndex,
            onTap: (index) => ref.read(tabIndexProvider.notifier).state = index.clamp(0, 3),
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppTheme.primary,
            unselectedItemColor: AppTheme.textMuted,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            items: List.generate(4, (i) {
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
  const _NavIcon(this.index, {super.key, required this.isSelected});

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


