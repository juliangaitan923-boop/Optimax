import 'dart:math';
import '../core/utils.dart';

class StorageCategory {
  final String name;
  final int size;
  final double percent;
  final String iconPath;

  StorageCategory({
    required this.name,
    required this.size,
    required this.percent,
    required this.iconPath,
  });

  String get sizeFormatted => formatBytes(size);
}

class StorageAnalyzerService {
  Future<List<StorageCategory>> analyze() async {
    await Future.delayed(const Duration(seconds: 1));
    final random = Random();
    return [
      StorageCategory(name: 'Fotos y videos', size: 14 * 1024 * 1024 * 1024 + random.nextInt(1024) * 1024 * 1024, percent: 0.44, iconPath: 'photos'),
      StorageCategory(name: 'Apps', size: 8 * 1024 * 1024 * 1024 + random.nextInt(512) * 1024 * 1024, percent: 0.27, iconPath: 'apps'),
      StorageCategory(name: 'Música', size: 3 * 1024 * 1024 * 1024 + random.nextInt(256) * 1024 * 1024, percent: 0.10, iconPath: 'music'),
      StorageCategory(name: 'Documentos', size: 2 * 1024 * 1024 * 1024 + random.nextInt(128) * 1024 * 1024, percent: 0.07, iconPath: 'docs'),
      StorageCategory(name: 'Caché', size: 2 * 1024 * 1024 * 1024, percent: 0.06, iconPath: 'cache'),
      StorageCategory(name: 'Sistema', size: 1 * 1024 * 1024 * 1024 + random.nextInt(256) * 1024 * 1024, percent: 0.04, iconPath: 'system'),
      StorageCategory(name: 'Otros', size: 512 * 1024 * 1024 + random.nextInt(256) * 1024 * 1024, percent: 0.02, iconPath: 'other'),
    ];
  }
}
