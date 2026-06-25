import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum SearchCategory {
  all,
  projects,
  freelancers,
  services,
  ideas,
}

enum SortOption {
  relevance,
  newest,
  oldest,
  priceLow,
  priceHigh,
  rating,
  popular,
}

enum FilterType {
  category,
  priceRange,
  rating,
  location,
  skills,
  availability,
  experience,
}

class SearchFilter {
  final FilterType type;
  final String key;
  final dynamic value;
  final String? label;

  SearchFilter({
    required this.type,
    required this.key,
    required this.value,
    this.label,
  });

  SearchFilter copyWith({
    FilterType? type,
    String? key,
    dynamic value,
    String? label,
  }) {
    return SearchFilter(
      type: type ?? this.type,
      key: key ?? this.key,
      value: value ?? this.value,
      label: label ?? this.label,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'key': key,
      'value': value,
      'label': label,
    };
  }

  factory SearchFilter.fromJson(Map<String, dynamic> json) {
    return SearchFilter(
      type: FilterType.values.firstWhere((e) => e.name == json['type']),
      key: json['key'],
      value: json['value'],
      label: json['label'],
    );
  }
}

class SearchQuery {
  final String query;
  final SearchCategory category;
  final List<SearchFilter> filters;
  final SortOption sortOption;
  final int page;
  final int limit;

  SearchQuery({
    this.query = '',
    this.category = SearchCategory.all,
    this.filters = const [],
    this.sortOption = SortOption.relevance,
    this.page = 1,
    this.limit = 20,
  });

  SearchQuery copyWith({
    String? query,
    SearchCategory? category,
    List<SearchFilter>? filters,
    SortOption? sortOption,
    int? page,
    int? limit,
  }) {
    return SearchQuery(
      query: query ?? this.query,
      category: category ?? this.category,
      filters: filters ?? this.filters,
      sortOption: sortOption ?? this.sortOption,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'category': category.name,
      'filters': filters.map((f) => f.toJson()).toList(),
      'sortOption': sortOption.name,
      'page': page,
      'limit': limit,
    };
  }

  factory SearchQuery.fromJson(Map<String, dynamic> json) {
    return SearchQuery(
      query: json['query'] ?? '',
      category: SearchCategory.values.firstWhere((e) => e.name == json['category']),
      filters: (json['filters'] as List?)
          ?.map((f) => SearchFilter.fromJson(f))
          .toList() ?? [],
      sortOption: SortOption.values.firstWhere((e) => e.name == json['sortOption']),
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
    );
  }
}

class SearchResult<T> {
  final List<T> items;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  SearchResult({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });
}

class SearchState {
  final bool isLoading;
  final String? error;
  final List<String> suggestions;
  final List<String> recentSearches;
  final List<String> trendingSearches;
  final SearchQuery currentQuery;

  const SearchState({
    this.isLoading = false,
    this.error,
    this.suggestions = const [],
    this.recentSearches = const [],
    this.trendingSearches = const [],
    this.currentQuery = const SearchQuery(),
  });

  SearchState copyWith({
    bool? isLoading,
    String? error,
    List<String>? suggestions,
    List<String>? recentSearches,
    List<String>? trendingSearches,
    SearchQuery? currentQuery,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      suggestions: suggestions ?? this.suggestions,
      recentSearches: recentSearches ?? this.recentSearches,
      trendingSearches: trendingSearches ?? this.trendingSearches,
      currentQuery: currentQuery ?? this.currentQuery,
    );
  }
}

final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService();
});

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.read(searchServiceProvider));
});

