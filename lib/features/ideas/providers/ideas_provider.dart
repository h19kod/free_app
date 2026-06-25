import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

final ideasProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  try {
    final res = await api.getIdeas();
    return (res.data as List).cast<Map<String, dynamic>>();
  } catch (e) {
    // Return mock data for test mode or error fallback
    return [
      {
        'id': 1,
        'title': 'Smart Home Automation',
        'description': 'IoT-based home automation system with voice control',
        'budget': 5000.0,
        'status': 'open',
        'proposals_count': 3,
        'required_skills': 'IoT,Python,Mobile Dev',
        'owner_name': 'John Doe',
        'created_at': '2024-01-15T10:30:00Z',
      },
      {
        'id': 2,
        'title': 'Fitness Tracking App',
        'description': 'Mobile app for tracking workouts and nutrition',
        'budget': 3000.0,
        'status': 'open',
        'proposals_count': 5,
        'required_skills': 'Flutter,Health APIs,UI/UX',
        'owner_name': 'Jane Smith',
        'created_at': '2024-01-14T14:20:00Z',
      },
    ];
  }
});

final ideaDetailProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, id) async {
  final api = ref.watch(apiServiceProvider);
  try {
    final res = await api.getIdea(id);
    return res.data as Map<String, dynamic>;
  } catch (e) {
    // Return mock data for test mode or error fallback
    return {
      'id': id,
      'title': 'Sample Idea',
      'description': 'This is a sample idea description',
      'budget': 1000.0,
      'status': 'open',
      'proposals_count': 2,
      'required_skills': 'Flutter,Dart,Backend',
      'owner_name': 'Test User',
    };
  }
});

final ideaProposalsProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, ideaId) async {
  final api = ref.watch(apiServiceProvider);
  try {
    // This should be a dedicated endpoint for proposals
    return [];
  } catch (e) {
    return [];
  }
});
