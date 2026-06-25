class AppConstants {
  // API
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
  static const String wsBaseUrl = 'ws://10.0.2.2:8000/api/v1';

  // Storage Keys
  static const String tokenKey = 'token';
  static const String userKey = 'user';

  // Categories
  static const List<String> categories = [
    'Website',
    'Mobile App',
    'AI Project',
    'SaaS',
    'Design',
    'Game',
    'API / Backend',
    'Chrome Extension',
    'Other',
  ];

  // Sort Options
  static const Map<String, String> sortOptions = {
    'newest': 'Newest',
    'price_asc': 'Price: Low to High',
    'price_desc': 'Price: High to Low',
    'rating': 'Top Rated',
  };
}
