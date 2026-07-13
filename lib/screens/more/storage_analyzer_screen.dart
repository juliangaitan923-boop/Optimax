import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/theme_colors.dart';
import '../../providers/system_providers.dart';
import '../../services/storage_analyzer_service.dart';
import '../../widgets/glass_card.dart';

class StorageAnalyzerScreen extends ConsumerStatefulWidget {
  const StorageAnalyzerScreen({super.key});

  @override
  ConsumerState<StorageAnalyzerScreen> createState() => _StorageAnalyzerScreenState();
}

class _StorageAnalyzerScreenState extends ConsumerState<StorageAnalyzerScreen> {
  List<StorageCategory>? _categories;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final service = ref.read(storageAnalyzerProvider);
    final data = await service.analyze();
    setState(() {
      _categories = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Almacenamiento', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: context.textMuted),
            onPressed: _load,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: _buildPieChart(),
                        ),
                        const SizedBox(height: 16),
                        ..._categories!.map((cat) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getColor(cat.name),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(cat.name, style: TextStyle(color: context.textPrimary, fontSize: 13)),
                              ),
                              Text(cat.sizeFormatted, style: TextStyle(color: context.textSecondary, fontSize: 13)),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 18),
                            const SizedBox(width: 8),
                            Text('Recomendaciones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.textPrimary)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _tipTile(Icons.photo_library, 'Revisa y respalda fotos/videos duplicados'),
                        const SizedBox(height: 8),
                        _tipTile(Icons.delete, 'Elimina apps que no usas hace más de 30 días'),
                        const SizedBox(height: 8),
                        _tipTile(Icons.cloud_upload, 'Usa Google Photos o Drive para liberar espacio'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildPieChart() {
    if (_categories == null || _categories!.isEmpty) return const SizedBox();
    final total = _categories!.fold<double>(0, (sum, c) => sum + c.size);
    if (total == 0) return const SizedBox();

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: _categories!.asMap().entries.map((entry) {
                final cat = entry.value;
                final percent = (cat.size / total) * 100;
                return PieChartSectionData(
                  color: _getColor(cat.name),
                  value: percent,
                  title: '${percent.toStringAsFixed(0)}%',
                  radius: 50,
                  titleStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.textPrimary),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Total', style: TextStyle(color: context.textMuted, fontSize: 12)),
            const SizedBox(height: 4),
            Text(_formatTotalSize(), style: TextStyle(color: context.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _tipTile(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.info, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: TextStyle(color: context.textSecondary, fontSize: 13)),
        ),
      ],
    );
  }

  String _formatTotalSize() {
    if (_categories == null) return '0 GB';
    final total = _categories!.fold<int>(0, (sum, c) => sum + c.size);
    if (total < 1024 * 1024 * 1024) {
      return '${(total / (1024 * 1024)).toStringAsFixed(0)} MB';
    }
    return '${(total / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Color _getColor(String name) {
    final colors = {
      'Fotos y videos': const Color(0xFF6C63FF),
      'Apps': const Color(0xFF00D9A6),
      'Música': const Color(0xFFFF6B6B),
      'Documentos': const Color(0xFF4FC3F7),
      'Caché': const Color(0xFFFFB74D),
      'Sistema': const Color(0xFFAB47BC),
      'Otros': const Color(0xFF78909C),
    };
    return colors[name] ?? const Color(0xFF78909C);
  }
}
