import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class AnimationService {
  // Animation durations
  static const Duration fastDuration = Duration(milliseconds: 300);
  static const Duration mediumDuration = Duration(milliseconds: 500);
  static const Duration slowDuration = Duration(milliseconds: 800);
  static const Duration extraSlowDuration = Duration(milliseconds: 1200);

  // Animation curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.bounceOut;
  static const Curve elasticCurve = Curves.elasticOut;
  static const Curve sharpCurve = Curves.easeInOutCubic;
  static const Curve smoothCurve = Curves.easeInOutCirc;

  // Fade in animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = defaultCurve,
    Duration delay = Duration.zero,
  }) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: duration, curve: curve);
  }

  // Slide in from bottom
  static Widget slideInFromBottom({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = defaultCurve,
    Duration delay = Duration.zero,
    double begin = 0.3,
  }) {
    return child
        .animate(delay: delay)
        .slideY(begin: begin, end: 0, duration: duration, curve: curve)
        .fadeIn(duration: duration * 0.8, curve: curve);
  }

  // Slide in from top
  static Widget slideInFromTop({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = defaultCurve,
    Duration delay = Duration.zero,
    double begin = -0.3,
  }) {
    return child
        .animate(delay: delay)
        .slideY(begin: begin, end: 0, duration: duration, curve: curve)
        .fadeIn(duration: duration * 0.8, curve: curve);
  }

  // Slide in from left
  static Widget slideInFromLeft({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = defaultCurve,
    Duration delay = Duration.zero,
    double begin = -0.3,
  }) {
    return child
        .animate(delay: delay)
        .slideX(begin: begin, end: 0, duration: duration, curve: curve)
        .fadeIn(duration: duration * 0.8, curve: curve);
  }

  // Slide in from right
  static Widget slideInFromRight({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = defaultCurve,
    Duration delay = Duration.zero,
    double begin = 0.3,
  }) {
    return child
        .animate(delay: delay)
        .slideX(begin: begin, end: 0, duration: duration, curve: curve)
        .fadeIn(duration: duration * 0.8, curve: curve);
  }

  // Scale in animation
  static Widget scaleIn({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = elasticCurve,
    Duration delay = Duration.zero,
    double begin = 0.0,
  }) {
    return child
        .animate(delay: delay)
        .scale(begin: begin, end: 1.0, duration: duration, curve: curve)
        .fadeIn(duration: duration * 0.8, curve: curve);
  }

  // Bounce in animation
  static Widget bounceIn({
    required Widget child,
    Duration duration = slowDuration,
    Curve curve = bounceCurve,
    Duration delay = Duration.zero,
  }) {
    return child
        .animate(delay: delay)
        .scale(begin: 0.0, end: 1.0, duration: duration, curve: curve)
        .fadeIn(duration: duration * 0.8, curve: curve);
  }

  // Shimmer loading effect
  static Widget shimmer({
    required Widget child,
    Color baseColor = Colors.grey,
    Color highlightColor = Colors.white,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return AnimatedContainer(
      duration: duration,
      child: child,
    ).animate(onPlay: (controller) => controller.repeat()).shimmer(
      duration: duration,
      color: baseColor,
      angle: 0.5,
    );
  }

  // Pulse animation
  static Widget pulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
    double scale = 1.05,
  }) {
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: 1.0,
          end: scale,
          duration: duration,
          curve: Curves.easeInOut,
        );
  }

  // Shake animation for error states
  static Widget shake({
    required Widget child,
    Duration duration = fastDuration,
    double offset = 10.0,
  }) {
    return child
        .animate()
        .shake(
          duration: duration,
          hz: 4,
          offset: offset,
          rotation: 0.05,
        );
  }

  // Typewriter text animation
  static Widget typewriterText({
    required String text,
    TextStyle? textStyle,
    Duration speed = const Duration(milliseconds: 50),
    Function()? onComplete,
  }) {
    return AnimatedTextKit(
      animatedTexts: [
        TypewriterAnimatedText(
          text,
          textStyle: textStyle,
          speed: speed,
          cursor: '|',
        ),
      ],
      totalRepeatCount: 1,
      onFinished: onComplete,
    );
  }

  // Fade through text animation
  static Widget fadeThroughText({
    required List<String> texts,
    TextStyle? textStyle,
    Duration duration = const Duration(milliseconds: 2000),
    Function(String)? onNext,
  }) {
    return AnimatedTextKit(
      animatedTexts: texts.map((text) {
        return FadeAnimatedText(
          text,
          textStyle: textStyle,
          duration: duration,
        );
      }).toList(),
      onFinished: () => onNext?.call(texts.last),
      repeatForever: true,
    );
  }

  // Staggered list animation
  static Widget staggeredList({
    required List<Widget> children,
    Duration duration = mediumDuration,
    Duration delay = Duration.zero,
    double slideOffset = 0.1,
  }) {
    return AnimationLimiter(
      child: Column(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: duration,
            delay: delay,
            child: SlideAnimation(
              verticalOffset: slideOffset,
              child: FadeInAnimation(
                child: child,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Staggered grid animation
  static Widget staggeredGrid({
    required List<Widget> children,
    int columns = 2,
    Duration duration = mediumDuration,
    Duration delay = Duration.zero,
    double slideOffset = 0.1,
  }) {
    return AnimationLimiter(
      child: GridView.count(
        crossAxisCount: columns,
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: duration,
            delay: delay,
            columnCount: columns,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: child,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Page transition animations
  static Widget pageTransition({
    required Widget child,
    PageTransitionType type = PageTransitionType.fade,
    Duration duration = mediumDuration,
    Curve curve = defaultCurve,
  }) {
    switch (type) {
      case PageTransitionType.fade:
        return fadeIn(child: child, duration: duration, curve: curve);
      case PageTransitionType.slideFromBottom:
        return slideInFromBottom(child: child, duration: duration, curve: curve);
      case PageTransitionType.slideFromTop:
        return slideInFromTop(child: child, duration: duration, curve: curve);
      case PageTransitionType.slideFromLeft:
        return slideInFromLeft(child: child, duration: duration, curve: curve);
      case PageTransitionType.slideFromRight:
        return slideInFromRight(child: child, duration: duration, curve: curve);
      case PageTransitionType.scale:
        return scaleIn(child: child, duration: duration, curve: curve);
      case PageTransitionType.bounce:
        return bounceIn(child: child, duration: duration, curve: curve);
    }
  }

  // Loading animation with custom child
  static Widget loadingAnimation({
    Widget? child,
    double size = 50.0,
    Color color = Colors.blue,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: child ?? CircularProgressIndicator(
        strokeWidth: 3.0,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    ).animate(onPlay: (controller) => controller.repeat()).rotate(
      duration: duration,
      curve: Curves.linear,
    );
  }

  // Success animation
  static Widget successAnimation({
    required Widget child,
    Duration duration = slowDuration,
    VoidCallback? onComplete,
  }) {
    return child
        .animate(onComplete: (controller) => onComplete?.call())
        .scale(begin: 0.0, end: 1.2, duration: duration * 0.5, curve: elasticCurve)
        .then()
        .scale(begin: 1.2, end: 1.0, duration: duration * 0.5, curve: sharpCurve);
  }

  // Error animation
  static Widget errorAnimation({
    required Widget child,
    Duration duration = fastDuration,
    VoidCallback? onComplete,
  }) {
    return child
        .animate(onComplete: (controller) => onComplete?.call())
        .shake(duration: duration, hz: 5, offset: 15.0)
        .then()
        .tint(color: Colors.red, duration: duration * 0.5)
        .then()
        .tint(color: Colors.transparent, duration: duration * 0.5);
  }

  // Floating animation
  static Widget floating({
    required Widget child,
    Duration duration = const Duration(milliseconds: 2000),
    double offset = 10.0,
  }) {
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .moveY(begin: 0, end: -offset, duration: duration, curve: Curves.easeInOut);
  }

  // Glow animation
  static Widget glow({
    required Widget child,
    Color glowColor = Colors.blue,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shadowColor(
          begin: Colors.transparent,
          end: glowColor.withValues(alpha: 0.5),
          duration: duration,
          curve: Curves.easeInOut,
        )
        .then()
        .shadowBlur(
          begin: 0,
          end: 20.0,
          duration: duration,
          curve: Curves.easeInOut,
        );
  }

  // Morph animation (shape transformation)
  static Widget morph({
    required Widget child,
    BorderRadius? begin,
    BorderRadius? end,
    Duration duration = mediumDuration,
    Curve curve = defaultCurve,
  }) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      decoration: BoxDecoration(
        borderRadius: end ?? BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  // Flip animation
  static Widget flip({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = defaultCurve,
  }) {
    return AnimatedBuilder(
      animation: const AlwaysStoppedAnimation(0),
      builder: (context, _) {
        return Transform.rotate(
          angle: 0,
          child: child,
        );
      },
    ).animate().rotate(
      begin: 0,
      end: 3.14159, // 180 degrees
      duration: duration,
      curve: curve,
    );
  }

  // Custom staggered animation for complex layouts
  static Widget customStagger({
    required List<Widget> children,
    required List<AnimationEffect> effects,
    Duration? delay,
  }) {
    return AnimationLimiter(
      child: Column(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: mediumDuration,
            delay: delay ?? Duration(milliseconds: index * 100),
            child: Animate(
              effects: effects,
              child: child,
            ),
          );
        }).toList(),
      ),
    );
  }
}

enum PageTransitionType {
  fade,
  slideFromBottom,
  slideFromTop,
  slideFromLeft,
  slideFromRight,
  scale,
  bounce,
}

// Extension methods for easy animation usage
extension AnimationExtensions on Widget {
  Widget animateWithFade({Duration? duration, Curve? curve, Duration? delay}) {
    return AnimationService.fadeIn(
      child: this,
      duration: duration ?? AnimationService.mediumDuration,
      curve: curve ?? AnimationService.defaultCurve,
      delay: delay ?? Duration.zero,
    );
  }

  Widget animateWithSlide({
    SlideDirection direction = SlideDirection.bottom,
    Duration? duration,
    Curve? curve,
    Duration? delay,
  }) {
    switch (direction) {
      case SlideDirection.bottom:
        return AnimationService.slideInFromBottom(
          child: this,
          duration: duration ?? AnimationService.mediumDuration,
          curve: curve ?? AnimationService.defaultCurve,
          delay: delay ?? Duration.zero,
        );
      case SlideDirection.top:
        return AnimationService.slideInFromTop(
          child: this,
          duration: duration ?? AnimationService.mediumDuration,
          curve: curve ?? AnimationService.defaultCurve,
          delay: delay ?? Duration.zero,
        );
      case SlideDirection.left:
        return AnimationService.slideInFromLeft(
          child: this,
          duration: duration ?? AnimationService.mediumDuration,
          curve: curve ?? AnimationService.defaultCurve,
          delay: delay ?? Duration.zero,
        );
      case SlideDirection.right:
        return AnimationService.slideInFromRight(
          child: this,
          duration: duration ?? AnimationService.mediumDuration,
          curve: curve ?? AnimationService.defaultCurve,
          delay: delay ?? Duration.zero,
        );
    }
  }

  Widget animateWithScale({
    Duration? duration,
    Curve? curve,
    Duration? delay,
  }) {
    return AnimationService.scaleIn(
      child: this,
      duration: duration ?? AnimationService.mediumDuration,
      curve: curve ?? AnimationService.elasticCurve,
      delay: delay ?? Duration.zero,
    );
  }

  Widget animateWithBounce({
    Duration? duration,
    Curve? curve,
    Duration? delay,
  }) {
    return AnimationService.bounceIn(
      child: this,
      duration: duration ?? AnimationService.slowDuration,
      curve: curve ?? AnimationService.bounceCurve,
      delay: delay ?? Duration.zero,
    );
  }

  Widget animateWithShimmer({
    Color? baseColor,
    Color? highlightColor,
    Duration? duration,
  }) {
    return AnimationService.shimmer(
      child: this,
      baseColor: baseColor ?? Colors.grey,
      highlightColor: highlightColor ?? Colors.white,
      duration: duration ?? const Duration(milliseconds: 1500),
    );
  }

  Widget animateWithPulse({
    Duration? duration,
    double? scale,
  }) {
    return AnimationService.pulse(
      child: this,
      duration: duration ?? const Duration(milliseconds: 1000),
      scale: scale ?? 1.05,
    );
  }

  Widget animateWithShake({
    Duration? duration,
    double? offset,
  }) {
    return AnimationService.shake(
      child: this,
      duration: duration ?? AnimationService.fastDuration,
      offset: offset ?? 10.0,
    );
  }

  Widget animateWithFloating({
    Duration? duration,
    double? offset,
  }) {
    return AnimationService.floating(
      child: this,
      duration: duration ?? const Duration(milliseconds: 2000),
      offset: offset ?? 10.0,
    );
  }

  Widget animateWithGlow({
    Color? glowColor,
    Duration? duration,
  }) {
    return AnimationService.glow(
      child: this,
      glowColor: glowColor ?? Colors.blue,
      duration: duration ?? const Duration(milliseconds: 1500),
    );
  }
}

enum SlideDirection {
  bottom,
  top,
  left,
  right,
}
