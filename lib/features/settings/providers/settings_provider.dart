import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/two_factor_service.dart';
import '../../../core/services/payment_service.dart';

class SettingsState {
  final bool isLoading;
  final String? error;
  final ThemeMode themeMode;
  final String selectedLanguage;
  final Currency selectedCurrency;
  final bool isBiometricEnabled;
  final bool isTwoFactorEnabled;
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final BiometricType biometricType;

  const SettingsState({
    this.isLoading = false,
    this.error,
    this.themeMode = ThemeMode.light,
    this.selectedLanguage = 'en',
    this.selectedCurrency = Currency.USD,
    this.isBiometricEnabled = false,
    this.isTwoFactorEnabled = false,
    this.pushNotificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.biometricType = BiometricType.none,
  });

  SettingsState copyWith({
    bool? isLoading,
    String? error,
    ThemeMode? themeMode,
    String? selectedLanguage,
    Currency? selectedCurrency,
    bool? isBiometricEnabled,
    bool? isTwoFactorEnabled,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    BiometricType? biometricType,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      themeMode: themeMode ?? this.themeMode,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isTwoFactorEnabled: isTwoFactorEnabled ?? this.isTwoFactorEnabled,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      biometricType: biometricType ?? this.biometricType,
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final BiometricService _biometricService = BiometricService();
  final TwoFactorService _twoFactorService = TwoFactorService();

  SettingsNotifier() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Load theme mode
      final themeModeString = await _storage.read(key: 'theme_mode');
      final themeMode = _parseThemeMode(themeModeString ?? 'light');

      // Load language
      final language = await _storage.read(key: 'selected_language') ?? 'en';

      // Load currency
      final currencyCode = await _storage.read(key: 'selected_currency') ?? 'USD';
      final currency = Currency.values.firstWhere((c) => c.code == currencyCode);

      // Load notification settings
      final pushEnabled = await _storage.read(key: 'push_notifications_enabled') == 'true';
      final emailEnabled = await _storage.read(key: 'email_notifications_enabled') != 'false';

      // Load biometric status
      final biometricStatus = await _loadBiometricStatus();

      // Load 2FA status
      final twoFactorStatus = await _loadTwoFactorStatus();

      state = state.copyWith(
        isLoading: false,
        themeMode: themeMode,
        selectedLanguage: language,
        selectedCurrency: currency,
        pushNotificationsEnabled: pushEnabled,
        emailNotificationsEnabled: emailEnabled,
        isBiometricEnabled: biometricStatus['enabled'],
        biometricType: biometricStatus['type'],
        isTwoFactorEnabled: twoFactorStatus,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load settings: $e',
      );
    }
  }

