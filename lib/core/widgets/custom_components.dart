import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'animated_widgets.dart';

// Custom Search Bar with Suggestions
class CustomSearchBar extends StatefulWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final List<String>? suggestions;
  final ValueChanged<String>? onSuggestionSelected;
  final TextEditingController? controller;
  final bool showSuggestions;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const CustomSearchBar({
    super.key,
    this.hintText,
    this.onChanged,
    this.onClear,
    this.suggestions,
    this.onSuggestionSelected,
    this.controller,
    this.showSuggestions = true,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onTextChanged() {
    final text = _controller.text;
    widget.onChanged?.call(text);
    
    if (widget.suggestions != null) {
      setState(() {
        _filteredSuggestions = widget.suggestions!
            .where((suggestion) => suggestion.toLowerCase().contains(text.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isFocused ? AppTheme.primary : Colors.grey.shade300,
              width: _isFocused ? 2 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.hintText ?? 'Search...',
              prefixIcon: widget.prefixIcon ?? const Icon(Icons.search),
              suffixIcon: widget.suffixIcon ?? (_controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        widget.onClear?.call();
                      },
                    )
                  : null),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        if (_isFocused && _filteredSuggestions.isNotEmpty && widget.showSuggestions)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _filteredSuggestions[index];
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(suggestion),
                  onTap: () {
                    _controller.text = suggestion;
                    widget.onSuggestionSelected?.call(suggestion);
                    _focusNode.unfocus();
                  },
                );
              },
            ),
          ).animateWithSlide(direction: SlideDirection.top),
      ],
    );
  }
}

// Custom Filter Chip with Animation
class CustomFilterChip extends StatefulWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;
  final Color? selectedColor;
  final Color? unselectedColor;

  const CustomFilterChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onSelected,
    this.icon,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  State<CustomFilterChip> createState() => _CustomFilterChipState();
}

class _CustomFilterChipState extends State<CustomFilterChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
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
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) {
              _controller.reverse();
              widget.onSelected?.call(!widget.selected);
            },
            onTapCancel: () => _controller.reverse(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.selected
                    ? (widget.selectedColor ?? AppTheme.primary)
                    : (widget.unselectedColor ?? Colors.grey.shade200),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.selected
                      ? (widget.selectedColor ?? AppTheme.primary)
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 16,
                      color: widget.selected ? Colors.white : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.selected ? Colors.white : Colors.grey.shade700,
                      fontWeight: widget.selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Custom Status Card with Progress
class CustomStatusCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final Color progressColor;
  final IconData? icon;
  final VoidCallback? onTap;
  final List<Widget>? actions;

  const CustomStatusCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.progressColor,
    this.icon,
    this.onTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: progressColor, size: 24),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (actions != null) ...actions,
            ],
          ),
          const SizedBox(height: 16),
          AnimatedProgressBar(
            value: progress,
            progressColor: progressColor,
            height: 8,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}% Complete',
                style: TextStyle(
                  fontSize: 12,
                  color: progressColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${((1 - progress) * 100).toInt()}% Remaining',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom Stats Grid
class CustomStatsGrid extends StatelessWidget {
  final List<CustomStatItem> items;

  const CustomStatsGrid({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return CustomStatCard(item: items[index]);
      },
    );
  }
}

class CustomStatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? change;
  final bool isPositiveChange;

  CustomStatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.change,
    this.isPositiveChange = true,
  });
}

class CustomStatCard extends StatelessWidget {
  final CustomStatItem item;

  const CustomStatCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
              const Spacer(),
              if (item.change != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isPositiveChange 
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.isPositiveChange ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: item.isPositiveChange ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        item.change!,
                        style: TextStyle(
                          fontSize: 12,
                          color: item.isPositiveChange ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedCounter(
            value: int.tryParse(item.value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
            textStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Notification Badge
class CustomNotificationBadge extends StatelessWidget {
  final Widget child;
  final int count;
  final bool showBadge;
  final Color? badgeColor;
  final Color? textColor;

  const CustomNotificationBadge({
    super.key,
    required this.child,
    required this.count,
    this.showBadge = true,
    this.badgeColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (showBadge && count > 0)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: badgeColor ?? Colors.red,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ).animateWithPulse(),
          ),
      ],
    );
  }
}

// Custom Empty State Widget
class CustomEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget? customIllustration;

  const CustomEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.actionText,
    this.onAction,
    this.customIllustration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (customIllustration != null)
              customIllustration!
            else if (icon != null)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 60,
                  color: AppTheme.primary,
                ),
              ).animateWithScale(),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ).animateWithSlide(direction: SlideDirection.bottom),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ).animateWithSlide(direction: SlideDirection.bottom),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              AnimatedButton(
                text: actionText!,
                onPressed: onAction,
                icon: Icons.add,
              ).animateWithSlide(direction: SlideDirection.bottom),
            ],
          ],
        ),
      ),
    );
  }
}

// Custom Loading Skeleton
class CustomLoadingSkeleton extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;

  const CustomLoadingSkeleton({
    super.key,
    required this.height,
    this.width = double.infinity,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    ).animateWithShimmer();
  }
}

// Custom Avatar with Online Status
class CustomAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final bool isOnline;
  final VoidCallback? onTap;

  const CustomAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 50,
    this.isOnline = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade300,
            ),
            child: imageUrl != null
                ? ClipOval(
                    child: Image.network(
                      imageUrl!,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildInitials();
                      },
                    ),
                  )
                : _buildInitials(),
          ),
          if (isOnline)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ).animateWithPulse(),
            ),
        ],
      ),
    );
  }

  Widget _buildInitials() {
    if (name == null || name!.isEmpty) {
      return Icon(Icons.person, size: size * 0.6, color: Colors.grey.shade600);
    }
    
    final initials = name!
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase())
        .take(2)
        .join('');
    
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}

// Custom Tab Bar with Indicator
class CustomTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onTabSelected;
  final Color? selectedColor;
  final Color? unselectedColor;
  final double? height;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    this.onTabSelected,
    this.selectedColor,
    this.unselectedColor,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == selectedIndex;
          
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected?.call(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (selectedColor ?? AppTheme.primary)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    tab,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (unselectedColor ?? AppTheme.textSecondary),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
