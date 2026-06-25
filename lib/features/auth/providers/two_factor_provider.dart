import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/two_factor_service.dart';
import '../../../core/services/api_service.dart';

enum TwoFactorSetupStep {
  scan,
  verify,
  backup,
  complete,
}

class TwoFactorState {
  final bool isLoading;
  final String? error;
  final TwoFactorSetupStep setupStep;
  final String? qrCodeData;
  final String? secretKey;
  final List<String>? backupCodes;
  final bool isEnabled;

  const TwoFactorState({
    this.isLoading = false,
    this.error,
    this.setupStep = TwoFactorSetupStep.scan,
    this.qrCodeData,
    this.secretKey,
    this.backupCodes,
    this.isEnabled = false,
  });

  TwoFactorState copyWith({
    bool? isLoading,
    String? error,
    TwoFactorSetupStep? setupStep,
    String? qrCodeData,
    String? secretKey,
    List<String>? backupCodes,
    bool? isEnabled,
  }) {
    return TwoFactorState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      setupStep: setupStep ?? this.setupStep,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      secretKey: secretKey ?? this.secretKey,
      backupCodes: backupCodes ?? this.backupCodes,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

final twoFactorProvider = StateNotifierProvider<TwoFactorNotifier, TwoFactorState>((ref) {
  final twoFactorService = ref.watch(twoFactorServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  return TwoFactorNotifier(twoFactorService, apiService);
});

class TwoFactorNotifier extends StateNotifier<TwoFactorState> {
  final TwoFactorService _twoFactorService;
  final ApiService _apiService;

  TwoFactorNotifier(this._twoFactorService, this._apiService) 
      : super(const TwoFactorState());

  Future<void> initializeSetup() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Get current user
      final user = await _getCurrentUser();
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Generate secret and QR code
      final secret = _twoFactorService.generateSecret();
      final email = user['email'] ?? 'user@example.com';
      final qrCodeData = _twoFactorService.generateQRCodeData(
        secret,
        email,
        'AppMarket',
      );

      state = state.copyWith(
        isLoading: false,
        secretKey: secret,
        qrCodeData: qrCodeData,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize 2FA setup: $e',
      );
    }
  }

  Future<void> checkTwoFactorStatus() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final user = await _getCurrentUser();
      if (user == null) {
        throw Exception('User not logged in');
      }

      final isEnabled = await _twoFactorService.isTwoFactorEnabled(user['id']);
      
      state = state.copyWith(
        isLoading: false,
        isEnabled: isEnabled,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to check 2FA status: $e',
      );
    }
  }

  Future<bool> verifyCode(String code) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final user = await _getCurrentUser();
      if (user == null || state.secretKey == null) {
        throw Exception('Setup not initialized');
      }

      // Verify the code
      final isValid = _twoFactorService.verifyTOTP(state.secretKey!, code);
      if (!isValid) {
        throw Exception('Invalid verification code');
      }

      // Enable 2FA
      await _twoFactorService.enableTwoFactor(
        userId: user['id'],
        secret: state.secretKey!,
        verificationCode: code,
      );

      // Generate backup codes
      final backupCodes = _twoFactorService.generateBackupCodes();

      state = state.copyWith(
        isLoading: false,
        backupCodes: backupCodes,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Code verification failed: $e',
      );
      return false;
    }
  }

  Future<bool> disableTwoFactor(String verificationCode) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final user = await _getCurrentUser();
      if (user == null) {
        throw Exception('User not logged in');
      }

      final success = await _twoFactorService.disableTwoFactor(
        userId: user['id'],
        verificationCode: verificationCode,
      );

      if (success) {
        state = state.copyWith(
          isLoading: false,
          isEnabled: false,
        );
      }

      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to disable 2FA: $e',
      );
      return false;
    }
  }

  Future<bool> verifyTwoFactorLogin(String code) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final user = await _getCurrentUser();
      if (user == null) {
        throw Exception('User not logged in');
      }

      final isValid = await _twoFactorService.verifyTwoFactor(
        userId: user['id'],
        code: code,
      );

      state = state.copyWith(isLoading: false);
      return isValid;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '2FA verification failed: $e',
      );
      return false;
    }
  }

  Future<List<String>?> getBackupCodes() async {
    try {
      final user = await _getCurrentUser();
      if (user == null) {
        return null;
      }

      return await _twoFactorService.getBackupCodes(user['id']);
    } catch (e) {
      state = state.copyWith(error: 'Failed to get backup codes: $e');
      return null;
    }
  }

  Future<List<String>?> regenerateBackupCodes() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final user = await _getCurrentUser();
      if (user == null) {
        throw Exception('User not logged in');
      }

      final backupCodes = await _twoFactorService.regenerateBackupCodes(user['id']);

      state = state.copyWith(
        isLoading: false,
        backupCodes: backupCodes,
      );

      return backupCodes;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to regenerate backup codes: $e',
      );
      return null;
    }
  }

  Future<bool> sendTwoFactorEmail() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final user = await _getCurrentUser();
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Generate a code for email verification
      final code = _twoFactorService.generateTOTP(
        _twoFactorService.generateSecret(),
      );

      final success = await _twoFactorService.sendTwoFactorEmail(
        email: user['email'],
        code: code,
      );

      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to send 2FA email: $e',
      );
      return false;
    }
  }

  Future<bool> sendTwoFactorSMS(String phoneNumber) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Generate a code for SMS verification
      final code = _twoFactorService.generateTOTP(
        _twoFactorService.generateSecret(),
      );

      final success = await _twoFactorService.sendTwoFactorSMS(
        phoneNumber: phoneNumber,
        code: code,
      );

      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to send 2FA SMS: $e',
      );
      return false;
    }
  }

  void nextStep() {
    final currentStepIndex = TwoFactorSetupStep.values.indexOf(state.setupStep);
    if (currentStepIndex < TwoFactorSetupStep.values.length - 1) {
      state = state.copyWith(
        setupStep: TwoFactorSetupStep.values[currentStepIndex + 1],
      );
    }
  }

  void previousStep() {
    final currentStepIndex = TwoFactorSetupStep.values.indexOf(state.setupStep);
    if (currentStepIndex > 0) {
      state = state.copyWith(
        setupStep: TwoFactorSetupStep.values[currentStepIndex - 1],
      );
    }
  }

  void completeSetup() {
    state = state.copyWith(
      setupStep: TwoFactorSetupStep.complete,
      isEnabled: true,
    );
  }

  void resetSetup() {
    state = const TwoFactorState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<Map<String, dynamic>?> _getCurrentUser() async {
    try {
      final response = await _apiService.getMe();
      return response.data;
    } catch (e) {
      return null;
    }
  }
}
