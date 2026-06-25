import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

final escrowProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.getEscrow();
  return res.data as List<dynamic>;
});

final disputesProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.getDisputes();
  return res.data as List<dynamic>;
});