  ThemeMode _parseThemeMode(String themeModeString) {
    switch (themeModeString) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  String _themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
      default:
        return 'light';
    }
  }

  Future<Map<String, dynamic>> _loadBiometricStatus() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return {'enabled': false, 'type': BiometricType.none};
      }

      final isEnabled = await _biometricService.isBiometricEnabled(userId);
      final type = await _biometricService.getBiometricType(userId);

      return {'enabled': isEnabled, 'type': type};
    } catch (e) {
      return {'enabled': false, 'type': BiometricType.none};
    }
  }

  Future<bool> _loadTwoFactorStatus() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return false;
      }

      return await _twoFactorService.isTwoFactorEnabled(userId);
    } catch (e) {
      return false;
    }
  }

  Future<String?> _getCurrentUserId() async {
    // In a real app, get current user ID from auth service
    return await _storage.read(key: 'current_user_id');
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    try {
      await _storage.write(key: 'theme_mode', value: _themeModeToString(themeMode));
      state = state.copyWith(themeMode: themeMode);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update theme: $e');
    }
  }

  Future<void> updateLanguage(String languageCode) async {
    try {
      await _storage.write(key: 'selected_language', value: languageCode);
      state = state.copyWith(selectedLanguage: languageCode);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update language: $e');
    }
  }

  Future<void> updateCurrency(Currency currency) async {
    try {
      await _storage.write(key: 'selected_currency', value: currency.code);
      state = state.copyWith(selectedCurrency: currency);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update currency: $e');
    }
  }

  Future<BiometricResult> enableBiometric(BuildContext context) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return BiometricResult(
          success: false,
          error: 'User not logged in',
          type: BiometricType.none,
        );
      }

      final result = await _biometricService.enableBiometric(
        userId: userId,
        reason: 'Enable biometric authentication for AppMarket',
      );

      if (result.success) {
        state = state.copyWith(
          isBiometricEnabled: true,
          biometricType: result.type,
        );
      }

      return result;
    } catch (e) {
      return BiometricResult(
        success: false,
        error: 'Failed to enable biometrics: $e',
        type: BiometricType.none,
      );
    }
  }

  Future<bool> disableBiometric() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return false;
      }

      final success = await _biometricService.disableBiometric(userId);

      if (success) {
        state = state.copyWith(
          isBiometricEnabled: false,
          biometricType: BiometricType.none,
        );
      }

      return success;
    } catch (e) {
      state = state.copyWith(error: 'Failed to disable biometrics: $e');
      return false;
    }
  }

  Future<void> checkTwoFactorStatus() async {
    try {
      final isEnabled = await _loadTwoFactorStatus();
      state = state.copyWith(isTwoFactorEnabled: isEnabled);
    } catch (e) {
      state = state.copyWith(error: 'Failed to check 2FA status: $e');
    }
  }

  Future<void> updateNotificationSettings(String type, bool enabled) async {
    try {
      switch (type) {
        case 'push':
          await _storage.write(key: 'push_notifications_enabled', value: enabled.toString());
          state = state.copyWith(pushNotificationsEnabled: enabled);
          break;
        case 'email':
          await _storage.write(key: 'email_notifications_enabled', value: enabled.toString());
          state = state.copyWith(emailNotificationsEnabled: enabled);
          break;
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to update notification settings: $e');
    }
  }

  Future<void> resetSettings() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Clear all settings from storage
      await _storage.delete(key: 'theme_mode');
      await _storage.delete(key: 'selected_language');
      await _storage.delete(key: 'selected_currency');
      await _storage.delete(key: 'push_notifications_enabled');
      await _storage.delete(key: 'email_notifications_enabled');

      // Reset to defaults
      state = const SettingsState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to reset settings: $e',
      );
    }
  }

  Future<Map<String, dynamic>> exportSettings() async {
    try {
      return {
        'theme_mode': _themeModeToString(state.themeMode),
        'selected_language': state.selectedLanguage,
        'selected_currency': state.selectedCurrency.code,
        'push_notifications_enabled': state.pushNotificationsEnabled,
        'email_notifications_enabled': state.emailNotificationsEnabled,
        'exported_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to export settings: $e');
    }
  }

  Future<void> importSettings(Map<String, dynamic> settings) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Import theme mode
      if (settings.containsKey('theme_mode')) {
        final themeMode = _parseThemeMode(settings['theme_mode']);
        await updateThemeMode(themeMode);
      }

      // Import language
      if (settings.containsKey('selected_language')) {
        await updateLanguage(settings['selected_language']);
      }

      // Import currency
      if (settings.containsKey('selected_currency')) {
        final currency = Currency.values.firstWhere(
          (c) => c.code == settings['selected_currency'],
          orElse: () => Currency.USD,
        );
        await updateCurrency(currency);
      }

      // Import notification settings
      if (settings.containsKey('push_notifications_enabled')) {
        await updateNotificationSettings('push', settings['push_notifications_enabled']);
      }

      if (settings.containsKey('email_notifications_enabled')) {
        await updateNotificationSettings('email', settings['email_notifications_enabled']);
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to import settings: $e',
      );
    }
  }

  Future<Map<String, dynamic>> getSystemInfo() async {
    try {
      final userId = await _getCurrentUserId();
      final biometricStatus = userId != null 
          ? await _biometricService.getBiometricStatus(userId)
          : null;

      return {
        'app_version': '1.0.0',
        'build_number': '1',
        'platform': 'Flutter',
        'user_id': userId,
        'biometric_status': biometricStatus,
        'current_language': state.selectedLanguage,
        'current_currency': state.selectedCurrency.code,
        'current_theme': _themeModeToString(state.themeMode),
        'notifications': {
          'push_enabled': state.pushNotificationsEnabled,
          'email_enabled': state.emailNotificationsEnabled,
        },
        'security': {
          'biometric_enabled': state.isBiometricEnabled,
          'biometric_type': state.biometricType.name,
          'two_factor_enabled': state.isTwoFactorEnabled,
        },
      };
    } catch (e) {
      throw Exception('Failed to get system info: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> refreshSettings() async {
    await _loadSettings();
  }
}
