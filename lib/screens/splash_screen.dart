import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconScale;
  late Animation<double> _iconFade;
  late Animation<double> _textSlide;
  late Animation<double> _textFade;
  late Animation<double> _taglineFade;
  late Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    );

    _iconFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.4, curve: Curves.easeOut),
    );
    _iconScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.5, curve: Curves.easeOutBack),
    );
    _glowPulse = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOutSine),
    );
    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
    );
    _textSlide = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
    );
    _taglineFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDark,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glow behind icon
                AnimatedBuilder(
                  animation: _glowPulse,
                  builder: (_, child) => Container(
                    width: 120 + 20 * sin(_glowPulse.value * pi).abs(),
                    height: 120 + 20 * sin(_glowPulse.value * pi).abs(),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.15 + 0.15 * sin(_glowPulse.value * pi).abs()),
                          blurRadius: 40 + 20 * sin(_glowPulse.value * pi).abs(),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: child,
                  ),
                  child: FadeTransition(
                    opacity: _iconFade,
                    child: ScaleTransition(
                      scale: _iconScale,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.bolt, size: 52, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Title
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(_textSlide),
                    child: const Text(
                      'OptiMax',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Tagline
                FadeTransition(
                  opacity: _taglineFade,
                  child: Text(
                    'Acelerador Inteligente',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary.withOpacity(0.8),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Loading indicator at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 60,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
