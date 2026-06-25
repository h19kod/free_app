import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/ideas_provider.dart';

class IdeasScreen extends ConsumerWidget {
  const IdeasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ideas = ref.watch(ideasProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ideas Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => context.push('/ideas/create'),
          ),
        ],
      ),
      body: ideas.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
              const SizedBox(height: 8),
              const Text('Failed to load ideas'),
              TextButton(onPressed: () => ref.refresh(ideasProvider), child: const Text('Retry')),
            ],
          ),
        ),
        data: (data) => data.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lightbulb_outline, size: 64, color: AppTheme.textSecondary),
                    const SizedBox(height: 12),
                    Text('No ideas yet. Be the first!', style: TextStyle(color: AppTheme.textSecondary)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.push('/ideas/create'),
                      child: const Text('Post an Idea'),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () async => ref.refresh(ideasProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.length,
                  itemBuilder: (_, i) => _IdeaCard(idea: data[i]),
                ),
              ),
      ),
    );
  }
}

class _IdeaCard extends StatelessWidget {
  final Map<String, dynamic> idea;
  const _IdeaCard({required this.idea});

  @override
  Widget build(BuildContext context) {
    final budget = (idea['budget'] ?? 0).toDouble();
    final skills = idea['required_skills'] ?? '';

    return GestureDetector(
      onTap: () => context.push('/ideas/detail/${idea['id']}'),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.lightbulb, color: AppTheme.secondary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      idea['title'] ?? '',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '\$${budget.toStringAsFixed(0)}',
                      style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                idea['description'] ?? '',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (skills.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: (skills as String)
                      .split(',')
                      .take(3)
                      .map((s) => Chip(
                            label: Text(s.trim(), style: const TextStyle(fontSize: 11)),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    idea['owner_name'] ?? 'Anonymous',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.textSecondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
