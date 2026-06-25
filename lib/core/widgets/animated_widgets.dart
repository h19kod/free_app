import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../services/animation_service.dart';

// Animated Button with hover and press effects
class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final IconData? icon;
  final bool isLoading;
  final AnimationType animationType;

  const AnimatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
    this.icon,
    this.isLoading = false,
    this.animationType = AnimationType.scale,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isLoading) {
          setState(() => _isPressed = true);
          _controller.forward();
        }
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.width,
              height: widget.height ?? 48,
              padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: widget.isLoading 
                    ? Colors.grey 
                    : _isPressed 
                        ? (widget.backgroundColor ?? Theme.of(context).primaryColor).withValues(alpha: 0.8)
                        : widget.backgroundColor ?? Theme.of(context).primaryColor,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
                boxShadow: _isPressed
                    ? []
                    : [
                        BoxShadow(
                          color: (widget.backgroundColor ?? Theme.of(context).primaryColor).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: widget.isLoading
                  ? Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.textColor ?? Colors.white,
                          ),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: widget.textColor ?? Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: TextStyle(
                            color: widget.textColor ?? Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    ).animateWithScale(duration: const Duration(milliseconds: 300));
  }
}

// Animated Card with hover effects
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? elevation;
  final double? borderRadius;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final AnimationType animationType;
  final Duration? animationDelay;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.margin,
    this.padding,
    this.animationType = AnimationType.slideFromBottom,
    this.animationDelay,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 4.0,
      end: (widget.elevation ?? 4.0) + 4.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: widget.margin ?? const EdgeInsets.all(8),
              padding: widget.padding ?? const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
                child: widget.child,
              ),
            ),
          );
        },
      ),
    ).animateWithSlide(
      direction: _getSlideDirection(),
      delay: widget.animationDelay,
    );
  }

  SlideDirection _getSlideDirection() {
    switch (widget.animationType) {
      case AnimationType.slideFromTop:
        return SlideDirection.top;
      case AnimationType.slideFromBottom:
        return SlideDirection.bottom;
      case AnimationType.slideFromLeft:
        return SlideDirection.left;
      case AnimationType.slideFromRight:
        return SlideDirection.right;
      default:
        return SlideDirection.bottom;
    }
  }
}

// Animated List Item
class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final AnimationType animationType;
  final Duration? delay;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.animationType = AnimationType.slideFromLeft,
    this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 375),
      delay: delay ?? Duration(milliseconds: index * 50),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: child,
        ),
      ),
    );
  }
}

// Animated Text with typewriter effect
class AnimatedText extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final Duration speed;
  final bool isTypewriter;
  final VoidCallback? onComplete;

  const AnimatedText({
    super.key,
    required this.text,
    this.textStyle,
    this.speed = const Duration(milliseconds: 50),
    this.isTypewriter = true,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (isTypewriter) {
      return AnimationService.typewriterText(
        text: text,
        textStyle: textStyle,
        speed: speed,
        onComplete: onComplete,
      );
    } else {
      return Text(
        text,
        style: textStyle,
      ).animateWithFade();
    }
  }
}

// Animated Loading Widget
class AnimatedLoadingWidget extends StatelessWidget {
  final String? message;
  final double size;
  final Color color;
  final LoadingType loadingType;

  const AnimatedLoadingWidget({
    super.key,
    this.message,
    this.size = 50.0,
    this.color = Colors.blue,
    this.loadingType = LoadingType.spinner,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLoadingWidget(),
        if (message != null) ...[
          const SizedBox(height: 16),
          AnimatedText(
            text: message!,
            textStyle: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingWidget() {
    switch (loadingType) {
      case LoadingType.spinner:
        return AnimationService.loadingAnimation(
          size: size,
          color: color,
        );
      case LoadingType.dots:
        return _buildDotsLoading();
      case LoadingType.pulse:
        return _buildPulseLoading();
    }
  }

  Widget _buildDotsLoading() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ).animateWithScale(
          delay: Duration(milliseconds: index * 200),
        ).animate(onPlay: (controller) => controller.repeat(reverse: true));
      }),
    );
  }

  Widget _buildPulseLoading() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: Container(
        width: size * 0.6,
        height: size * 0.6,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    ).animateWithPulse();
  }
}

// Animated Success/Error Widget
class AnimatedStatusWidget extends StatelessWidget {
  final bool isSuccess;
  final String message;
  final IconData? icon;
  final VoidCallback? onComplete;

  const AnimatedStatusWidget({
    super.key,
    required this.isSuccess,
    required this.message,
    this.icon,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSuccess ? Colors.green : Colors.red;
    final iconData = icon ?? (isSuccess ? Icons.check_circle : Icons.error);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            iconData,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animateWithScale(
      curve: isSuccess ? AnimationService.elasticCurve : AnimationService.sharpCurve,
    );
  }
}

// Animated Counter
class AnimatedCounter extends StatefulWidget {
  final int value;
  final Duration duration;
  final TextStyle? textStyle;
  final String? prefix;
  final String? suffix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(seconds: 1),
    this.textStyle,
    this.prefix,
    this.suffix,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _counterAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _counterAnimation = IntTween(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.reset();
      _counterAnimation = IntTween(
        begin: oldWidget.value,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _counterAnimation,
      builder: (context, child) {
        return Text(
          '${widget.prefix ?? ''}${_counterAnimation.value}${widget.suffix ?? ''}',
          style: widget.textStyle,
        );
      },
    );
  }
}

// Animated Progress Bar
class AnimatedProgressBar extends StatefulWidget {
  final double value;
  final Color? backgroundColor;
  final Color? progressColor;
  final double height;
  final BorderRadius? borderRadius;
  final Duration duration;
  final String? label;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.backgroundColor,
    this.progressColor,
    this.height = 8.0,
    this.borderRadius,
    this.duration = const Duration(milliseconds: 800),
    this.label,
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.reset();
      _progressAnimation = Tween<double>(
        begin: oldWidget.value,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Theme.of(context).dividerColor,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.progressColor ?? Theme.of(context).primaryColor,
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

enum AnimationType {
  fade,
  slideFromTop,
  slideFromBottom,
  slideFromLeft,
  slideFromRight,
  scale,
  bounce,
}

enum LoadingType {
  spinner,
  dots,
  pulse,
}
