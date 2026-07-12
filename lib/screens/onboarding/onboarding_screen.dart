import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPage(
      icon: Icons.speed,
      title: 'Monitoreo en Tiempo Real',
      description: 'Monitorea CPU, RAM, almacenamiento y temperatura de batería en tiempo real',
    ),
    _OnboardingPage(
      icon: Icons.cleaning_services_outlined,
      title: 'Limpieza Inteligente',
      description: 'Elimina caché, archivos temporales y libera almacenamiento con un solo toque',
    ),
    _OnboardingPage(
      icon: Icons.battery_std_outlined,
      title: 'Optimizador de Batería',
      description: 'Extiende la vida de la batería con perfiles inteligentes de ahorro',
    ),
    _OnboardingPage(
      icon: Icons.bolt,
      title: 'One-Tap Boost',
      description: 'Mejora el rendimiento al instante con un solo toque. Sin complicaciones.',
    ),
  ];

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: _pages.map((p) => _PageContent(page: p)).toList(),
            ),
          ),
          _buildBottom(isDark),
        ],
      ),
    );
  }

  Widget _buildBottom(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            (isDark ? AppColors.surfaceDark : AppColors.lightBackground).withOpacity(0.9),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (i) => AnimatedContainer(
                duration: AppDurations.animationDuration,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == i ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _currentPage == i
                      ? AppColors.primary
                      : (isDark ? AppColors.textMuted : AppColors.lightBorder),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              if (_currentPage < _pages.length - 1)
                TextButton(
                  onPressed: _complete,
                  child: Text(
                    'Saltar',
                    style: TextStyle(
                      color: isDark ? AppColors.textMuted : AppColors.lightTextSecondary,
                    ),
                  ),
                )
              else
                const SizedBox(),
              const Spacer(),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _controller.nextPage(
                        duration: AppDurations.animationDuration,
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _complete();
                    }
                  },
                  child: Text(
                    _currentPage < _pages.length - 1 ? 'Siguiente' : 'Comenzar',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _PageContent extends StatelessWidget {
  final _OnboardingPage page;

  const _PageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(page.icon, size: 56, color: Colors.white),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: isDark ? Colors.white : AppColors.lightText,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
