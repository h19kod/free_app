import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app_theme.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

class ThemeState {
  final AppThemeMode themeMode;
  final bool isDarkMode;
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final ColorScheme? customColorScheme;

  const ThemeState({
    this.themeMode = AppThemeMode.system,
    this.isDarkMode = false,
    required this.lightTheme,
    required this.darkTheme,
    this.customColorScheme,
  });

  ThemeState copyWith({
    AppThemeMode? themeMode,
    bool? isDarkMode,
    ThemeData? lightTheme,
    ThemeData? darkTheme,
    ColorScheme? customColorScheme,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
      customColorScheme: customColorScheme ?? this.customColorScheme,
    );
  }

  ThemeData get currentTheme => isDarkMode ? darkTheme : lightTheme;
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeState> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ThemeNotifier() : super(const ThemeState(
    themeMode: AppThemeMode.system,
    isDarkMode: false,
    lightTheme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
  )) {
    _loadThemeSettings();
  }

  Future<void> _loadThemeSettings() async {
    try {
      // Load saved theme mode
      final savedThemeMode = await _storage.read(key: 'theme_mode');
      final themeMode = _parseThemeMode(savedThemeMode ?? 'system');
      
      // Load custom colors if any
      final customPrimaryColor = await _storage.read(key: 'custom_primary_color');
      final customAccentColor = await _storage.read(key: 'custom_accent_color');
      
      ColorScheme? customColorScheme;
      if (customPrimaryColor != null || customAccentColor != null) {
        customColorScheme = _createCustomColorScheme(
          primaryColor: customPrimaryColor != null 
              ? Color(int.parse(customPrimaryColor)) 
              : null,
          accentColor: customAccentColor != null 
              ? Color(int.parse(customAccentColor)) 
              : null,
        );
      }

      // Determine if dark mode should be active
      final isDarkMode = _shouldUseDarkMode(themeMode);

      state = state.copyWith(
        themeMode: themeMode,
        isDarkMode: isDarkMode,
        customColorScheme: customColorScheme,
      );
    } catch (e) {
      // Keep default theme if there's an error
    }
  }

