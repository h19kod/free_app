import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_widgets.dart';
import '../providers/onboarding_provider.dart';

class CoachMarkOverlay extends ConsumerStatefulWidget {
  final Widget child;
  final List<CoachMarkTarget> targets;
  final VoidCallback? onComplete;
  final bool showSkipButton;

  const CoachMarkOverlay({
    super.key,
    required this.child,
    required this.targets,
    this.onComplete,
    this.showSkipButton = true,
  });

  @override
  ConsumerState<CoachMarkOverlay> createState() => _CoachMarkOverlayState();
}

class _CoachMarkOverlayState extends ConsumerState<CoachMarkOverlay>
    with TickerProviderStateMixin {
  late AnimationController _overlayController;
  late AnimationController _spotlightController;
  late Animation<double> _overlayAnimation;
  late Animation<double> _spotlightAnimation;
  
  int _currentTargetIndex = 0;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _spotlightController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _overlayAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeInOut,
    ));

    _spotlightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _spotlightController,
      curve: Curves.easeInOut,
    ));

    // Start showing after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCoachMarks();
    });
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _spotlightController.dispose();
    super.dispose();
  }

  void _showCoachMarks() {
    if (widget.targets.isNotEmpty) {
      setState(() => _isVisible = true);
      _overlayController.forward();
      _spotlightController.repeat(reverse: true);
    }
  }

  void _hideCoachMarks() {
    _overlayController.reverse().then((_) {
      setState(() => _isVisible = false);
      widget.onComplete?.call();
    });
  }

  void _nextTarget() {
    if (_currentTargetIndex < widget.targets.length - 1) {
      setState(() => _currentTargetIndex++);
    } else {
      _hideCoachMarks();
    }
  }

  void _previousTarget() {
    if (_currentTargetIndex > 0) {
      setState(() => _currentTargetIndex--);
    }
  }

  void _skipCoachMarks() {
    _hideCoachMarks();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isVisible)
          AnimatedBuilder(
            animation: _overlayAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _overlayAnimation.value,
                child: _buildOverlay(),
              );
            },
          ),
      ],
    );
  }

  Widget _buildOverlay() {
    final currentTarget = widget.targets[_currentTargetIndex];
    
    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      child: Stack(
        children: [
          // Highlight the target area
          _buildSpotlight(currentTarget),
          
          // Coach mark content
          _buildCoachMarkContent(currentTarget),
          
          // Navigation buttons
          _buildNavigationButtons(),
          
          // Skip button
          if (widget.showSkipButton)
            _buildSkipButton(),
        ],
      ),
    );
  }

  Widget _buildSpotlight(CoachMarkTarget target) {
    return Positioned(
      left: target.globalPosition.dx - 10,
      top: target.globalPosition.dy - 10,
      child: AnimatedBuilder(
        animation: _spotlightAnimation,
        builder: (context, child) {
          return Container(
            width: target.size.width + 20,
            height: target.size.height + 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.primary.withValues(
                  alpha: 0.3 + (_spotlightAnimation.value * 0.4),
                ),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(
                    alpha: 0.2 * _spotlightAnimation.value,
                  ),
                  blurRadius: 20 * _spotlightAnimation.value,
                  spreadRadius: 5 * _spotlightAnimation.value,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCoachMarkContent(CoachMarkTarget target) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Position the coach mark bubble
    double bubbleTop = target.globalPosition.dy + target.size.height + 20;
    double bubbleLeft = target.globalPosition.dx;
    
    // Adjust position if bubble goes off screen
    if (bubbleLeft + 300 > screenWidth) {
      bubbleLeft = screenWidth - 320;
    }
    if (bubbleLeft < 20) {
      bubbleLeft = 20;
    }
    if (bubbleTop + 200 > screenHeight) {
      bubbleTop = target.globalPosition.dy - 220;
    }

    return Positioned(
      left: bubbleLeft,
      top: bubbleTop,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: screenWidth - 40,
          minWidth: 280,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Row(
              children: [
                Icon(
                  target.icon,
                  color: AppTheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    target.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Description
            Text(
              target.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            
            if (target.tips.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...target.tips.map((tip) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppTheme.warning,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ).animateWithScale(),
    );
  }

  Widget _buildNavigationButtons() {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Row(
        children: [
          // Previous button
          if (_currentTargetIndex > 0)
            Expanded(
              child: AnimatedButton(
                text: 'Previous',
                onPressed: _previousTarget,
                backgroundColor: Colors.grey.shade300,
                textColor: Colors.grey.shade700,
              ),
            )
          else
            const Expanded(child: SizedBox()),
          
          const SizedBox(width: 16),
          
          // Next/Complete button
          Expanded(
            child: AnimatedButton(
              text: _currentTargetIndex < widget.targets.length - 1 
                  ? 'Next' 
                  : 'Got it!',
              onPressed: _nextTarget,
              icon: _currentTargetIndex < widget.targets.length - 1 
                  ? Icons.arrow_forward 
                  : Icons.check,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkipButton() {
    return Positioned(
      top: 50,
      right: 20,
      child: AnimatedButton(
        text: 'Skip Tour',
        onPressed: _skipCoachMarks,
        backgroundColor: Colors.transparent,
        textColor: Colors.white,
        height: 36,
      ),
    );
  }
}

class CoachMarkTarget {
  final GlobalKey key;
  final String title;
  final String description;
  final IconData icon;
  final List<String> tips;

  CoachMarkTarget({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    this.tips = const [],
  });

  // Get the global position and size of the target widget
  Rect get globalBounds {
    final RenderBox renderBox = key.currentContext?.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    return Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
  }

  Offset get globalPosition => globalBounds.topLeft;
  Size get size => globalBounds.size;
}

// Coach mark controller for managing coach marks
class CoachMarkController {
  final List<CoachMarkTarget> targets = [];
  
  void addTarget(CoachMarkTarget target) {
    targets.add(target);
  }
  
  void removeTarget(CoachMarkTarget target) {
    targets.remove(target);
  }
  
  void clearTargets() {
    targets.clear();
  }
  
  List<CoachMarkTarget> getTargetsForFeature(String feature) {
    return targets.where((target) => 
        target.title.toLowerCase().contains(feature.toLowerCase())).toList();
  }
}

// Predefined coach marks for common features
class PredefinedCoachMarks {
  static CoachMarkTarget marketplaceFab = CoachMarkTarget(
    key: GlobalKey(),
    title: 'Create New Listing',
    description: 'Tap this button to create a new project listing and find talented freelancers.',
    icon: Icons.add_circle,
    tips: [
      'You can post projects, jobs, or gigs',
      'Set your budget and timeline',
      'Add detailed requirements',
    ],
  );

  static CoachMarkTarget searchButton = CoachMarkTarget(
    key: GlobalKey(),
    title: 'Smart Search',
    description: 'Find exactly what you\'re looking for with our advanced search and filtering.',
    icon: Icons.search,
    tips: [
      'Search by keywords, skills, or categories',
      'Use filters to narrow down results',
      'Save your searches for later',
    ],
  );

  static CoachMarkTarget chatButton = CoachMarkTarget(
    key: GlobalKey(),
    title: 'Messages',
    description: 'Stay connected with freelancers and clients through real-time messaging.',
    icon: Icons.chat,
    tips: [
      'Instant messaging with all users',
      'Share files and media',
      'Voice and video calls coming soon',
    ],
  );

  static CoachMarkTarget profileButton = CoachMarkTarget(
    key: GlobalKey(),
    title: 'Your Profile',
    description: 'Manage your profile, view your stats, and customize your experience.',
    icon: Icons.person,
    tips: [
      'Update your skills and portfolio',
      'View your earnings and ratings',
      'Customize your notification preferences',
    ],
  );

  static CoachMarkTarget notificationButton = CoachMarkTarget(
    key: GlobalKey(),
    title: 'Notifications',
    description: 'Never miss important updates about your projects and messages.',
    icon: Icons.notifications,
    tips: [
      'Real-time push notifications',
      'Email alerts for important updates',
      'Customize notification settings',
    ],
  );

  static List<CoachMarkTarget> getAllForFirstTimeUser() => [
    marketplaceFab,
    searchButton,
    chatButton,
    profileButton,
    notificationButton,
  ];

  static List<CoachMarkTarget> getForFreelancer() => [
    searchButton,
    chatButton,
    profileButton,
    notificationButton,
  ];

  static List<CoachMarkTarget> getForClient() => [
    marketplaceFab,
    searchButton,
    chatButton,
    profileButton,
    notificationButton,
  ];
}
