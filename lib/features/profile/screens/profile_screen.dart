import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final isAdmin = ref.watch(authProvider).isAdmin;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppTheme.primary,
                  child: Text(
                    (user?['full_name'] ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?['full_name'] ?? '',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(user?['email'] ?? '',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (user?['role'] ?? 'buyer').toString().toUpperCase(),
                    style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
                if (isAdmin) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('ADMIN',
                        style: TextStyle(color: AppTheme.accent, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
          _SectionTitle('Account'),
          _ProfileTile(
            icon: Icons.verified_user_outlined,
            label: 'KYC Verification',
            trailing: user?['kyc_verified'] == true
                ? const Icon(Icons.check_circle, color: AppTheme.success, size: 18)
                : const Icon(Icons.pending, color: AppTheme.warning, size: 18),
            onTap: () => context.push('/kyc'),
          ),
          _ProfileTile(
            icon: Icons.payment_outlined,
            label: 'Stripe Connect',
            trailing: user?['stripe_connect_onboarding_complete'] == true
                ? const Icon(Icons.check_circle, color: AppTheme.success, size: 18)
                : const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _SectionTitle('Activity'),
          _ProfileTile(
            icon: Icons.store_outlined,
            label: 'My Listings',
            onTap: () => context.go('/marketplace'),
          ),
          _ProfileTile(
            icon: Icons.lightbulb_outline,
            label: 'My Ideas',
            onTap: () => context.go('/ideas'),
          ),
          _ProfileTile(
            icon: Icons.gavel_outlined,
            label: 'My Disputes',
            onTap: () => context.push('/disputes'),
          ),
          _ProfileTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: () => context.push('/notifications'),
          ),
          _ProfileTile(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            onTap: () => context.go('/dashboard'),
          ),
          if (isAdmin) ...[
            const SizedBox(height: 16),
            _SectionTitle('Admin'),
            _ProfileTile(
              icon: Icons.admin_panel_settings_outlined,
              label: 'Admin Panel',
              onTap: () => context.push('/admin'),
            ),
          ],
          const SizedBox(height: 16),
          _SectionTitle('App'),
          _ProfileTile(
            icon: Icons.info_outline,
            label: 'About AppMarket',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              letterSpacing: 1)),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(label),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}
