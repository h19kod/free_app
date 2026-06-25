import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class ListingCard extends StatelessWidget {
  final Map<String, dynamic> listing;
  const ListingCard({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final price = (listing['price'] ?? 0).toDouble();
    final rating = (listing['rating'] ?? 0.0).toDouble();
    final images = listing['image_urls'] as List? ?? [];

    return GestureDetector(
      onTap: () => context.push('/marketplace/listing/${listing['id']}'),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: images.isNotEmpty
                  ? Image.network(
                      images.first,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          listing['title'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '\$${price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    listing['description'] ?? '',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (listing['tech_stack'] != null)
                        ...(listing['tech_stack'] as List).isNotEmpty
                            ? [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    (listing['tech_stack'] as List).first.toString(),
                                    style: const TextStyle(
                                        fontSize: 11, color: AppTheme.primary),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ]
                            : [],
                      const Spacer(),
                      if (rating > 0) ...[
                        const Icon(Icons.star, size: 14, color: AppTheme.warning),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 180,
      color: AppTheme.primary.withValues(alpha: 0.1),
      child: const Center(
        child: Icon(Icons.code, size: 48, color: AppTheme.primary),
      ),
    );
  }
}
