import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class KycScreen extends ConsumerWidget {
  const KycScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final isVerified = user?['kyc_verified'] == true;
    final isPending = user?['kyc_status'] == 'pending';

    return Scaffold(
      appBar: AppBar(title: const Text('KYC Verification')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isVerified
                    ? AppTheme.success.withValues(alpha: 0.1)
                    : isPending
                        ? AppTheme.warning.withValues(alpha: 0.1)
                        : AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    isVerified
                        ? Icons.verified_user
                        : isPending
                            ? Icons.pending
                            : Icons.verified_user_outlined,
                    size: 48,
                    color: isVerified
                        ? AppTheme.success
                        : isPending
                            ? AppTheme.warning
                            : AppTheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isVerified
                              ? 'Verified'
                              : isPending
                                  ? 'Under Review'
                                  : 'Not Verified',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          isVerified
                              ? 'Your identity has been verified'
                              : isPending
                                  ? 'Your documents are under review'
                                  : 'Verify your identity to sell and receive payments',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Why verify?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _BenefitTile(
                icon: Icons.sell, text: 'List and sell your projects'),
            _BenefitTile(
                icon: Icons.account_balance_wallet,
                text: 'Receive payouts via Stripe Connect'),
            _BenefitTile(
                icon: Icons.security, text: 'Build trust with buyers'),
            _BenefitTile(
                icon: Icons.star, text: 'Get verified badge on profile'),
            const SizedBox(height: 32),
            if (!isVerified && !isPending)
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload ID Document'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Document upload coming in next update!')),
                  );
                },
              ),
            if (isPending)
              ElevatedButton.icon(
                icon: const Icon(Icons.hourglass_empty),
                label: const Text('Waiting for Approval'),
                onPressed: null,
              ),
            if (isVerified)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                icon: const Icon(Icons.check_circle),
                label: const Text('Identity Verified'),
                onPressed: null,
              ),
          ],
        ),
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  final IconData icon;
  final String text;
  const _BenefitTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
