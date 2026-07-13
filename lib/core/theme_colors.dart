import 'package:flutter/material.dart';
import 'constants.dart';

extension AppThemeColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get surfaceCard => isDark ? AppColors.surfaceCard : AppColors.lightCard;
  Color get surfaceDark => isDark ? AppColors.surfaceDark : AppColors.lightBackground;
  Color get surfaceCardLight => isDark ? AppColors.surfaceCardLight : const Color(0xFFF0F0F8);
  Color get surfaceCardBorder => isDark ? AppColors.surfaceCardBorder : AppColors.lightBorder;

  Color get textPrimary => isDark ? AppColors.textPrimary : AppColors.lightText;
  Color get textSecondary => isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
  Color get textMuted => isDark ? AppColors.textMuted : AppColors.lightTextSecondary.withOpacity(0.6);

  Color get dividerColor => isDark ? Colors.white10 : AppColors.lightBorder.withOpacity(0.5);
  Color get shimmerBase => isDark ? AppColors.surfaceCard : const Color(0xFFE8E8F0);
  Color get shimmerHighlight => isDark ? AppColors.surfaceCardLight : const Color(0xFFF5F5FA);

  Color backgroundColor(double opacity) =>
      (isDark ? Colors.white : Colors.black).withOpacity(opacity);
}
