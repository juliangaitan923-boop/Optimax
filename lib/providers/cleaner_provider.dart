import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cleanup_item.dart';
import '../services/cleaner_service.dart';
import 'system_providers.dart';

final cleanerServiceProvider = Provider<CleanerService>((ref) {
  final deviceService = ref.read(deviceServiceProvider);
  return CleanerService(deviceService);
});

final scanResultProvider = FutureProvider<List<CleanupItem>>((ref) async {
  final service = ref.read(cleanerServiceProvider);
  return await service.scanJunk();
});

final cleaningInProgressProvider = StateProvider<bool>((ref) => false);

final selectedItemsProvider = StateProvider<Set<String>>((ref) => {});

final cleanResultProvider = FutureProvider.autoDispose<int>((ref) async {
  final inProgress = ref.watch(cleaningInProgressProvider);
  if (!inProgress) throw Exception('Not cleaning');

  final selected = ref.read(selectedItemsProvider);
  final service = ref.read(cleanerServiceProvider);
  return await service.cleanItems(selected.toList());
});