class SearchService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Mock data for demonstration
  static const List<String> _mockSuggestions = [
    'Flutter Developer',
    'Web Design',
    'Mobile App',
    'UI/UX Design',
    'Backend Development',
    'Content Writing',
    'Digital Marketing',
    'Data Science',
    'Machine Learning',
    'Blockchain Development',
  ];

  static const List<String> _mockTrending = [
    'AI Development',
    'Flutter Apps',
    'React Native',
    'Web3 Projects',
    'NFT Marketplace',
    'DeFi Platform',
    'Metaverse Development',
    'AR/VR Applications',
  ];

  // Get search suggestions
  Future<List<String>> getSearchSuggestions(String query) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (query.isEmpty) return [];
    
    return _mockSuggestions
        .where((suggestion) => 
            suggestion.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Get recent searches
  Future<List<String>> getRecentSearches() async {
    try {
      final searchesJson = await _storage.read(key: 'recent_searches');
      if (searchesJson != null) {
        final searches = List<String>.from(
          // In a real app, you'd properly decode JSON
          searchesJson.split(',').where((s) => s.isNotEmpty).toList(),
        );
        return searches.take(10).toList(); // Limit to 10 recent searches
      }
    } catch (e) {
      // Handle error
    }
    return [];
  }

  // Save search to recent searches
  Future<void> saveRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    try {
      final recentSearches = await getRecentSearches();
      
      // Remove if already exists
      recentSearches.remove(query);
      
      // Add to beginning
      recentSearches.insert(0, query);
      
      // Limit to 10
      final limitedSearches = recentSearches.take(10).toList();
      
      // Save to storage
      await _storage.write(
        key: 'recent_searches',
        value: limitedSearches.join(','),
      );
    } catch (e) {
      // Handle error
    }
  }

  // Clear recent searches
  Future<void> clearRecentSearches() async {
    try {
      await _storage.delete(key: 'recent_searches');
    } catch (e) {
      // Handle error
    }
  }

  // Get trending searches
  Future<List<String>> getTrendingSearches() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockTrending;
  }

  // Perform search (mock implementation)
  Future<SearchResult<Map<String, dynamic>>> performSearch(SearchQuery query) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock search results
    final mockResults = _generateMockResults(query);
    final totalCount = mockResults.length;
    final totalPages = (totalCount / query.limit).ceil();
    
    final startIndex = (query.page - 1) * query.limit;
    final endIndex = (startIndex + query.limit).clamp(0, totalCount);
    final pageResults = mockResults.sublist(startIndex, endIndex);
    
    return SearchResult(
      items: pageResults,
      totalCount: totalCount,
      currentPage: query.page,
      totalPages: totalPages,
      hasNextPage: query.page < totalPages,
      hasPreviousPage: query.page > 1,
    );
  }

  List<Map<String, dynamic>> _generateMockResults(SearchQuery query) {
    // Generate mock results based on query
    final results = <Map<String, dynamic>>[];
    
    for (int i = 1; i <= 50; i++) {
      results.add({
        'id': 'item_$i',
        'title': '${query.query.isEmpty ? 'Sample' : query.query} Project $i',
        'description': 'This is a sample project description for item $i',
        'category': _getRandomCategory(),
        'price': (i * 10.0) + 50,
        'rating': 3.5 + (i % 5) * 0.5,
        'reviews': i * 3,
        'imageUrl': 'https://picsum.photos/seed/item$i/200/200.jpg',
        'createdAt': DateTime.now().subtract(Duration(days: i)).toIso8601String(),
        'freelancer': {
          'id': 'freelancer_$i',
          'name': 'Freelancer $i',
          'avatar': 'https://picsum.photos/seed/user$i/100/100.jpg',
          'rating': 4.0 + (i % 5) * 0.2,
        },
        'skills': _getRandomSkills(),
        'location': 'City $i',
        'isAvailable': i % 3 != 0,
      });
    }
    
    // Apply filters and sorting
    return _applyFiltersAndSorting(results, query);
  }

  String _getRandomCategory() {
    final categories = ['Development', 'Design', 'Marketing', 'Writing', 'Video'];
    return categories[(DateTime.now().millisecondsSinceEpoch % categories.length)];
  }

  List<String> _getRandomSkills() {
    final allSkills = [
      'Flutter', 'React', 'Node.js', 'Python', 'UI/UX',
      'Figma', 'Photoshop', 'SEO', 'Content Writing', 'Video Editing'
    ];
    allSkills.shuffle();
    return allSkills.take(3).toList();
  }

  List<Map<String, dynamic>> _applyFiltersAndSorting(
    List<Map<String, dynamic>> results,
    SearchQuery query,
  ) {
    var filteredResults = results;
    
    // Apply text search filter
    if (query.query.isNotEmpty) {
      filteredResults = filteredResults.where((item) {
        final title = item['title'].toString().toLowerCase();
        final description = item['description'].toString().toLowerCase();
        final searchQuery = query.query.toLowerCase();
        return title.contains(searchQuery) || description.contains(searchQuery);
      }).toList();
    }
    
    // Apply category filter
    if (query.category != SearchCategory.all) {
      filteredResults = filteredResults.where((item) {
        // In a real app, you'd check the actual category
        return true; // Simplified for demo
      }).toList();
    }
    
    // Apply custom filters
    for (final filter in query.filters) {
      filteredResults = _applyFilter(filteredResults, filter);
    }
    
    // Apply sorting
    filteredResults = _applySorting(filteredResults, query.sortOption);
    
    return filteredResults;
  }

  List<Map<String, dynamic>> _applyFilter(
    List<Map<String, dynamic>> results,
    SearchFilter filter,
  ) {
    switch (filter.type) {
      case FilterType.priceRange:
        final range = filter.value as Map<String, double>;
        return results.where((item) {
          final price = item['price'] as double;
          return price >= range['min']! && price <= range['max']!;
        }).toList();
        
      case FilterType.rating:
        final minRating = filter.value as double;
        return results.where((item) {
          final rating = item['rating'] as double;
          return rating >= minRating;
        }).toList();
        
      case FilterType.skills:
        final requiredSkills = List<String>.from(filter.value);
        return results.where((item) {
          final itemSkills = List<String>.from(item['skills']);
          return requiredSkills.any((skill) => 
              itemSkills.any((itemSkill) => 
                  itemSkill.toLowerCase().contains(skill.toLowerCase())));
        }).toList();
        
      case FilterType.availability:
        final isAvailable = filter.value as bool;
        return results.where((item) {
          return item['isAvailable'] == isAvailable;
        }).toList();
        
      default:
        return results;
    }
  }

  List<Map<String, dynamic>> _applySorting(
    List<Map<String, dynamic>> results,
    SortOption sortOption,
  ) {
    switch (sortOption) {
      case SortOption.newest:
        results.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
        break;
      case SortOption.oldest:
        results.sort((a, b) => a['createdAt'].compareTo(b['createdAt']));
        break;
      case SortOption.priceLow:
        results.sort((a, b) => (a['price'] as double).compareTo(b['price'] as double));
        break;
      case SortOption.priceHigh:
        results.sort((a, b) => (b['price'] as double).compareTo(a['price'] as double));
        break;
      case SortOption.rating:
        results.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
        break;
      case SortOption.popular:
        results.sort((a, b) => (b['reviews'] as int).compareTo(a['reviews'] as int));
        break;
      case SortOption.relevance:
      default:
        // Keep original order for relevance
        break;
    }
    return results;
  }

  // Get popular filters
  List<SearchFilter> getPopularFilters() {
    return [
      SearchFilter(
        type: FilterType.priceRange,
        key: 'price_0_100',
        value: {'min': 0.0, 'max': 100.0},
        label: 'Under $100',
      ),
      SearchFilter(
        type: FilterType.priceRange,
        key: 'price_100_500',
        value: {'min': 100.0, 'max': 500.0},
        label: '$100 - $500',
      ),
      SearchFilter(
        type: FilterType.rating,
        key: 'rating_4_plus',
        value: 4.0,
        label: '4+ Stars',
      ),
      SearchFilter(
        type: FilterType.availability,
        key: 'available_now',
        value: true,
        label: 'Available Now',
      ),
      SearchFilter(
        type: FilterType.skills,
        key: 'flutter',
        value: ['Flutter'],
        label: 'Flutter',
      ),
      SearchFilter(
        type: FilterType.skills,
        key: 'react',
        value: ['React'],
        label: 'React',
      ),
    ];
  }

  // Get search analytics
  Future<Map<String, dynamic>> getSearchAnalytics() async {
    // Mock analytics data
    return {
      'totalSearches': 1234,
      'popularQueries': [
        {'query': 'Flutter Developer', 'count': 156},
        {'query': 'Web Design', 'count': 142},
        {'query': 'Mobile App', 'count': 98},
      ],
      'searchTrends': [
        {'date': '2024-01-01', 'count': 45},
        {'date': '2024-01-02', 'count': 52},
        {'date': '2024-01-03', 'count': 38},
      ],
      'topCategories': [
        {'category': 'Development', 'count': 456},
        {'category': 'Design', 'count': 234},
        {'category': 'Marketing', 'count': 123},
      ],
    };
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final SearchService _searchService;

  SearchNotifier(this._searchService) : super(const SearchState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final recentSearches = await _searchService.getRecentSearches();
      final trendingSearches = await _searchService.getTrendingSearches();
      
      state = state.copyWith(
        isLoading: false,
        recentSearches: recentSearches,
        trendingSearches: trendingSearches,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load search data: $e',
      );
    }
  }

  Future<void> updateQuery(String query) async {
    final updatedQuery = state.currentQuery.copyWith(query: query);
    state = state.copyWith(currentQuery: updatedQuery);
    
    // Get suggestions
    if (query.isNotEmpty) {
      final suggestions = await _searchService.getSearchSuggestions(query);
      state = state.copyWith(suggestions: suggestions);
    } else {
      state = state.copyWith(suggestions: []);
    }
  }

  Future<void> performSearch() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Save to recent searches
      if (state.currentQuery.query.isNotEmpty) {
        await _searchService.saveRecentSearch(state.currentQuery.query);
        final updatedRecentSearches = await _searchService.getRecentSearches();
        state = state.copyWith(recentSearches: updatedRecentSearches);
      }
      
      // Perform search
      final results = await _searchService.performSearch(state.currentQuery);
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Search failed: $e',
      );
    }
  }

  Future<void> setCategory(SearchCategory category) async {
    final updatedQuery = state.currentQuery.copyWith(category: category);
    state = state.copyWith(currentQuery: updatedQuery);
    await performSearch();
  }

  Future<void> setSortOption(SortOption sortOption) async {
    final updatedQuery = state.currentQuery.copyWith(sortOption: sortOption);
    state = state.copyWith(currentQuery: updatedQuery);
    await performSearch();
  }

  Future<void> addFilter(SearchFilter filter) async {
    final updatedFilters = [...state.currentQuery.filters];
    
    // Remove existing filter of same type/key
    updatedFilters.removeWhere((f) => f.type == filter.type && f.key == filter.key);
    
    updatedFilters.add(filter);
    
    final updatedQuery = state.currentQuery.copyWith(filters: updatedFilters);
    state = state.copyWith(currentQuery: updatedQuery);
    await performSearch();
  }

  Future<void> removeFilter(SearchFilter filter) async {
    final updatedFilters = [...state.currentQuery.filters];
    updatedFilters.removeWhere((f) => f.type == filter.type && f.key == filter.key);
    
    final updatedQuery = state.currentQuery.copyWith(filters: updatedFilters);
    state = state.copyWith(currentQuery: updatedQuery);
    await performSearch();
  }

  Future<void> clearFilters() async {
    final updatedQuery = state.currentQuery.copyWith(filters: []);
    state = state.copyWith(currentQuery: updatedQuery);
    await performSearch();
  }

  Future<void> goToPage(int page) async {
    final updatedQuery = state.currentQuery.copyWith(page: page);
    state = state.copyWith(currentQuery: updatedQuery);
    await performSearch();
  }

  Future<void> clearRecentSearches() async {
    await _searchService.clearRecentSearches();
    state = state.copyWith(recentSearches: []);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void resetSearch() {
    state = state.copyWith(
      currentQuery: const SearchQuery(),
      suggestions: [],
      error: null,
    );
  }
}
