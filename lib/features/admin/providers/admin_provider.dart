import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.getAdminStats();
  return res.data as Map<String, dynamic>;
});

final adminUsersProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.getAdminUsers();
  return res.data as List<dynamic>;
});

final kycPendingProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.getKycPending();
  return res.data as List<dynamic>;
});
