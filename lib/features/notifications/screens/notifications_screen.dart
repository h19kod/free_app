import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'icon': Icons.shopping_bag,
        'color': AppTheme.primary,
        'title': 'New Purchase',
        'body': 'Someone bought your listing "E-commerce App"',
        'time': '2h ago',
      },
      {
        'icon': Icons.chat_bubble,
        'color': AppTheme.secondary,
        'title': 'New Message',
        'body': 'Ahmed sent you a message',
        'time': '4h ago',
      },
      {
        'icon': Icons.star,
        'color': AppTheme.warning,
        'title': 'New Review',
        'body': 'You received a 5-star review!',
        'time': '1d ago',
      },
      {
        'icon': Icons.account_balance_wallet,
        'color': AppTheme.success,
        'title': 'Payment Received',
        'body': 'Your escrow of \$500 has been released',
        'time': '2d ago',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: AppTheme.textSecondary),
                  const SizedBox(height: 12),
                  Text('No notifications yet',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final n = notifications[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (n['color'] as Color).withValues(alpha: 0.1),
                    child: Icon(n['icon'] as IconData,
                        color: n['color'] as Color, size: 20),
                  ),
                  title: Text(n['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(n['body'] as String,
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  trailing: Text(n['time'] as String,
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                );
              },
            ),
    );
  }
}
