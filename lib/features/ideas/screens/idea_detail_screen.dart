import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

final ideaDetailProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, id) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.getIdea(id);
  return res.data as Map<String, dynamic>;
});

class IdeaDetailScreen extends ConsumerStatefulWidget {
  final int id;
  const IdeaDetailScreen({super.key, required this.id});

  @override
  ConsumerState<IdeaDetailScreen> createState() => _IdeaDetailScreenState();
}

class _IdeaDetailScreenState extends ConsumerState<IdeaDetailScreen> {
  final _proposalController = TextEditingController();
  final _priceController = TextEditingController();
  bool _submitting = false;

  Future<void> _submitProposal() async {
    if (_proposalController.text.isEmpty || _priceController.text.isEmpty) return;
    setState(() => _submitting = true);
    try {
      final api = ref.read(apiServiceProvider);
      await api.submitProposal(widget.id, {
        'message': _proposalController.text,
        'proposed_price': double.parse(_priceController.text),
      });
      _proposalController.clear();
      _priceController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proposal submitted!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit proposal')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final idea = ref.watch(ideaDetailProvider(widget.id));
    final currentUser = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Idea Details')),
      body: idea.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load')),
        data: (data) {
          final budget = (data['budget'] ?? 0).toDouble();
          final isOwner = currentUser?['id'] == data['owner_id'];
          final proposals = data['proposals'] as List? ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['title'] ?? '',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Budget: \$${budget.toStringAsFixed(0)}',
                          style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(data['description'] ?? '',
                    style: TextStyle(fontSize: 15, color: AppTheme.textSecondary, height: 1.6)),
                if (data['required_skills'] != null && (data['required_skills'] as String).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Required Skills', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (data['required_skills'] as String)
                        .split(',')
                        .map((s) => Chip(label: Text(s.trim())))
                        .toList(),
                  ),
                ],
                const Divider(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Proposals (${proposals.length})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                if (proposals.isEmpty)
                  Text('No proposals yet', style: TextStyle(color: AppTheme.textSecondary))
                else
                  ...proposals.map<Widget>((p) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(p['developer_name'] ?? 'Developer',
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text('\$${(p['proposed_price'] ?? 0).toStringAsFixed(0)}',
                                      style: const TextStyle(
                                          color: AppTheme.primary, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(p['message'] ?? '',
                                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                              if (isOwner) ...[
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () =>
                                      context.push('/chat/${p['developer_id']}'),
                                  child: const Text('Contact Developer'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )),
                if (!isOwner) ...[
                  const Divider(height: 40),
                  const Text('Submit a Proposal',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _proposalController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Describe your approach and timeline...',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Your Price (\$)',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitting ? null : _submitProposal,
                    child: const Text('Submit Proposal'),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
