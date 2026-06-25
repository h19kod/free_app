import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_service.dart';
import '../../../core/widgets/animated_widgets.dart';

class ThemeSettingsScreen extends ConsumerStatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  ConsumerState<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends ConsumerState<ThemeSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
        backgroundColor: themeNotifier.currentTheme.appBarTheme.backgroundColor,
        foregroundColor: themeNotifier.currentTheme.appBarTheme.foregroundColor,
      ),
      body: ThemeTransition(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Theme Mode Selection
            _buildThemeModeSection(themeState, themeNotifier),
            
            const SizedBox(height: 24),
            
            // Theme Presets
            _buildThemePresetsSection(themeNotifier),
            
            const SizedBox(height: 24),
            
            // Custom Colors
            _buildCustomColorsSection(themeState, themeNotifier),
            
            const SizedBox(height: 24),
            
            // Theme Preview
            _buildThemePreviewSection(themeState),
            
            const SizedBox(height: 24),
            
            // Actions
            _buildActionsSection(themeNotifier),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeSection(ThemeState state, ThemeNotifier notifier) {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Theme Mode',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          RadioListTile<AppThemeMode>(
            title: const Text('Light'),
            subtitle: const Text('Always use light theme'),
            value: AppThemeMode.light,
            groupValue: state.themeMode,
            onChanged: (value) {
              if (value != null) notifier.setThemeMode(value);
            },
          ),
          RadioListTile<AppThemeMode>(
            title: const Text('Dark'),
            subtitle: const Text('Always use dark theme'),
            value: AppThemeMode.dark,
            groupValue: state.themeMode,
            onChanged: (value) {
              if (value != null) notifier.setThemeMode(value);
            },
          ),
          RadioListTile<AppThemeMode>(
            title: const Text('System'),
            subtitle: const Text('Follow system theme settings'),
            value: AppThemeMode.system,
            groupValue: state.themeMode,
            onChanged: (value) {
              if (value != null) notifier.setThemeMode(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemePresetsSection(ThemeNotifier notifier) {
    final presets = notifier.getAvailablePresets();
    
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Theme Presets',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Choose from our carefully designed color schemes',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: presets.length,
            itemBuilder: (context, index) {
              final preset = presets[index];
              return _buildPresetCard(preset, notifier);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPresetCard(ThemePreset preset, ThemeNotifier notifier) {
    return AnimatedCard(
      onTap: () => notifier.applyThemePreset(preset),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: preset.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: preset.accentColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            preset.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            preset.description,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomColorsSection(ThemeState state, ThemeNotifier notifier) {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Custom Colors',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: notifier.currentTheme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            title: const Text('Primary Color'),
            subtitle: const Text('Tap to change primary color'),
            trailing: const Icon(Icons.colorize),
            onTap: () => _showColorPicker(
              context, 
              'Primary Color', 
              notifier.currentTheme.colorScheme.primary,
              (color) => notifier.setCustomColors(primaryColor: color),
            ),
          ),
          const Divider(),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: notifier.currentTheme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            title: const Text('Accent Color'),
            subtitle: const Text('Tap to change accent color'),
            trailing: const Icon(Icons.colorize),
            onTap: () => _showColorPicker(
              context, 
              'Accent Color', 
              notifier.currentTheme.colorScheme.secondary,
              (color) => notifier.setCustomColors(accentColor: color),
            ),
          ),
          if (state.customColorScheme != null) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Reset to Default'),
              subtitle: const Text('Remove custom colors'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showResetDialog(notifier),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThemePreviewSection(ThemeState state) {
    final theme = ref.read(themeProvider.notifier).currentTheme;
    
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Theme Preview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: [
                // Sample AppBar
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Sample AppBar',
                      style: TextStyle(
                        color: theme.appBarTheme.foregroundColor ?? 
                               theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Sample Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                        child: const Text('Primary'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                        ),
                        child: const Text('Outline'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Sample Text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sample Heading',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is sample body text that demonstrates how the theme affects text appearance. The colors and styles will change based on your selected theme.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(ThemeNotifier notifier) {
    return Column(
      children: [
        AnimatedButton(
          text: 'Export Theme Settings',
          onPressed: () => _exportThemeSettings(notifier),
          icon: Icons.download,
          backgroundColor: Colors.grey.shade200,
          textColor: Colors.grey.shade800,
        ),
        const SizedBox(height: 12),
        AnimatedButton(
          text: 'Import Theme Settings',
          onPressed: () => _importThemeSettings(notifier),
          icon: Icons.upload,
          backgroundColor: Colors.grey.shade200,
          textColor: Colors.grey.shade800,
        ),
      ],
    );
  }

  void _showColorPicker(
    BuildContext context, 
    String title, 
    Color currentColor, 
    Function(Color) onColorSelected,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select $title'),
          content: SizedBox(
            height: 200,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
              ),
              itemCount: _predefinedColors.length,
              itemBuilder: (context, index) {
                final color = _predefinedColors[index];
                final isSelected = color.value == currentColor.value;
                
                return GestureDetector(
                  onTap: () {
                    onColorSelected(color);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected 
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showResetDialog(ThemeNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Theme'),
          content: const Text(
            'Are you sure you want to reset to the default theme? This will remove all custom colors.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                notifier.resetToDefault();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Theme reset to default')),
                );
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _exportThemeSettings(ThemeNotifier notifier) async {
    try {
      final settings = await notifier.exportThemeSettings();
      // In a real app, you would save this to a file or share it
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Theme settings exported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export: $e')),
      );
    }
  }

  void _importThemeSettings(ThemeNotifier notifier) async {
    // In a real app, you would show a file picker and import the settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import feature coming soon')),
    );
  }

  static const List<Color> _predefinedColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
  ];
}
