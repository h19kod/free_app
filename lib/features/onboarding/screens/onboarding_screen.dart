import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_widgets.dart';
import '../../../core/services/animation_service.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);
    final onboardingNotifier = ref.read(onboardingProvider.notifier);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primary.withValues(alpha: 0.1),
              AppTheme.primary.withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _completeOnboarding(onboardingNotifier),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ).animateWithFade(),
                  ],
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: onboardingState.pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(
                      onboardingState.pages[index],
                      index,
                    );
                  },
                ),
              ),

              // Bottom section with indicators and buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        onboardingState.pages.length,
                        (index) => _buildIndicator(index),
                      ),
                    ).animateWithFade(),

                    const SizedBox(height: 32),

                    // Navigation buttons
                    if (_currentPage == onboardingState.pages.length - 1)
                      AnimatedButton(
                        text: 'Get Started',
                        onPressed: () => _completeOnboarding(onboardingNotifier),
                        width: double.infinity,
                        height: 48,
                        icon: Icons.rocket_launch,
                      )
                    else
                      Row(
                        children: [
                          // Previous button
                          Expanded(
                            child: AnimatedButton(
                              text: 'Previous',
                              onPressed: _currentPage > 0
                                  ? () => _previousPage()
                                  : null,
                              backgroundColor: Colors.grey.shade300,
                              textColor: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Next button
                          Expanded(
                            child: AnimatedButton(
                              text: 'Next',
                              onPressed: () => _nextPage(),
                              icon: Icons.arrow_forward,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, int index) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration or icon
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 80,
              color: AppTheme.primary,
            ),
          ).animateWithScale(
            delay: Duration(milliseconds: index * 100),
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ).animateWithSlide(
            direction: SlideDirection.bottom,
            delay: Duration(milliseconds: index * 100 + 200),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ).animateWithSlide(
            direction: SlideDirection.bottom,
            delay: Duration(milliseconds: index * 100 + 400),
          ),

          const SizedBox(height: 32),

          // Features list
          if (page.features.isNotEmpty)
            ...page.features.asMap().entries.map((entry) {
              final featureIndex = entry.key;
              final feature = entry.value;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.success,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animateWithSlide(
                direction: SlideDirection.left,
                delay: Duration(milliseconds: index * 100 + 600 + featureIndex * 100),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    final isActive = index == _currentPage;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < ref.read(onboardingProvider).pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding(OnboardingNotifier notifier) async {
    await notifier.completeOnboarding();
    if (mounted) {
      context.go('/marketplace');
    }
  }
}

// Onboarding page model
class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final List<String> features;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    this.features = const [],
  });
}
