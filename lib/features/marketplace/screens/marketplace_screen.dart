import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/listing_card.dart';

final listingsProvider = FutureProvider.family<List<dynamic>, Map<String, dynamic>>((ref, filters) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.getListings(
    search: filters['search'],
    minPrice: filters['minPrice'],
    maxPrice: filters['maxPrice'],
    techStack: filters['techStack'],
    minRating: filters['minRating'],
    sortBy: filters['sortBy'],
  );
  return res.data as List<dynamic>;
});

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  final _searchController = TextEditingController();
  String? _sortBy;
  double? _minPrice;
  double? _maxPrice;
  String? _techStack;
  Map<String, dynamic> _filters = {};

  void _applyFilters() {
    setState(() {
      _filters = {
        if (_searchController.text.isNotEmpty) 'search': _searchController.text,
        if (_minPrice != null) 'minPrice': _minPrice,
        if (_maxPrice != null) 'maxPrice': _maxPrice,
        if (_techStack != null && _techStack!.isNotEmpty) 'techStack': _techStack,
        if (_sortBy != null) 'sortBy': _sortBy,
      };
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter & Sort', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Sort By'),
              items: const [
                DropdownMenuItem(value: null, child: Text('Default')),
                DropdownMenuItem(value: 'newest', child: Text('Newest')),
                DropdownMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
                DropdownMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
                DropdownMenuItem(value: 'rating', child: Text('Top Rated')),
              ],
              onChanged: (v) => setState(() => _sortBy = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Tech Stack (e.g. React)'),
              onChanged: (v) => _techStack = v,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Min Price (\$)'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _minPrice = double.tryParse(v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Max Price (\$)'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _maxPrice = double.tryParse(v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _applyFilters();
                Navigator.pop(ctx);
              },
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listings = ref.watch(listingsProvider(_filters));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => context.push('/marketplace/create'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search projects...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _applyFilters();
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (_) => _applyFilters(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: AppTheme.primary),
                  icon: const Icon(Icons.tune, color: Colors.white),
                  onPressed: _showFilterSheet,
                ),
              ],
            ),
          ),
          Expanded(
            child: listings.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                    const SizedBox(height: 8),
                    Text('Failed to load listings', style: TextStyle(color: AppTheme.textSecondary)),
                    TextButton(onPressed: () => ref.refresh(listingsProvider(_filters)), child: const Text('Retry')),
                  ],
                ),
              ),
              data: (data) => data.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.store_outlined, size: 64, color: AppTheme.textSecondary),
                          const SizedBox(height: 12),
                          Text('No listings found', style: TextStyle(color: AppTheme.textSecondary)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => ref.refresh(listingsProvider(_filters)),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: data.length,
                        itemBuilder: (_, i) => ListingCard(listing: data[i]),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
