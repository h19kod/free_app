import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

class MarketplaceFilters {
  final String? search;
  final double? minPrice;
  final double? maxPrice;
  final String? techStack;
  final double? minRating;
  final String? sortBy;

  const MarketplaceFilters({
    this.search,
    this.minPrice,
    this.maxPrice,
    this.techStack,
    this.minRating,
    this.sortBy,
  });

  MarketplaceFilters copyWith({
    String? search,
    double? minPrice,
    double? maxPrice,
    String? techStack,
    double? minRating,
    String? sortBy,
  }) {
    return MarketplaceFilters(
      search: search ?? this.search,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      techStack: techStack ?? this.techStack,
      minRating: minRating ?? this.minRating,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

final marketplaceFiltersProvider =
    StateProvider<MarketplaceFilters>((ref) => const MarketplaceFilters());

final marketplaceListingsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final filters = ref.watch(marketplaceFiltersProvider);
  final res = await api.getListings(
    search: filters.search,
    minPrice: filters.minPrice,
    maxPrice: filters.maxPrice,
    techStack: filters.techStack,
    minRating: filters.minRating,
    sortBy: filters.sortBy,
  );
  return res.data as List<dynamic>;
});
