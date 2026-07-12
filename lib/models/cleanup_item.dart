import 'package:flutter/material.dart';

class CleanupItem {
  final String id;
  final String name;
  final String category;
  final int size;
  final IconData icon;
  final bool isRecommended;

  CleanupItem({
    required this.id,
    required this.name,
    required this.category,
    required this.size,
    required this.icon,
    this.isRecommended = true,
  });

  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(0)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
