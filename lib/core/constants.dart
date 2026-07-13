import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF7C6FFF);
  static const primaryLight = Color(0xFF9D95FF);
  static const primaryDark = Color(0xFF5A4FE0);
  static const secondary = Color(0xFF00E5A0);
  static const secondaryLight = Color(0xFF50F5C0);
  static const warning = Color(0xFFFF6B6B);
  static const warningLight = Color(0xFFFF8E8E);
  static const surfaceDark = Color(0xFF0A0A1A);
  static const surfaceMid = Color(0xFF111128);
  static const surfaceCard = Color(0xFF161633);
  static const surfaceCardLight = Color(0xFF1E1E42);
  static const surfaceCardBorder = Color(0xFF2A2A5A);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB8B8D0);
  static const textMuted = Color(0xFF6B6B8D);
  static const success = Color(0xFF00E5A0);
  static const info = Color(0xFF60CFFF);
  static const gradientStart = Color(0xFF7C6FFF);
  static const gradientEnd = Color(0xFF00E5A0);

  static const lightBackground = Color(0xFFF5F5FA);
  static const lightCard = Colors.white;
  static const lightText = Color(0xFF1A1A2E);
  static const lightTextSecondary = Color(0xFF444466);
  static const lightBorder = Color(0xFFE0E0F0);
}

class AppStrings {
  static const appName = 'OptiMax';
  static const boost = 'Optimizar ahora';
  static const cleaning = 'Limpiando...';
  static const scan = 'Escanear';
  static const done = 'Completado';
  static const cpu = 'CPU';
  static const ram = 'RAM';
  static const storage = 'Almacenamiento';
  static const battery = 'Batería';
  static const score = 'Puntuación';
  static const healthScore = 'Salud del sistema';
}

const batteryTabIndex = 2;

class AppDurations {
  static const scanDuration = Duration(seconds: 2);
  static const boostDuration = Duration(seconds: 3);
  static const refreshInterval = Duration(seconds: 5);
  static const animationDuration = Duration(milliseconds: 300);
}