  AppThemeMode _parseThemeMode(String themeModeString) {
    switch (themeModeString.toLowerCase()) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
      default:
        return AppThemeMode.system;
    }
  }

  String _themeModeToString(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
      case AppThemeMode.system:
        return 'system';
    }
  }

  bool _shouldUseDarkMode(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness == 
               Brightness.dark;
    }
  }

  Future<void> setThemeMode(AppThemeMode themeMode) async {
    try {
      await _storage.write(key: 'theme_mode', value: _themeModeToString(themeMode));
      
      final isDarkMode = _shouldUseDarkMode(themeMode);
      
      state = state.copyWith(
        themeMode: themeMode,
        isDarkMode: isDarkMode,
      );
    } catch (e) {
      // Handle error if needed
    }
  }

  Future<void> toggleTheme() async {
    final newMode = state.isDarkMode ? AppThemeMode.light : AppThemeMode.dark;
    await setThemeMode(newMode);
  }

  Future<void> setCustomColors({
    Color? primaryColor,
    Color? accentColor,
  }) async {
    try {
      if (primaryColor != null) {
        await _storage.write(
          key: 'custom_primary_color', 
          value: primaryColor.value.toString(),
        );
      }
      if (accentColor != null) {
        await _storage.write(
          key: 'custom_accent_color', 
          value: accentColor.value.toString(),
        );
      }

      final customColorScheme = _createCustomColorScheme(
        primaryColor: primaryColor,
        accentColor: accentColor,
      );

      state = state.copyWith(customColorScheme: customColorScheme);
    } catch (e) {
      // Handle error if needed
    }
  }

  ColorScheme _createCustomColorScheme({
    Color? primaryColor,
    Color? accentColor,
  }) {
    final baseScheme = state.isDarkMode 
        ? ThemeData.dark().colorScheme 
        : ThemeData.light().colorScheme;

    return baseScheme.copyWith(
      primary: primaryColor ?? baseScheme.primary,
      secondary: accentColor ?? baseScheme.secondary,
    );
  }

  Future<void> resetToDefault() async {
    try {
      await _storage.delete(key: 'theme_mode');
      await _storage.delete(key: 'custom_primary_color');
      await _storage.delete(key: 'custom_accent_color');

      state = const ThemeState(
        themeMode: AppThemeMode.system,
        isDarkMode: false,
        lightTheme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
      );
    } catch (e) {
      // Handle error if needed
    }
  }

  Future<void> updateSystemTheme() async {
    if (state.themeMode == AppThemeMode.system) {
      final isDarkMode = _shouldUseDarkMode(AppThemeMode.system);
      if (state.isDarkMode != isDarkMode) {
        state = state.copyWith(isDarkMode: isDarkMode);
      }
    }
  }

  // Get current theme data with customizations
  ThemeData get currentTheme {
    if (state.customColorScheme != null) {
      return _getThemeWithCustomColors(state.currentTheme, state.customColorScheme!);
    }
    return state.currentTheme;
  }

  ThemeData _getThemeWithCustomColors(ThemeData baseTheme, ColorScheme customColorScheme) {
    return baseTheme.copyWith(
      colorScheme: customColorScheme,
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: customColorScheme.primary,
        foregroundColor: customColorScheme.onPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: customColorScheme.primary,
          foregroundColor: customColorScheme.onPrimary,
        ),
      ),
      floatingActionButtonTheme: baseTheme.floatingActionButtonTheme.copyWith(
        backgroundColor: customColorScheme.primary,
        foregroundColor: customColorScheme.onPrimary,
      ),
    );
  }

  // Get theme preview data
  Map<String, dynamic> getThemePreview() {
    return {
      'themeMode': _themeModeToString(state.themeMode),
      'isDarkMode': state.isDarkMode,
      'primaryColor': currentTheme.colorScheme.primary.value,
      'secondaryColor': currentTheme.colorScheme.secondary.value,
      'backgroundColor': currentTheme.colorScheme.background.value,
      'surfaceColor': currentTheme.colorScheme.surface.value,
      'hasCustomColors': state.customColorScheme != null,
    };
  }

  // Export theme settings
  Future<Map<String, dynamic>> exportThemeSettings() async {
    return {
      'themeMode': _themeModeToString(state.themeMode),
      'customPrimaryColor': state.customColorScheme?.primary.value,
      'customAccentColor': state.customColorScheme?.secondary.value,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  // Import theme settings
  Future<void> importThemeSettings(Map<String, dynamic> settings) async {
    try {
      if (settings.containsKey('themeMode')) {
        final themeMode = _parseThemeMode(settings['themeMode']);
        await setThemeMode(themeMode);
      }

      Color? primaryColor;
      Color? accentColor;

      if (settings.containsKey('customPrimaryColor')) {
        primaryColor = Color(settings['customPrimaryColor']);
      }
      if (settings.containsKey('customAccentColor')) {
        accentColor = Color(settings['customAccentColor']);
      }

      if (primaryColor != null || accentColor != null) {
        await setCustomColors(
          primaryColor: primaryColor,
          accentColor: accentColor,
        );
      }
    } catch (e) {
      // Handle error if needed
    }
  }

  // Get available theme presets
  List<ThemePreset> getAvailablePresets() {
    return [
      ThemePreset(
        name: 'Default',
        primaryColor: AppTheme.primary,
        accentColor: AppTheme.accent,
        description: 'Original AppMarket theme',
      ),
      ThemePreset(
        name: 'Ocean Blue',
        primaryColor: const Color(0xFF2196F3),
        accentColor: const Color(0xFF03DAC6),
        description: 'Calming ocean colors',
      ),
      ThemePreset(
        name: 'Sunset Orange',
        primaryColor: const Color(0xFFFF9800),
        accentColor: const Color(0xFFFF5722),
        description: 'Warm sunset tones',
      ),
      ThemePreset(
        name: 'Forest Green',
        primaryColor: const Color(0xFF4CAF50),
        accentColor: const Color(0xFF8BC34A),
        description: 'Natural forest colors',
      ),
      ThemePreset(
        name: 'Royal Purple',
        primaryColor: const Color(0xFF9C27B0),
        accentColor: const Color(0xFFE91E63),
        description: 'Elegant royal colors',
      ),
      ThemePreset(
        name: 'Midnight Dark',
        primaryColor: const Color(0xFF121212),
        accentColor: const Color(0xFFBB86FC),
        description: 'Dark midnight theme',
      ),
    ];
  }

  // Apply theme preset
  Future<void> applyThemePreset(ThemePreset preset) async {
    await setCustomColors(
      primaryColor: preset.primaryColor,
      accentColor: preset.accentColor,
    );
  }
}

class ThemePreset {
  final String name;
  final Color primaryColor;
  final Color accentColor;
  final String description;

  ThemePreset({
    required this.name,
    required this.primaryColor,
    required this.accentColor,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'primaryColor': primaryColor.value,
      'accentColor': accentColor.value,
      'description': description,
    };
  }

  factory ThemePreset.fromJson(Map<String, dynamic> json) {
    return ThemePreset(
      name: json['name'],
      primaryColor: Color(json['primaryColor']),
      accentColor: Color(json['accentColor']),
      description: json['description'],
    );
  }
}

// Theme transition widget for smooth theme changes
class ThemeTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ThemeTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<ThemeTransition> createState() => _ThemeTransitionState();
}

class _ThemeTransitionState extends State<ThemeTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// Theme-aware widget that responds to theme changes
class ThemeAwareWidget extends ConsumerWidget {
  final Widget Function(BuildContext context, ThemeData theme) builder;

  const ThemeAwareWidget({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    
    return ThemeTransition(
      child: builder(context, themeNotifier.currentTheme),
    );
  }
}
