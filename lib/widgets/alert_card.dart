import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme_colors.dart';

class AlertCard extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback? onAction;
  final IconData icon;
  final Color? color;

  const AlertCard({
    super.key,
    required this.message,
    required this.actionLabel,
    this.onAction,
    this.icon = Icons.warning_amber_rounded,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final alertColor = color ?? AppColors.warning;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: alertColor.withOpacity(0.1),
        border: Border.all(color: alertColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: alertColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: alertColor,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
