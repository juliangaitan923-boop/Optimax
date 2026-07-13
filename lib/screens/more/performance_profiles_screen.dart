import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/theme_colors.dart';
import '../../providers/system_providers.dart';
import '../../services/app_settings.dart';

class PerformanceProfilesScreen extends ConsumerWidget {
  const PerformanceProfilesScreen({super.key});

  static const _profiles = [
    _ProfileData('normal', Icons.balance, 'Normal', 'Rendimiento equilibrado para uso diario'),
    _ProfileData('ahorro', Icons.battery_charging_full, 'Ahorro', 'Reduce consumo de batería al máximo'),
    _ProfileData('gaming', Icons.sports_esports, 'Gaming', 'Máximo rendimiento para juegos'),
    _ProfileData('personalizado', Icons.tune, 'Personalizado', 'Configuración manual ajustable'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentProfile = ref.watch(performanceProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfiles de rendimiento', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Selecciona un perfil',
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ..._profiles.map((profile) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ProfileCard(
                data: profile,
                isSelected: currentProfile == profile.id,
                onTap: () async {
                  ref.read(performanceProfileProvider.notifier).state = profile.id;
                  await AppSettings.instance.setString('performanceProfile', profile.id);
                  final service = ref.read(deviceServiceProvider);
                  await service.setPerformanceProfile(profile.id);
                },
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _ProfileData {
  final String id;
  final IconData icon;
  final String name;
  final String description;

  const _ProfileData(this.id, this.icon, this.name, this.description);
}

class _ProfileCard extends StatelessWidget {
  final _ProfileData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProfileCard({
    super.key,
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? AppColors.primary : Colors.transparent;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.5),
          gradient: LinearGradient(
            colors: [
              context.surfaceCard,
              context.surfaceCard.withOpacity(0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  data.icon,
                  color: isSelected ? Colors.white : AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : context.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.description,
                      style: TextStyle(
                        color: context.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
