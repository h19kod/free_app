import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final localizationService = LocalizationService();

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final locale = context.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr()),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Language Section
          _buildSection(
            context,
            title: 'language'.tr(),
            children: [
              _buildLanguageSelector(context, settingsNotifier, locale),
            ],
          ),

          const SizedBox(height: 24),

          // Theme Section
          _buildSection(
            context,
            title: 'theme'.tr(),
            children: [
              _buildThemeSelector(context, settingsNotifier, settingsState),
            ],
          ),

          const SizedBox(height: 24),

          // Security Section
          _buildSection(
            context,
            title: 'Security',
            children: [
              _buildBiometricToggle(context, settingsNotifier, settingsState),
              _buildTwoFactorToggle(context, settingsNotifier, settingsState),
            ],
          ),

          const SizedBox(height: 24),

          // Payment Section
          _buildSection(
            context,
            title: 'payment'.tr(),
            children: [
              _buildCurrencySelector(context, settingsNotifier, settingsState),
              _buildPaymentMethods(context),
            ],
          ),

          const SizedBox(height: 24),

          // Notifications Section
          _buildSection(
            context,
            title: 'notifications'.tr(),
            children: [
              _buildNotificationSettings(context, settingsNotifier, settingsState),
            ],
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSection(
            context,
            title: 'About',
            children: [
              _buildAboutSection(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final locale = context.locale;
    
    return Card(
      child: Padding(
        padding: localizationService.getEdgeInsets(locale,
          top: 16,
          bottom: 16,
          start: 16,
          end: 16,
        ),
        child: Column(
          crossAxisAlignment: localizationService.getCrossAxisAlignment(locale),
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(
    BuildContext context,
    SettingsNotifier notifier,
    Locale currentLocale,
  ) {
    final locale = context.locale;
    final supportedLocales = localizationService.getSupportedLocales();
    
    return Column(
      crossAxisAlignment: localizationService.getCrossAxisAlignment(locale),
      children: [
        Text(
          'Select your preferred language',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 12),
        ...supportedLocales.map((supportedLocale) {
          final isSelected = supportedLocale.languageCode == currentLocale.languageCode;
          final displayName = localizationService.getLocaleDisplayName(supportedLocale);
          
          return RadioListTile<Locale>(
            title: localizationService.buildLocalizedRow(
              context: context,
              children: [
                Text(displayName),
                if (localizationService.isRTL(supportedLocale)) ...[
                  const SizedBox(width: 8),
                  const Text('🔄'),
                ],
              ],
            ),
            value: supportedLocale,
            groupValue: currentLocale,
            onChanged: (Locale? newLocale) async {
              if (newLocale != null) {
                await localizationService.changeLanguage(context, newLocale.languageCode);
                notifier.updateLanguage(newLocale.languageCode);
              }
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    SettingsNotifier notifier,
    SettingsState state,
  ) {
    final locale = context.locale;
    
    return Column(
      crossAxisAlignment: localizationService.getCrossAxisAlignment(locale),
      children: [
        Text(
          'Choose your preferred theme',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 12),
        RadioListTile<ThemeMode>(
          title: Text('light_theme'.tr()),
          value: ThemeMode.light,
          groupValue: state.themeMode,
          onChanged: (ThemeMode? mode) {
            if (mode != null) {
              notifier.updateThemeMode(mode);
            }
          },
        ),
        RadioListTile<ThemeMode>(
          title: Text('dark_theme'.tr()),
          value: ThemeMode.dark,
          groupValue: state.themeMode,
          onChanged: (ThemeMode? mode) {
            if (mode != null) {
              notifier.updateThemeMode(mode);
            }
          },
        ),
        RadioListTile<ThemeMode>(
          title: Text('System Default'),
          value: ThemeMode.system,
          groupValue: state.themeMode,
          onChanged: (ThemeMode? mode) {
            if (mode != null) {
              notifier.updateThemeMode(mode);
            }
          },
        ),
      ],
    );
  }

  Widget _buildBiometricToggle(
    BuildContext context,
    SettingsNotifier notifier,
    SettingsState state,
  ) {
    final locale = context.locale;
    
    return SwitchListTile(
      title: Text('Biometric Authentication'),
      subtitle: Text('Use fingerprint or face to unlock'),
      value: state.isBiometricEnabled,
      onChanged: (bool value) async {
        if (value) {
          final result = await notifier.enableBiometric(context);
          if (!result.success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result.error ?? 'Failed to enable biometrics')),
            );
          }
        } else {
          final success = await notifier.disableBiometric();
          if (!success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to disable biometrics')),
            );
          }
        }
      },
      secondary: Icon(Icons.fingerprint),
    );
  }

  Widget _buildTwoFactorToggle(
    BuildContext context,
    SettingsNotifier notifier,
    SettingsState state,
  ) {
    return SwitchListTile(
      title: Text('Two-Factor Authentication'),
      subtitle: Text('Add an extra layer of security'),
      value: state.isTwoFactorEnabled,
      onChanged: (bool value) async {
        if (value) {
          final success = await Navigator.of(context).pushNamed('/two-factor-setup');
          if (success == true) {
            await notifier.checkTwoFactorStatus();
          }
        } else {
          final success = await Navigator.of(context).pushNamed('/two-factor-disable');
          if (success == true) {
            await notifier.checkTwoFactorStatus();
          }
        }
      },
      secondary: Icon(Icons.security),
    );
  }

  Widget _buildCurrencySelector(
    BuildContext context,
    SettingsNotifier notifier,
    SettingsState state,
  ) {
    final locale = context.locale;
    
    return ListTile(
      title: Text('Default Currency'),
      subtitle: Text(state.selectedCurrency.name),
      trailing: Text(state.selectedCurrency.symbol),
      leading: Icon(Icons.attach_money),
      onTap: () {
        _showCurrencySelector(context, notifier, state.selectedCurrency);
      },
    );
  }

  Widget _buildPaymentMethods(BuildContext context) {
    return ListTile(
      title: Text('Payment Methods'),
      subtitle: Text('Manage your payment methods'),
      leading: Icon(Icons.credit_card),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.of(context).pushNamed('/payment');
      },
    );
  }

  Widget _buildNotificationSettings(
    BuildContext context,
    SettingsNotifier notifier,
    SettingsState state,
  ) {
    return Column(
      children: [
        SwitchListTile(
          title: Text('push_notifications'.tr()),
          subtitle: Text('Receive push notifications'),
          value: state.pushNotificationsEnabled,
          onChanged: (bool value) {
            notifier.updateNotificationSettings('push', value);
          },
          secondary: Icon(Icons.notifications),
        ),
        SwitchListTile(
          title: Text('email_notifications'.tr()),
          subtitle: Text('Receive email notifications'),
          value: state.emailNotificationsEnabled,
          onChanged: (bool value) {
            notifier.updateNotificationSettings('email', value);
          },
          secondary: Icon(Icons.email),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text('Version'),
          subtitle: Text('1.0.0'),
          leading: Icon(Icons.info),
        ),
        ListTile(
          title: Text('terms'.tr()),
          leading: Icon(Icons.description),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            _showTermsDialog(context);
          },
        ),
        ListTile(
          title: Text('privacy'.tr()),
          leading: Icon(Icons.privacy_tip),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            _showPrivacyDialog(context);
          },
        ),
        ListTile(
          title: Text('help'.tr()),
          leading: Icon(Icons.help),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            _showHelpDialog(context);
          },
        ),
      ],
    );
  }

  void _showCurrencySelector(
    BuildContext context,
    SettingsNotifier notifier,
    Currency currentCurrency,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Currency',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...Currency.values.map((currency) {
              return ListTile(
                title: Text(currency.name),
                subtitle: Text(currency.symbol),
                trailing: currency == currentCurrency
                    ? const Icon(Icons.check, color: AppTheme.primary)
                    : null,
                onTap: () {
                  notifier.updateCurrency(currency);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        );
      },
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('terms'.tr()),
          content: const SingleChildScrollView(
            child: Text(
              'By using this app, you agree to our terms of service. '
              'These terms govern your use of our services and outline '
              'your rights and responsibilities as a user.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('close'.tr()),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('privacy'.tr()),
          content: const SingleChildScrollView(
            child: Text(
              'We are committed to protecting your privacy. '
              'This privacy policy explains how we collect, use, '
              'and protect your personal information.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('close'.tr()),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('help'.tr()),
          content: const SingleChildScrollView(
            child: Text(
              'If you need help with the app, please contact our '
              'support team at support@appmarket.com or visit our '
              'help center at help.appmarket.com',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('close'.tr()),
            ),
          ],
        );
      },
    );
  }
}
