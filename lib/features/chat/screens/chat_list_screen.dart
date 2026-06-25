import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/chat_provider.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: conversations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load conversations')),
        data: (data) => data.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 64, color: AppTheme.textSecondary),
                    const SizedBox(height: 12),
                    Text('No conversations yet', style: TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: data.length,
                itemBuilder: (_, i) {
                  final c = data[i] as Map<String, dynamic>;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primary,
                      child: Text(
                        (c['name'] ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(c['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(c['last_message'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textSecondary),
                    onTap: () => context.push('/chat/${c['user_id']}'),
                  );
                },
              ),
      ),
    );
  }
}
