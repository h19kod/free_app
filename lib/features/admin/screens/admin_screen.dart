import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/admin_provider.dart';

// Use the apiServiceProvider from api_service.dart
final adminApiProvider = Provider((ref) => ref.watch(apiServiceProvider));

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatsProvider);
    final users = ref.watch(adminUsersProvider);
    final kyc = ref.watch(kycPendingProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Users'),
              Tab(text: 'KYC'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Overview Tab
            stats.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Failed to load stats')),
              data: (data) => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _StatCard(
                    icon: Icons.people,
                    label: 'Total Users',
                    value: '${data['total_users'] ?? 0}',
                    color: AppTheme.primary,
                  ),
                  _StatCard(
                    icon: Icons.store,
                    label: 'Listings',
                    value: '${data['total_listings'] ?? 0}',
                    color: AppTheme.secondary,
                  ),
                  _StatCard(
                    icon: Icons.attach_money,
                    label: 'Revenue',
                    value: '\$${(data['total_revenue'] ?? 0).toStringAsFixed(0)}',
                    color: AppTheme.success,
                  ),
                  _StatCard(
                    icon: Icons.gavel,
                    label: 'Open Disputes',
                    value: '${data['open_disputes'] ?? 0}',
                    color: AppTheme.error,
                  ),
                ],
              ),
            ),

            // Users Tab
            users.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Failed to load users')),
              data: (data) => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: data.length,
                itemBuilder: (_, i) {
                  final u = data[i] as Map<String, dynamic>;
                  final isActive = u['is_active'] == true;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isActive ? AppTheme.primary : Colors.grey,
                        child: Text(
                          (u['full_name'] ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(u['full_name'] ?? ''),
                      subtitle: Text(u['email'] ?? ''),
                      trailing: TextButton(
                        onPressed: () async {
                          final api = ref.read(adminApiProvider);
                          if (isActive) {
                            await api.banUser(u['id']);
                          } else {
                            await api.unbanUser(u['id']);
                          }
                          await ref.refresh(adminUsersProvider); // ignore: unused_result
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: isActive ? AppTheme.error : AppTheme.success,
                        ),
                        child: Text(isActive ? 'Ban' : 'Unban'),
                      ),
                    ),
                  );
                },
              ),
            ),

            // KYC Tab
            kyc.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Failed to load KYC')),
              data: (data) => data.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified_user_outlined, size: 64, color: AppTheme.textSecondary),
                          const SizedBox(height: 12),
                          Text('No pending KYC', style: TextStyle(color: AppTheme.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: data.length,
                      itemBuilder: (_, i) {
                        final u = data[i] as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(u['full_name'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(u['email'] ?? '',
                                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.success),
                                        onPressed: () async {
                                          await ref.read(adminApiProvider).approveKyc(u['id']);
                                          await ref.refresh(kycPendingProvider); // ignore: unused_result
                                        },
                                        child: const Text('Approve'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.error),
                                        onPressed: () async {
                                          await ref.read(adminApiProvider).rejectKyc(u['id']);
                                          await ref.refresh(kycPendingProvider); // ignore: unused_result
                                        },
                                        child: const Text('Reject'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
