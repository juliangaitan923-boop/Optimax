import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../providers/cleaner_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/progress_indicators.dart';
import '../../widgets/gradient_button.dart';
import '../../models/cleanup_item.dart';

class CleanerScreen extends ConsumerStatefulWidget {
  const CleanerScreen({super.key});

  @override
  ConsumerState<CleanerScreen> createState() => _CleanerScreenState();
}

class _CleanerScreenState extends ConsumerState<CleanerScreen> {
  @override
  Widget build(BuildContext context) {
    final scanAsync = ref.watch(scanResultProvider);
    final isCleaning = ref.watch(cleaningInProgressProvider);
    final selected = ref.watch(selectedItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.cleaning_services, color: AppColors.secondary),
            SizedBox(width: 8),
            Text('Limpiador', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
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
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.info, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Escanea y elimina archivos innecesarios para liberar espacio y mejorar el rendimiento.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (scanAsync.isLoading)
                    const Column(
                      children: [
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                        SizedBox(height: 8),
                        Text('Escaneando...', style: TextStyle(color: AppColors.textMuted)),
                      ],
                    )
                  else
                    GradientButton(
                      label: 'Escanear ahora',
                      icon: Icons.search,
                      onPressed: () => ref.invalidate(scanResultProvider),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            scanAsync.when(
              data: (items) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Archivos encontrados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                      const Spacer(),
                      Text('${items.length} archivos', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...items.map((item) => _CleanupItemCard(
                    item: item,
                    isSelected: selected.contains(item.id),
                    onToggle: () {
                      final current = Set<String>.from(selected);
                      if (current.contains(item.id)) {
                        current.remove(item.id);
                      } else {
                        current.add(item.id);
                      }
                      ref.read(selectedItemsProvider.notifier).state = current;
                    },
                  )),
                  if (items.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    GradientButton(
                      label: 'Limpiar ${selected.length} seleccionados',
                      icon: Icons.delete_sweep,
                      isLoading: isCleaning,
                      onPressed: isCleaning ? null : () => _startCleaning(context),
                    ),
                  ],
                ],
              ),
              loading: () => const Column(
                children: [
                  SkeletonCard(),
                  SkeletonCard(),
                  SkeletonCard(),
                ],
              ),
              error: (err, _) => GlassCard(
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.warning, size: 40),
                      const SizedBox(height: 8),
                      Text('Error: $err', style: const TextStyle(color: AppColors.textMuted)),
                      const SizedBox(height: 8),
                      TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ref.invalidate(scanResultProvider);
                      },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _startCleaning(BuildContext context) {
    final selected = ref.read(selectedItemsProvider);
    if (selected.isEmpty) return;

    HapticFeedback.mediumImpact();
    ref.read(cleaningInProgressProvider.notifier).state = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _CleaningDialog(),
    );

    ref.read(cleanResultProvider.future).then((freed) {
      ref.read(cleaningInProgressProvider.notifier).state = false;
      if (context.mounted) {
        Navigator.of(context).pop();
        ref.invalidate(scanResultProvider);
        ref.read(selectedItemsProvider.notifier).state = {};
        _showResult(context, freed);
      }
    }).catchError((_) {
      ref.read(cleaningInProgressProvider.notifier).state = false;
      if (context.mounted) Navigator.of(context).pop();
    });
  }

  void _showResult(BuildContext context, int freed) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 56),
            const SizedBox(height: 16),
            const Text('¡Limpieza completada!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            Text('Espacio liberado: ${formatBytes(freed)}', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _CleanupItemCard extends StatelessWidget {
  final CleanupItem item;
  final bool isSelected;
  final VoidCallback onToggle;

  const _CleanupItemCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.surfaceCard,
        border: Border.all(
          color: isSelected ? AppColors.primary.withOpacity(0.5) : Colors.transparent,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(item.category, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
                Text(item.sizeFormatted, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(width: 8),
                Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CleaningDialog extends StatelessWidget {
  const _CleaningDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 60,
              width: 60,
              child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.secondary),
            ),
            SizedBox(height: 24),
            Text('Limpiando archivos...', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('Eliminando archivos innecesarios de forma segura', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
