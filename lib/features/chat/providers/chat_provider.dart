import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

final conversationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  try {
    final res = await api.getConversations();
    return (res.data as List).cast<Map<String, dynamic>>();
  } catch (e) {
    // Return mock data for test mode or error fallback
    return [
      {
        'user_id': 2,
        'name': 'John Doe',
        'last_message': 'Hey, how is the project going?',
        'timestamp': '2024-01-15T10:30:00Z',
      },
      {
        'user_id': 3,
        'name': 'Jane Smith',
        'last_message': 'Can you send me the files?',
        'timestamp': '2024-01-14T15:20:00Z',
      },
    ];
  }
});

final messagesProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, recipientId) async {
  final api = ref.watch(apiServiceProvider);
  try {
    final res = await api.getMessages(recipientId);
    return (res.data as List).cast<Map<String, dynamic>>();
  } catch (e) {
    // Return mock data for test mode or error fallback
    return [
      {
        'id': 1,
        'sender_id': 1,
        'recipient_id': recipientId,
        'content': 'Hello! How are you?',
        'created_at': '2024-01-15T10:30:00Z',
      },
      {
        'id': 2,
        'sender_id': recipientId,
        'recipient_id': 1,
        'content': 'I\'m good, thanks! How about you?',
        'created_at': '2024-01-15T10:31:00Z',
      },
    ];
  }
});
