import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../services/update_service.dart';
import 'glass_card.dart';

class UpdateCheckDialog extends StatelessWidget {
  const UpdateCheckDialog({super.key});

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

class UpdateProgressDialog extends StatelessWidget {
  const UpdateProgressDialog({super.key});

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

class UpdateAvailableDialog extends StatelessWidget {
  final UpdateInfo info;
  final VoidCallback onDownload;
  final VoidCallback? onSkip;

  const UpdateAvailableDialog({
    super.key,
    required this.info,
    required this.onDownload,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Row(
        children: [
          Icon(Icons.system_update, color: AppColors.primary, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text('Actualización disponible',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
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
        if (onSkip != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onSkip!();
            },
            child: const Text('Saltar versión', style: TextStyle(color: AppColors.textMuted)),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Más tarde', style: TextStyle(color: AppColors.textMuted)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            Navigator.pop(context);
            onDownload();
          },
          child: const Text('Actualizar ahora'),
        ),
      ],
    );
  }
}
