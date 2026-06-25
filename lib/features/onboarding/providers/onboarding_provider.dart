import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../screens/onboarding_screen.dart';

class OnboardingState {
  final bool isLoading;
  final String? error;
  final List<OnboardingPage> pages;
  final bool isCompleted;

  const OnboardingState({
    this.isLoading = false,
    this.error,
    this.pages = const [],
    this.isCompleted = false,
  });

  OnboardingState copyWith({
    bool? isLoading,
    String? error,
    List<OnboardingPage>? pages,
    bool? isCompleted,
  }) {
    return OnboardingState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      pages: pages ?? this.pages,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier();
});

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  OnboardingNotifier() : super(const OnboardingState()) {
    _initializeOnboarding();
  }

  Future<void> _initializeOnboarding() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Check if onboarding is already completed
      final isCompleted = await _storage.read(key: 'onboarding_completed') == 'true';
      
      // Create onboarding pages
      final pages = [
        OnboardingPage(
          title: 'Welcome to AppMarket',
          description: 'Your global marketplace for finding talented freelancers and amazing projects.',
          icon: Icons.store_rounded,
          features: [
            'Connect with talented freelancers worldwide',
            'Post your projects and get them done',
            'Secure payment system with escrow protection',
          ],
        ),
        OnboardingPage(
          title: 'Find Your Perfect Match',
          description: 'Discover skilled professionals for your projects or find exciting opportunities.',
          icon: Icons.search_rounded,
          features: [
            'Advanced search and filtering',
            'Verified freelancer profiles',
            'Real-time chat and collaboration',
          ],
        ),
        OnboardingPage(
          title: 'Secure & Easy Payments',
          description: 'Our payment system ensures your money is safe until work is completed.',
          icon: Icons.payments_rounded,
          features: [
            'Multiple payment methods',
            'Escrow protection for both parties',
            'Multi-currency support',
            'Instant withdrawals',
          ],
        ),
        OnboardingPage(
          title: 'Build Your Reputation',
          description: 'Showcase your skills and build a strong portfolio to attract more clients.',
          icon: Icons.star_rounded,
          features: [
            'Rating and review system',
            'Portfolio gallery',
            'Skill endorsements',
            'Achievement badges',
          ],
        ),
        OnboardingPage(
          title: 'Stay Connected',
          description: 'Never miss an update with our comprehensive notification system.',
          icon: Icons.notifications_rounded,
          features: [
            'Push notifications',
            'Email alerts',
            'In-app messaging',
            'Real-time updates',
          ],
        ),
        OnboardingPage(
          title: 'Ready to Get Started?',
          description: 'Join thousands of freelancers and clients already using AppMarket.',
          icon: Icons.rocket_launch_rounded,
          features: [
            'Create your profile in minutes',
            'Start posting or bidding on projects',
            '24/7 customer support',
            'Mobile and web access',
          ],
        ),
      ];

      state = state.copyWith(
        isLoading: false,
        pages: pages,
        isCompleted: isCompleted,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize onboarding: $e',
      );
    }
  }

  Future<void> completeOnboarding() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _storage.write(key: 'onboarding_completed', value: 'true');

      state = state.copyWith(
        isLoading: false,
        isCompleted: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to complete onboarding: $e',
      );
    }
  }

  Future<void> resetOnboarding() async {
    try {
      await _storage.delete(key: 'onboarding_completed');
      await _initializeOnboarding();
    } catch (e) {
      state = state.copyWith(error: 'Failed to reset onboarding: $e');
    }
  }

  Future<bool> shouldShowOnboarding() async {
    try {
      final isCompleted = await _storage.read(key: 'onboarding_completed') == 'true';
      return !isCompleted;
    } catch (e) {
      return true; // Show onboarding if there's an error
    }
  }

  Future<void> skipOnboarding() async {
    await completeOnboarding();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Get onboarding progress
  double getProgress() {
    if (state.pages.isEmpty) return 0.0;
    return state.isCompleted ? 1.0 : 0.0;
  }

  // Get current page index (for external navigation)
  int getCurrentPageIndex() {
    return 0; // Always start from page 0
  }

  // Check if onboarding is completed
  bool isOnboardingCompleted() {
    return state.isCompleted;
  }

  // Get total number of pages
  int getTotalPages() {
    return state.pages.length;
  }

  // Get specific page by index
  OnboardingPage? getPage(int index) {
    if (index >= 0 && index < state.pages.length) {
      return state.pages[index];
    }
    return null;
  }

  // Update onboarding pages (for customization)
  Future<void> updatePages(List<OnboardingPage> newPages) async {
    try {
      state = state.copyWith(pages: newPages);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update pages: $e');
    }
  }

  // Add custom page
  Future<void> addCustomPage(OnboardingPage page) async {
    try {
      final updatedPages = [...state.pages, page];
      state = state.copyWith(pages: updatedPages);
    } catch (e) {
      state = state.copyWith(error: 'Failed to add custom page: $e');
    }
  }

  // Remove page by index
  Future<void> removePage(int index) async {
    try {
      if (index >= 0 && index < state.pages.length) {
        final updatedPages = List<OnboardingPage>.from(state.pages)
          ..removeAt(index);
        state = state.copyWith(pages: updatedPages);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to remove page: $e');
    }
  }

  // Reorder pages
  Future<void> reorderPages(int oldIndex, int newIndex) async {
    try {
      if (oldIndex >= 0 && 
          oldIndex < state.pages.length && 
          newIndex >= 0 && 
          newIndex < state.pages.length) {
        final updatedPages = List<OnboardingPage>.from(state.pages);
        final page = updatedPages.removeAt(oldIndex);
        updatedPages.insert(newIndex, page);
        state = state.copyWith(pages: updatedPages);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to reorder pages: $e');
    }
  }

  // Get onboarding statistics
  Map<String, dynamic> getStatistics() {
    return {
      'total_pages': state.pages.length,
      'is_completed': state.isCompleted,
      'has_error': state.error != null,
      'is_loading': state.isLoading,
      'progress': getProgress(),
    };
  }

  // Export onboarding data
  Future<Map<String, dynamic>> exportData() async {
    return {
      'pages': state.pages.map((page) => {
        'title': page.title,
        'description': page.description,
        'icon': page.icon.codePoint,
        'features': page.features,
      }).toList(),
      'is_completed': state.isCompleted,
      'completed_at': state.isCompleted ? DateTime.now().toIso8601String() : null,
    };
  }

  // Import onboarding data
  Future<void> importData(Map<String, dynamic> data) async {
    try {
      if (data.containsKey('pages')) {
        final pagesData = data['pages'] as List;
        final pages = pagesData.map((pageData) {
          return OnboardingPage(
            title: pageData['title'],
            description: pageData['description'],
            icon: IconData(pageData['icon'], fontFamily: 'MaterialIcons'),
            features: List<String>.from(pageData['features'] ?? []),
          );
        }).toList();
        
        state = state.copyWith(pages: pages);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to import data: $e');
    }
  }
}
