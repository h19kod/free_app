import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

final listingDetailProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, id) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.getListing(id);
  return res.data as Map<String, dynamic>;
});

final listingReviewsProvider = FutureProvider.family<List<dynamic>, int>((ref, id) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.getReviews(listingId: id);
  return res.data as List<dynamic>;
});

class ListingDetailScreen extends ConsumerStatefulWidget {
  final int id;
  const ListingDetailScreen({super.key, required this.id});

  @override
  ConsumerState<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  int _rating = 5;
  final _reviewController = TextEditingController();
  bool _submittingReview = false;

  Future<void> _submitReview() async {
    if (_reviewController.text.isEmpty) return;
    setState(() => _submittingReview = true);
    try {
      final api = ref.read(apiServiceProvider);
      await api.createReview({
        'listing_id': widget.id,
        'rating': _rating,
        'comment': _reviewController.text,
      });
      _reviewController.clear();
      await ref.refresh(listingReviewsProvider(widget.id)); // ignore: unused_result
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit review')),
        );
      }
    } finally {
      if (mounted) setState(() => _submittingReview = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = ref.watch(listingDetailProvider(widget.id));
    final reviews = ref.watch(listingReviewsProvider(widget.id));
    final currentUser = ref.watch(authProvider).user;

    return Scaffold(
      body: listing.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Failed to load')),
        data: (data) {
          final images = data['image_urls'] as List? ?? [];
          final price = (data['price'] ?? 0).toDouble();
          final sellerId = data['seller_id'];
          final isOwner = currentUser?['id'] == sellerId;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: images.isNotEmpty
                      ? Image.network(images.first, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            child: const Icon(Icons.code, size: 64, color: AppTheme.primary),
                          ))
                      : Container(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.code, size: 64, color: AppTheme.primary),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(data['title'] ?? '',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          ),
                          Text('\$${price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (data['tech_stack'] != null && (data['tech_stack'] as String).isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(data['tech_stack'],
                              style: const TextStyle(color: AppTheme.primary, fontSize: 12)),
                        ),
                      const SizedBox(height: 16),
                      Text(data['description'] ?? '',
                          style: TextStyle(fontSize: 15, color: AppTheme.textSecondary, height: 1.6)),
                      const Divider(height: 40),
                      // Reviews
                      const Text('Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      reviews.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Text('Failed to load reviews'),
                        data: (reviewList) => reviewList.isEmpty
                            ? Text('No reviews yet', style: TextStyle(color: AppTheme.textSecondary))
                            : Column(
                                children: reviewList.map<Widget>((r) => _ReviewTile(review: r)).toList(),
                              ),
                      ),
                      if (!isOwner) ...[
                        const Divider(height: 40),
                        const Text('Write a Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Row(
                          children: List.generate(5, (i) => GestureDetector(
                            onTap: () => setState(() => _rating = i + 1),
                            child: Icon(
                              i < _rating ? Icons.star : Icons.star_border,
                              color: AppTheme.warning, size: 32,
                            ),
                          )),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _reviewController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Write your review...',
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _submittingReview ? null : _submitReview,
                          child: const Text('Submit Review'),
                        ),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: listing.maybeWhen(
        data: (data) {
          final currentUser = ref.watch(authProvider).user;
          final isOwner = currentUser?['id'] == data['seller_id'];
          final price = (data['price'] ?? 0).toDouble();
          if (isOwner) return const SizedBox.shrink();
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Contact Seller'),
                      onPressed: () => context.push('/chat/${data['seller_id']}'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.shopping_cart),
                      label: Text('Buy \$${price.toStringAsFixed(0)}'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payment flow coming soon!')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Map<String, dynamic> review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final rating = (review['rating'] ?? 0) as int;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(
                children: List.generate(5, (i) => Icon(
                  i < rating ? Icons.star : Icons.star_border,
                  size: 14, color: AppTheme.warning,
                )),
              ),
              const Spacer(),
              Text(review['reviewer_name'] ?? 'Anonymous',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
          if (review['comment'] != null && (review['comment'] as String).isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(review['comment'],
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ],
      ),
    );
  }
}
