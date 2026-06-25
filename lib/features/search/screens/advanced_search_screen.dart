import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/search_service.dart';
import '../../../core/widgets/custom_components.dart';
import '../../../core/widgets/animated_widgets.dart';
import '../providers/search_provider.dart';

class AdvancedSearchScreen extends ConsumerStatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  ConsumerState<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends ConsumerState<AdvancedSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _scrollController.removeListener(_onScroll);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(searchProvider.notifier).updateQuery(_searchController.text);
  }

  void _onScroll() {
    // Implement infinite scroll if needed
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final searchNotifier = ref.read(searchProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            _buildSearchHeader(searchState, searchNotifier),
            
            // Filters Section
            if (_showFilters)
              _buildFiltersSection(searchState, searchNotifier),
            
            // Results Section
            Expanded(
              child: _buildResultsSection(searchState, searchNotifier),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(SearchState state, SearchNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          CustomSearchBar(
            controller: _searchController,
            hintText: 'Search for projects, freelancers, services...',
            suggestions: state.suggestions,
            onSuggestionSelected: (suggestion) {
              _searchController.text = suggestion;
              notifier.performSearch();
            },
            onClear: () {
              notifier.resetSearch();
            },
          ),
          
          const SizedBox(height: 16),
          
          // Category Tabs and Actions
          Row(
            children: [
              // Category Tabs
              Expanded(
                child: CustomTabBar(
                  tabs: SearchCategory.values.map((category) => 
                      category.name.capitalize()).toList(),
                  selectedIndex: SearchCategory.values.indexOf(state.currentQuery.category),
                  onTabSelected: (index) {
                    notifier.setCategory(SearchCategory.values[index]);
                  },
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Filter Toggle
              AnimatedButton(
                text: 'Filters',
                onPressed: () {
                  setState(() => _showFilters = !_showFilters);
                },
                icon: _showFilters ? Icons.filter_list_off : Icons.filter_list,
                width: 100,
                height: 40,
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Active Filters and Sort
          Row(
            children: [
              // Active Filters
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: state.currentQuery.filters.map((filter) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CustomFilterChip(
                          label: filter.label ?? filter.key,
                          selected: true,
                          onSelected: (_) => notifier.removeFilter(filter),
                          icon: Icons.close,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Sort Dropdown
              PopupMenuButton<SortOption>(
                icon: const Icon(Icons.sort),
                onSelected: (sortOption) {
                  notifier.setSortOption(sortOption);
                },
                itemBuilder: (context) {
                  return SortOption.values.map((option) {
                    return PopupMenuItem(
                      value: option,
                      child: Row(
                        children: [
                          Icon(_getSortIcon(option)),
                          const SizedBox(width: 8),
                          Text(_getSortLabel(option)),
                          if (state.currentQuery.sortOption == option) ...[
                            const Spacer(),
                            const Icon(Icons.check, color: AppTheme.primary),
                          ],
                        ],
                      ),
                    );
                  }).toList();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(SearchState state, SearchNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Header
          Row(
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (state.currentQuery.filters.isNotEmpty)
                TextButton(
                  onPressed: notifier.clearFilters,
                  child: const Text('Clear All'),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Filter Options
          _buildFilterOptions(state, notifier),
        ],
      ),
    );
  }

  Widget _buildFilterOptions(SearchState state, SearchNotifier notifier) {
    return Column(
      children: [
        // Price Range Filter
        _buildPriceRangeFilter(state, notifier),
        
        const SizedBox(height: 16),
        
        // Rating Filter
        _buildRatingFilter(state, notifier),
        
        const SizedBox(height: 16),
        
        // Skills Filter
        _buildSkillsFilter(state, notifier),
        
        const SizedBox(height: 16),
        
        // Availability Filter
        _buildAvailabilityFilter(state, notifier),
      ],
    );
  }

  Widget _buildPriceRangeFilter(SearchState state, SearchNotifier notifier) {
    final priceFilter = state.currentQuery.filters
        .where((f) => f.type == FilterType.priceRange)
        .firstOrNull;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price Range',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            CustomFilterChip(
              label: 'Under $100',
              selected: priceFilter?.key == 'price_0_100',
              onSelected: (selected) {
                if (selected) {
                  notifier.addFilter(SearchFilter(
                    type: FilterType.priceRange,
                    key: 'price_0_100',
                    value: {'min': 0.0, 'max': 100.0},
                    label: 'Under $100',
                  ));
                } else {
                  notifier.removeFilter(SearchFilter(
                    type: FilterType.priceRange,
                    key: 'price_0_100',
                    value: {'min': 0.0, 'max': 100.0},
                  ));
                }
              },
            ),
            CustomFilterChip(
              label: '$100 - $500',
              selected: priceFilter?.key == 'price_100_500',
              onSelected: (selected) {
                if (selected) {
                  notifier.addFilter(SearchFilter(
                    type: FilterType.priceRange,
                    key: 'price_100_500',
                    value: {'min': 100.0, 'max': 500.0},
                    label: '$100 - $500',
                  ));
                } else {
                  notifier.removeFilter(SearchFilter(
                    type: FilterType.priceRange,
                    key: 'price_100_500',
                    value: {'min': 100.0, 'max': 500.0},
                  ));
                }
              },
            ),
            CustomFilterChip(
              label: '$500+',
              selected: priceFilter?.key == 'price_500_plus',
              onSelected: (selected) {
                if (selected) {
                  notifier.addFilter(SearchFilter(
                    type: FilterType.priceRange,
                    key: 'price_500_plus',
                    value: {'min': 500.0, 'max': double.infinity},
                    label: '$500+',
                  ));
                } else {
                  notifier.removeFilter(SearchFilter(
                    type: FilterType.priceRange,
                    key: 'price_500_plus',
                    value: {'min': 500.0, 'max': double.infinity},
                  ));
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingFilter(SearchState state, SearchNotifier notifier) {
    final ratingFilter = state.currentQuery.filters
        .where((f) => f.type == FilterType.rating)
        .firstOrNull;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Minimum Rating',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [3.0, 3.5, 4.0, 4.5].map((rating) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CustomFilterChip(
                label: '$rating+',
                selected: ratingFilter?.value == rating,
                onSelected: (selected) {
                  if (selected) {
                    notifier.addFilter(SearchFilter(
                      type: FilterType.rating,
                      key: 'rating_$rating',
                      value: rating,
                      label: '$rating+ Stars',
                    ));
                  } else {
                    notifier.removeFilter(SearchFilter(
                      type: FilterType.rating,
                      key: 'rating_$rating',
                      value: rating,
                    ));
                  }
                },
                icon: Icons.star,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSkillsFilter(SearchState state, SearchNotifier notifier) {
    final skillsFilter = state.currentQuery.filters
        .where((f) => f.type == FilterType.skills)
        .firstOrNull;
    
    final popularSkills = ['Flutter', 'React', 'Node.js', 'Python', 'UI/UX'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Skills',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: popularSkills.map((skill) {
            final isSelected = skillsFilter != null &&
                (skillsFilter.value as List<String>).contains(skill);
            
            return CustomFilterChip(
              label: skill,
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  final currentSkills = skillsFilter?.value as List<String>? ?? [];
                  final updatedSkills = [...currentSkills, skill];
                  
                  notifier.removeFilter(skillsFilter!);
                  notifier.addFilter(SearchFilter(
                    type: FilterType.skills,
                    key: 'skills_${updatedSkills.length}',
                    value: updatedSkills,
                    label: '${updatedSkills.length} Skills',
                  ));
                } else {
                  final currentSkills = skillsFilter?.value as List<String>? ?? [];
                  final updatedSkills = List<String>.from(currentSkills)..remove(skill);
                  
                  notifier.removeFilter(skillsFilter!);
                  if (updatedSkills.isNotEmpty) {
                    notifier.addFilter(SearchFilter(
                      type: FilterType.skills,
                      key: 'skills_${updatedSkills.length}',
                      value: updatedSkills,
                      label: '${updatedSkills.length} Skills',
                    ));
                  }
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAvailabilityFilter(SearchState state, SearchNotifier notifier) {
    final availabilityFilter = state.currentQuery.filters
        .where((f) => f.type == FilterType.availability)
        .firstOrNull;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Availability',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        CustomFilterChip(
          label: 'Available Now',
          selected: availabilityFilter?.value == true,
          onSelected: (selected) {
            if (selected) {
              notifier.addFilter(SearchFilter(
                type: FilterType.availability,
                key: 'available_now',
                value: true,
                label: 'Available Now',
              ));
            } else {
              notifier.removeFilter(SearchFilter(
                type: FilterType.availability,
                key: 'available_now',
                value: true,
              ));
            }
          },
          icon: Icons.check_circle,
        ),
      ],
    );
  }

  Widget _buildResultsSection(SearchState state, SearchNotifier notifier) {
    if (state.isLoading) {
      return const Center(
        child: AnimatedLoadingWidget(
          message: 'Searching...',
          loadingType: LoadingType.dots,
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: AnimatedStatusWidget(
          isSuccess: false,
          message: state.error!,
        ),
      );
    }

    if (state.currentQuery.query.isEmpty) {
      return _buildEmptySearchState(state, notifier);
    }

    return _buildSearchResults(state, notifier);
  }

  Widget _buildEmptySearchState(SearchState state, SearchNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trending Searches
          if (state.trendingSearches.isNotEmpty) ...[
            const Text(
              'Trending Searches',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: state.trendingSearches.map((trend) {
                return CustomFilterChip(
                  label: trend,
                  selected: false,
                  onSelected: (_) {
                    _searchController.text = trend;
                    notifier.performSearch();
                  },
                  icon: Icons.trending_up,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
          
          // Recent Searches
          if (state.recentSearches.isNotEmpty) ...[
            Row(
              children: [
                const Text(
                  'Recent Searches',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: notifier.clearRecentSearches,
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...state.recentSearches.map((search) {
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(search),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _searchController.text = search;
                  notifier.performSearch();
                },
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchState state, SearchNotifier notifier) {
    // Mock results - in a real app, you'd use actual search results
    final mockResults = List.generate(20, (index) {
      return {
        'id': 'item_$index',
        'title': '${state.currentQuery.query} Project $index',
        'description': 'This is a sample project description',
        'price': (index + 1) * 50.0,
        'rating': 3.5 + (index % 5) * 0.3,
        'reviews': index * 5,
        'imageUrl': 'https://picsum.photos/seed/item$index/200/200.jpg',
        'freelancer': {
          'name': 'Freelancer $index',
          'avatar': 'https://picsum.photos/seed/user$index/100/100.jpg',
        },
      };
    });

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: mockResults.length,
      itemBuilder: (context, index) {
        final result = mockResults[index];
        return _buildResultCard(result, index);
      },
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result, int index) {
    return AnimatedCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              result['imageUrl'],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image),
                );
              },
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  ),
                const SizedBox(height: 4),
                Text(
                  result['description'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CustomAvatar(
                      imageUrl: result['freelancer']['avatar'],
                      name: result['freelancer']['name'],
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      result['freelancer']['name'],
                      style: const TextStyle(fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      '\$${result['price'].toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      result['rating'].toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${result['reviews']} reviews)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSortIcon(SortOption option) {
    switch (option) {
      case SortOption.relevance:
        return Icons.search;
      case SortOption.newest:
        return Icons.new_releases;
      case SortOption.oldest:
        return Icons.history;
      case SortOption.priceLow:
        return Icons.arrow_upward;
      case SortOption.priceHigh:
        return Icons.arrow_downward;
      case SortOption.rating:
        return Icons.star;
      case SortOption.popular:
        return Icons.trending_up;
    }
  }

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.relevance:
        return 'Relevance';
      case SortOption.newest:
        return 'Newest';
      case SortOption.oldest:
        return 'Oldest';
      case SortOption.priceLow:
        return 'Price: Low to High';
      case SortOption.priceHigh:
        return 'Price: High to Low';
      case SortOption.rating:
        return 'Rating';
      case SortOption.popular:
        return 'Most Popular';
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
