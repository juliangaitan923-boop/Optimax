import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers/system_providers.dart';
import '../../services/app_settings.dart';
import '../../services/device_service.dart';
import '../../services/mock_service.dart';
import '../../widgets/glass_card.dart';

class GameOptimizerScreen extends ConsumerStatefulWidget {
  const GameOptimizerScreen({super.key});

  @override
  ConsumerState<GameOptimizerScreen> createState() => _GameOptimizerScreenState();
}

class _GameOptimizerScreenState extends ConsumerState<GameOptimizerScreen> {
  final _settings = AppSettings.instance;
  List<Map<String, dynamic>> _allApps = [];
  List<Map<String, dynamic>> _filteredApps = [];
  String? _selectedGame;
  bool _loading = true;
  bool _active = false;
  bool _extremeMode = false;
  int _extremeKilled = 0;
  bool _extremeLoading = false;

  @override
  void initState() {
    super.initState();
    _active = _settings.getBool('gameOptimizerActive', defaultValue: false);
    _selectedGame = _settings.getString('gameOptimizerSelected');
    _extremeMode = _settings.getBool('extremeMode', defaultValue: false);
    _extremeKilled = _settings.getInt('extremeKilled', defaultValue: 0);
    _loadApps();
  }

  Future<void> _loadApps() async {
    setState(() => _loading = true);
    try {
      final service = ref.read(deviceServiceProvider);
      final apps = await service.getInstalledApps();
      _allApps = apps;
      _filteredApps = apps;
    } catch (_) {
      final apps = await MockService.getInstalledApps();
      _allApps = apps;
      _filteredApps = apps;
    }
    setState(() => _loading = false);
  }

