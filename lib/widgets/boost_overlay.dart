import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants.dart';

class BoostOverlay extends StatelessWidget {
  final Map<String, dynamic> result;

  const BoostOverlay({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final ramFreed = result['ramFreed'] as int? ?? 0;
    final cacheFreed = result['cacheFreed'] as int? ?? 0;
    final processesKilled = result['processesKilled'] as int? ?? 0;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCardContent(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 64),
            const SizedBox(height: 16),
            const Text(
              '¡Optimización completada!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 24),
            _buildResultRow(Icons.memory, 'RAM liberada', _formatBytes(ramFreed)),
            const SizedBox(height: 12),
            _buildResultRow(Icons.cleaning_services, 'Caché limpiada', _formatBytes(cacheFreed)),
            const SizedBox(height: 12),
            _buildResultRow(Icons.close, 'Procesos cerrados', '$processesKilled'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class StepBoostOverlay extends StatefulWidget {
  const StepBoostOverlay({super.key});

  @override
  State<StepBoostOverlay> createState() => _StepBoostOverlayState();
}

class _StepBoostOverlayState extends State<StepBoostOverlay> {
  int _currentStep = 0;
  late Timer _timer;

  final _steps = [
    ('Liberando RAM...', Icons.memory),
    ('Limpiando caché...', Icons.cleaning_services),
    ('Cerrando procesos innecesarios...', Icons.close),
    ('Verificando resultado...', Icons.check_circle),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      if (_currentStep < _steps.length - 1) {
        setState(() => _currentStep++);
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCardContent(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 56,
              width: 56,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _steps[_currentStep].$1,
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            ..._steps.asMap().entries.map((entry) {
              final i = entry.key;
              final step = entry.value;
              final isDone = i < _currentStep;
              final isCurrent = i == _currentStep;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Icon(
                      isDone ? Icons.check_circle : isCurrent ? Icons.play_circle : Icons.radio_button_unchecked,
                      color: isDone ? AppColors.success : isCurrent ? AppColors.primary : AppColors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Icon(step.$2, color: isDone || isCurrent ? Colors.white : AppColors.textMuted, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      step.$1,
                      style: TextStyle(
                        color: isDone || isCurrent ? Colors.white : AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class GlassCardContent extends StatelessWidget {
  final Widget child;

  const GlassCardContent({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceCard.withOpacity(0.95),
            AppColors.surfaceDark.withOpacity(0.95),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: child,
    );
  }
}
