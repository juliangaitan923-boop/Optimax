import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/theme_colors.dart';
import '../../models/process_info.dart';
import '../../providers/system_providers.dart';
import '../../services/mock_service.dart';
import '../../widgets/boost_overlay.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';

class AcceleratorScreen extends ConsumerStatefulWidget {
  const AcceleratorScreen({super.key});

  @override
  ConsumerState<AcceleratorScreen> createState() => _AcceleratorScreenState();
}

class _AcceleratorScreenState extends ConsumerState<AcceleratorScreen> {
  List<ProcessInfo> _processes = [];
  bool _loading = true;
  bool _boosting = false;
  int _totalToKill = 0;
  int _killedSoFar = 0;
  Timer? _realtimeTimer;

  @override
  void initState() {
    super.initState();
    _loadProcesses();
    _startRealtimeMonitor();
  }

  @override
  void dispose() {
    _realtimeTimer?.cancel();
    super.dispose();
  }

  void _startRealtimeMonitor() {
    _realtimeTimer?.cancel();
    _realtimeTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!_boosting && mounted) {
        _loadProcesses();
      }
    });
  }

  Future<void> _loadProcesses() async {
    try {
      final service = ref.read(deviceServiceProvider);
      final processes = await service.getProcessList();
      if (processes.isEmpty) {
        final mock = await MockService.getProcessList();
        if (mounted) setState(() => _processes = mock);
      } else {
        if (mounted) setState(() => _processes = processes);
      }
    } catch (_) {
      final mock = await MockService.getProcessList();
      if (mounted) setState(() => _processes = mock);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _boost() async {
    setState(() {
      _boosting = true;
      _killedSoFar = 0;
      _totalToKill = _processes.where((p) => !p.isSystem).length;
    });

    final service = ref.read(deviceServiceProvider);
    Map<String, dynamic> result;

    try {
      result = await service.deepBoost();
    } catch (_) {
      result = await MockService.ramBoost();
    }

    final ramFreedBytes = result['ramFreed'] as int? ?? 0;
    final processesKilled = result['processesKilled'] as int? ?? 0;

    setState(() {
      _killedSoFar = processesKilled;
      _totalToKill = processesKilled;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    ref.invalidate(ramInfoProvider);
    setState(() => _boosting = false);
    _loadProcesses();

    if (!mounted) return;
    showDialog(
      context: context,
          builder: (ctx) => BoostOverlay(result: {
            'ramFreed': ramFreedBytes,
            'cacheFreed': 0,
            'processesKilled': processesKilled,
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ramAsync = ref.watch(ramInfoProvider);
    final ram = ramAsync.valueOrNull;

    final killableProcesses = _processes.where((p) => !p.isSystem).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acelerador', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // RAM status en vivo
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.bolt, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Acelerar dispositivo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.textPrimary)),
                        const SizedBox(height: 4),
                        Text(
                          ram != null
                              ? 'RAM: ${ram.usedFormatted} / ${ram.totalFormatted} (${ram.usagePercent}%)'
                              : 'Cargando...',
                          style: TextStyle(fontSize: 13, color: context.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // RAM gauge en tiempo real
            if (ram != null)
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Memoria RAM', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.textPrimary)),
                        Text(
                          '${ram.usagePercent}% usado',
                          style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold,
                            color: ram.usagePercent > 70 ? AppColors.warning : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: ram.usagePercent / 100.0,
                        minHeight: 12,
                        backgroundColor: context.backgroundColor(0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ram.usagePercent > 70 ? AppColors.warning : AppColors.success,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Usado: ${ram.usedFormatted}', style: TextStyle(fontSize: 12, color: context.textMuted)),
                        Text('${killableProcesses.length} procesos cerrables', style: TextStyle(fontSize: 12, color: context.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Deep Boost button
            _boosting
                ? GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 40, width: 40,
                          child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
                        ),
                        const SizedBox(height: 12),
                        Text('Acelerando a fondo... $_killedSoFar procesos cerrados',
                          style: TextStyle(color: context.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _totalToKill > 0 ? (_killedSoFar / _totalToKill).clamp(0.0, 1.0) : 0,
                            minHeight: 6,
                            backgroundColor: context.backgroundColor(0.05),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('$_killedSoFar / $_totalToKill procesos',
                          style: TextStyle(fontSize: 12, color: context.textMuted)),
                      ],
                    ),
                  )
                : GradientButton(
                    label: killableProcesses.isNotEmpty
                        ? 'Acelerar a fondo (${killableProcesses.length} procesos)'
                        : 'Acelerar a fondo',
                    icon: Icons.bolt,
                    isLoading: _boosting,
                    onPressed: _boosting ? null : _boost,
                  ),
            const SizedBox(height: 16),

            // Process list en tiempo real
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.settings_applications, color: AppColors.info, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Procesos del sistema', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.textPrimary)),
                      ),
                      if (!_loading)
                        Text('${_processes.length} activos', style: TextStyle(fontSize: 12, color: context.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_loading)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ))
                  else if (_processes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(child: Text('No hay procesos disponibles', style: TextStyle(color: context.textMuted))),
                    )
                  else
                    ..._processes.map((proc) => _processTile(proc)),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _processTile(ProcessInfo proc) {
    final canKill = !proc.isSystem;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: canKill ? AppColors.primary.withOpacity(0.15) : context.backgroundColor(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                proc.isSystem ? Icons.security : Icons.android,
                color: canKill ? AppColors.primary : context.textMuted,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(proc.name, style: TextStyle(color: canKill ? context.textPrimary : context.textMuted, fontSize: 14, fontWeight: FontWeight.w500)),
                  Text(proc.importanceLabel, style: TextStyle(color: context.textMuted, fontSize: 11)),
                ],
              ),
            ),
            if (!canKill)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Sistema', style: TextStyle(color: AppColors.warning, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
          ],
        ),
      ),
    );
  }
}


