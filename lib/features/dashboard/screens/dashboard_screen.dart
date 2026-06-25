import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final escrow = ref.watch(escrowProvider);
    final disputes = ref.watch(disputesProvider);
    final isAdmin = ref.watch(authProvider).isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () => context.push('/admin'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.refresh(escrowProvider); // ignore: unused_result
          await ref.refresh(disputesProvider); // ignore: unused_result
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // User greeting
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDark],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    child: Text(
                      (user?['full_name'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back!', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      Text(
                        user?['full_name'] ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user?['role']?.toString().toUpperCase() ?? '',
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _ActionButton(
                  icon: Icons.add_box_outlined,
                  label: 'Sell Project',
                  color: AppTheme.primary,
                  onTap: () => context.push('/marketplace/create'),
                ),
                const SizedBox(width: 12),
                _ActionButton(
                  icon: Icons.lightbulb_outline,
                  label: 'Post Idea',
                  color: AppTheme.secondary,
                  onTap: () => context.push('/ideas/create'),
                ),
                const SizedBox(width: 12),
                _ActionButton(
                  icon: Icons.store_outlined,
                  label: 'Browse',
                  color: AppTheme.accent,
                  onTap: () => context.go('/marketplace'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Escrow
            const Text('Escrow Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            escrow.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Text('Failed to load', style: TextStyle(color: AppTheme.textSecondary)),
              data: (data) => data.isEmpty
                  ? _EmptyState(icon: Icons.account_balance_wallet_outlined, label: 'No escrow transactions')
                  : Column(
                      children: data.map<Widget>((e) => _EscrowTile(escrow: e)).toList(),
                    ),
            ),
            const SizedBox(height: 24),

            // Disputes
            const Text('Disputes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            disputes.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Text('Failed to load', style: TextStyle(color: AppTheme.textSecondary)),
              data: (data) => data.isEmpty
                  ? _EmptyState(icon: Icons.gavel_outlined, label: 'No disputes')
                  : Column(
                      children: data.map<Widget>((d) => _DisputeTile(dispute: d)).toList(),
                    ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EscrowTile extends StatelessWidget {
  final Map<String, dynamic> escrow;
  const _EscrowTile({required this.escrow});

  @override
  Widget build(BuildContext context) {
    final amount = (escrow['amount'] ?? 0).toDouble();
    final status = escrow['status'] ?? 'pending';
    final color = status == 'completed'
        ? AppTheme.success
        : status == 'held'
            ? AppTheme.warning
            : AppTheme.textSecondary;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(Icons.account_balance_wallet, color: color, size: 20),
        ),
        title: Text('\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(status.toUpperCase(),
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

class _DisputeTile extends StatelessWidget {
  final Map<String, dynamic> dispute;
  const _DisputeTile({required this.dispute});

  @override
  Widget build(BuildContext context) {
    final status = dispute['status'] ?? 'open';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0x1AEF4444),
          child: Icon(Icons.gavel, color: AppTheme.error, size: 20),
        ),
        title: Text(dispute['reason'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(status.toUpperCase(),
            style: TextStyle(color: AppTheme.error, fontSize: 12, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String label;
  const _EmptyState({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 40, color: AppTheme.textSecondary),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
