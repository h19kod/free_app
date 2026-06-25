import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../marketplace/widgets/listing_card.dart';

final searchResultsProvider = FutureProvider.family<List<dynamic>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final api = ref.watch(apiServiceProvider);
  final res = await api.getListings(search: query);
  return res.data as List<dynamic>;
});

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  final List<String> _suggestions = [
    'React App', 'Flutter', 'E-commerce', 'AI Project',
    'SaaS', 'Mobile App', 'Dashboard', 'API',
  ];

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search projects...',
            border: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
          ),
          onChanged: (v) {
            if (v.length >= 2 || v.isEmpty) {
              setState(() => _query = v);
            }
          },
          onSubmitted: (v) => setState(() => _query = v),
        ),
      ),
      body: _query.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Popular Searches',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _suggestions.map((s) => GestureDetector(
                      onTap: () {
                        _controller.text = s;
                        setState(() => _query = s);
                      },
                      child: Chip(
                        label: Text(s),
                        backgroundColor: AppTheme.primary.withValues(alpha: 0.08),
                        labelStyle: const TextStyle(color: AppTheme.primary),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            )
          : results.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Search failed')),
              data: (data) => data.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: AppTheme.textSecondary),
                          const SizedBox(height: 12),
                          Text('No results for "$_query"',
                              style: TextStyle(color: AppTheme.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: data.length,
                      itemBuilder: (_, i) => ListingCard(listing: data[i]),
                    ),
            ),
    );
  }
}
