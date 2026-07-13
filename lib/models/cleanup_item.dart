import 'package:flutter/material.dart';
import '../core/utils.dart';

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

  String get sizeFormatted => formatBytes(size);
}