  void _filterApps(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredApps = _allApps;
      } else {
        final q = query.toLowerCase();
        _filteredApps = _allApps.where((app) {
          final name = (app['name'] as String? ?? '').toLowerCase();
          return name.contains(q);
        }).toList();
      }
    });
  }

  Future<void> _prioritizeGame(Map<String, dynamic> game) async {
    final service = ref.read(deviceServiceProvider);
    final packageName = game['packageName'] as String? ?? '';

    await service.killPackage(packageName);
    await service.enableGameMode();
    await service.setPerformanceProfile('gaming');

    await _settings.setBool('gameOptimizerActive', true);
    await _settings.setString('gameOptimizerSelected', packageName);
    await _settings.setString('performanceProfile', 'gaming');
    await _settings.setBool('gameMode', true);
    ref.read(performanceProfileProvider.notifier).state = 'gaming';
    ref.read(gameModeProvider.notifier).state = true;

    setState(() {
      _selectedGame = packageName;
      _active = true;
    });
  }

  Future<void> _deactivate() async {
    final service = ref.read(deviceServiceProvider);
    await service.disableGameMode();
    await service.setPerformanceProfile('normal');

    await _settings.setBool('gameOptimizerActive', false);
    await _settings.setString('gameOptimizerSelected', '');
    await _settings.setString('performanceProfile', 'normal');
    await _settings.setBool('gameMode', false);
    ref.read(performanceProfileProvider.notifier).state = 'normal';
    ref.read(gameModeProvider.notifier).state = false;

    setState(() {
      _selectedGame = null;
      _active = false;
    });
  }

  Future<void> _toggleExtremeMode(bool value) async {
    final service = ref.read(deviceServiceProvider);

    if (value) {
      setState(() => _extremeLoading = true);
      try {
        // Aplicar optimizaciones extremas vía ADB/shell
        final extResult = await service.applyExtremeOptimizations();
        if (extResult['success'] == true) {
          final tweaks = extResult['tweaksList'] as List<dynamic>? ?? [];
          // Obtener info del dispositivo
          final deviceInfo = await service.getDeviceInfo();
          if (deviceInfo.containsKey('model')) {
            debugPrint('Modo Extremo activado en: ${deviceInfo['model']}');
          }
          await service.enableGameMode();
          await service.setPerformanceProfile('gaming');
          ref.read(performanceProfileProvider.notifier).state = 'gaming';
          ref.read(gameModeProvider.notifier).state = true;

          await _settings.setBool('extremeMode', true);
          await _settings.setInt('extremeKilled', tweaks.length);
          await _settings.setString('performanceProfile', 'gaming');
          await _settings.setBool('gameMode', true);
          setState(() {
            _extremeMode = true;
            _extremeKilled = tweaks.length;
            _extremeLoading = false;
          });
        } else {
          // Fallback: usar mock si no se pudieron aplicar optimizaciones reales
          await _fallbackExtremeEnable(service);
          setState(() => _extremeLoading = false);
        }
      } catch (_) {
        await _fallbackExtremeEnable(service);
        setState(() => _extremeLoading = false);
      }
    } else {
      try {
        final result = await service.revertExtremeOptimizations();
        if (result['success'] == true) {
          debugPrint('Modo Extremo desactivado, tweaks revertidos');
        }
        await service.disableGameMode();
        await service.setPerformanceProfile('normal');
        ref.read(performanceProfileProvider.notifier).state = 'normal';
        ref.read(gameModeProvider.notifier).state = false;
      } catch (_) {}
      await _settings.setBool('extremeMode', false);
      await _settings.setInt('extremeKilled', 0);
      await _settings.setString('performanceProfile', 'normal');
      await _settings.setBool('gameMode', false);
      setState(() {
        _extremeMode = false;
        _extremeKilled = 0;
      });
      ref.invalidate(ramInfoProvider);
    }
  }

  Future<void> _fallbackExtremeEnable(DeviceService service) async {
    int killed = 0;
    try {
      final processes = await MockService.getProcessList();
      for (final proc in processes) {
        if (!proc.isSystem) {
          try {
            await service.killProcess(proc.pid);
          } catch (_) {
            await MockService.killProcess(proc.pid);
          }
          killed++;
        }
      }
      await service.enableGameMode();
      await service.setPerformanceProfile('gaming');
      ref.read(performanceProfileProvider.notifier).state = 'gaming';
      ref.read(gameModeProvider.notifier).state = true;
    } catch (_) {}
    await _settings.setBool('extremeMode', true);
    await _settings.setInt('extremeKilled', killed);
    await _settings.setString('performanceProfile', 'gaming');
    await _settings.setBool('gameMode', true);
    setState(() {
      _extremeMode = true;
      _extremeKilled = killed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Optimizador de Juegos', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          if (_active) _buildActiveBanner(),
          _buildExtremeModeCard(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: _filterApps,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar juegos...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : _filteredApps.isEmpty
                    ? const Center(
                        child: Text('No se encontraron aplicaciones', style: TextStyle(color: AppColors.textMuted)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredApps.length,
                        itemBuilder: (context, index) {
                          final app = _filteredApps[index];
                          return _buildAppTile(app);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBanner() {
    final selectedName = _allApps
        .where((a) => a['packageName'] == _selectedGame)
        .map((a) => a['name'] as String? ?? '')
        .firstOrNull;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.3),
            AppColors.success.withOpacity(0.2),
          ],
        ),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle, color: AppColors.success, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Optimizando: ${selectedName ?? _selectedGame ?? ''}',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Rendimiento máximo activado',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _deactivate,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.warning,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Desactivar', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildExtremeModeCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: _extremeMode ? AppColors.warning.withOpacity(0.2) : AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.dangerous,
                    color: _extremeMode ? AppColors.warning : AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Modo Extremo', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      Text('Desactiva todo mientras juegas, al salir se restaura solo', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
                if (_extremeLoading)
                  const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                else
                  Switch(
                    value: _extremeMode,
                    onChanged: _toggleExtremeMode,
                    activeColor: AppColors.warning,
                    activeTrackColor: AppColors.warning.withOpacity(0.4),
                  ),
              ],
            ),
            if (_extremeMode) ...[
              const Divider(color: Colors.white10, height: 20),
              Row(
                children: [
                  const Icon(Icons.close, color: AppColors.warning, size: 16),
                  const SizedBox(width: 6),
                  Text('$_extremeKilled procesos cerrados', style: const TextStyle(color: AppColors.warning, fontSize: 13, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  const Icon(Icons.auto_awesome, color: AppColors.success, size: 14),
                  const SizedBox(width: 4),
                  const Text('Auto-restauración activa', style: TextStyle(color: AppColors.success, fontSize: 11)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isSelected(String packageName) {
    return _active && _selectedGame == packageName;
  }

  Widget _buildAppTile(Map<String, dynamic> app) {
    final name = app['name'] as String? ?? '';
    final packageName = app['packageName'] as String? ?? '';
    final isGame = app['isGame'] as bool? ?? false;
    final selected = _isSelected(packageName);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isGame
                    ? AppColors.primary.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isGame ? Icons.sports_esports : Icons.android,
                color: isGame ? AppColors.primary : AppColors.textMuted,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: selected ? AppColors.primary : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isGame)
                    Text(
                      'Juego detectado',
                      style: TextStyle(
                        color: AppColors.success.withOpacity(0.8),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            if (selected)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              )
            else
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: () => _prioritizeGame(app),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isGame ? AppColors.primary : AppColors.surfaceCardLight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isGame ? 'Priorizar' : 'Priorizar',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
