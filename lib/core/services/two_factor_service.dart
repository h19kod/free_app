import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';

final twoFactorServiceProvider = Provider<TwoFactorService>((ref) {
  return TwoFactorService();
});

class TwoFactorService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Generate secret key for 2FA
  String generateSecret() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  // Generate QR code data for Google Authenticator
  String generateQRCodeData(String secret, String email, String appName) {
    final uri = Uri(
      scheme: 'otpauth',
      host: 'totp',
      path: '$appName:$email',
      queryParameters: {
        'secret': secret,
        'issuer': appName,
        'algorithm': 'SHA1',
        'digits': '6',
        'period': '30',
      },
    );
    return uri.toString();
  }

  // Generate TOTP code (simplified implementation)
  String generateTOTP(String secret) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final counter = now ~/ 30;
    
    // This is a simplified TOTP generation
    // In production, use a proper TOTP library
    final hmac = Hmac(sha1, base64.decode(secret));
    final counterBytes = _intToBytes(counter);
    final digest = hmac.convert(counterBytes);
    
    final offset = digest.bytes[20 - 1] & 0x0F;
    final code = ((digest.bytes[offset] & 0x7F) << 24) |
                ((digest.bytes[offset + 1] & 0xFF) << 16) |
                ((digest.bytes[offset + 2] & 0xFF) << 8) |
                (digest.bytes[offset + 3] & 0xFF);
    
    return (code % 1000000).toString().padLeft(6, '0');
  }

  // Verify TOTP code
  bool verifyTOTP(String secret, String code) {
    // Check current code and adjacent time windows
    for (int i = -1; i <= 1; i++) {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final counter = (now ~/ 30) + i;
      
      final hmac = Hmac(sha1, base64.decode(secret));
      final counterBytes = _intToBytes(counter);
      final digest = hmac.convert(counterBytes);
      
      final offset = digest.bytes[20 - 1] & 0x0F;
      final generatedCode = ((digest.bytes[offset] & 0x7F) << 24) |
                          ((digest.bytes[offset + 1] & 0xFF) << 16) |
                          ((digest.bytes[offset + 2] & 0xFF) << 8) |
                          (digest.bytes[offset + 3] & 0xFF);
      
      final finalCode = (generatedCode % 1000000).toString().padLeft(6, '0');
      
      if (finalCode == code) {
        return true;
      }
    }
    return false;
  }

  // Generate backup codes
  List<String> generateBackupCodes() {
    final codes = <String>[];
    final random = Random.secure();
    
    for (int i = 0; i < 10; i++) {
      final code = random.nextInt(1000000).toString().padLeft(6, '0');
      codes.add(code);
    }
    
    return codes;
  }

  // Enable 2FA for user
  Future<bool> enableTwoFactor({
    required String userId,
    required String secret,
    required String verificationCode,
  }) async {
    try {
      // Verify the code before enabling 2FA
      if (!verifyTOTP(secret, verificationCode)) {
        throw Exception('Invalid verification code');
      }

      // Store 2FA settings
      await _storage.write(key: '2fa_secret_$userId', value: secret);
      await _storage.write(key: '2fa_enabled_$userId', value: 'true');
      
      // Generate and store backup codes
      final backupCodes = generateBackupCodes();
      await _storage.write(
        key: '2fa_backup_codes_$userId',
        value: jsonEncode(backupCodes),
      );

      return true;
    } catch (e) {
      throw Exception('Failed to enable 2FA: $e');
    }
  }

  // Disable 2FA for user
  Future<bool> disableTwoFactor({
    required String userId,
    required String verificationCode,
  }) async {
    try {
      final secret = await _storage.read(key: '2fa_secret_$userId');
      if (secret == null) {
        throw Exception('2FA not enabled');
      }

      // Verify the code before disabling 2FA
      if (!verifyTOTP(secret, verificationCode)) {
        // Try backup codes
        final backupCodesJson = await _storage.read(key: '2fa_backup_codes_$userId');
        if (backupCodesJson != null) {
          final backupCodes = List<String>.from(jsonDecode(backupCodesJson));
          if (backupCodes.contains(verificationCode)) {
            backupCodes.remove(verificationCode);
            await _storage.write(
              key: '2fa_backup_codes_$userId',
              value: jsonEncode(backupCodes),
            );
          } else {
            throw Exception('Invalid verification code');
          }
        } else {
          throw Exception('Invalid verification code');
        }
      }

      // Remove 2FA settings
      await _storage.delete(key: '2fa_secret_$userId');
      await _storage.delete(key: '2fa_enabled_$userId');
      await _storage.delete(key: '2fa_backup_codes_$userId');

      return true;
    } catch (e) {
      throw Exception('Failed to disable 2FA: $e');
    }
  }

  // Check if 2FA is enabled for user
  Future<bool> isTwoFactorEnabled(String userId) async {
    final enabled = await _storage.read(key: '2fa_enabled_$userId');
    return enabled == 'true';
  }

  // Verify 2FA code during login
  Future<bool> verifyTwoFactor({
    required String userId,
    required String code,
  }) async {
    try {
      final secret = await _storage.read(key: '2fa_secret_$userId');
      if (secret == null) {
        return false;
      }

      // Try TOTP first
      if (verifyTOTP(secret, code)) {
        return true;
      }

      // Try backup codes
      final backupCodesJson = await _storage.read(key: '2fa_backup_codes_$userId');
      if (backupCodesJson != null) {
        final backupCodes = List<String>.from(jsonDecode(backupCodesJson));
        if (backupCodes.contains(code)) {
          // Remove used backup code
          backupCodes.remove(code);
          await _storage.write(
            key: '2fa_backup_codes_$userId',
            value: jsonEncode(backupCodes),
          );
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Get backup codes for user
  Future<List<String>?> getBackupCodes(String userId) async {
    try {
      final backupCodesJson = await _storage.read(key: '2fa_backup_codes_$userId');
      if (backupCodesJson != null) {
        return List<String>.from(jsonDecode(backupCodesJson));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Generate new backup codes
  Future<List<String>> regenerateBackupCodes(String userId) async {
    try {
      final backupCodes = generateBackupCodes();
      await _storage.write(
        key: '2fa_backup_codes_$userId',
        value: jsonEncode(backupCodes),
      );
      return backupCodes;
    } catch (e) {
      throw Exception('Failed to regenerate backup codes: $e');
    }
  }

  // Send 2FA code via email (mock implementation)
  Future<bool> sendTwoFactorEmail({
    required String email,
    required String code,
  }) async {
    try {
      // Mock email sending
      // In production, integrate with email service like SendGrid
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      throw Exception('Failed to send 2FA email: $e');
    }
  }

  // Send 2FA code via SMS (mock implementation)
  Future<bool> sendTwoFactorSMS({
    required String phoneNumber,
    required String code,
  }) async {
    try {
      // Mock SMS sending
      // In production, integrate with SMS service like Twilio
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      throw Exception('Failed to send 2FA SMS: $e');
    }
  }

  // Helper method to convert int to bytes
  List<int> _intToBytes(int value) {
    final bytes = List<int>.filled(8, 0);
    for (int i = 0; i < 8; i++) {
      bytes[7 - i] = (value >> (i * 8)) & 0xFF;
    }
    return bytes;
  }

  // Generate recovery key
  String generateRecoveryKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  // Store recovery key
  Future<void> storeRecoveryKey(String userId, String recoveryKey) async {
    await _storage.write(key: '2fa_recovery_key_$userId', value: recoveryKey);
  }

  // Verify recovery key
  Future<bool> verifyRecoveryKey(String userId, String recoveryKey) async {
    try {
      final storedKey = await _storage.read(key: '2fa_recovery_key_$userId');
      return storedKey == recoveryKey;
    } catch (e) {
      return false;
    }
  }

  // Disable 2FA using recovery key
  Future<bool> disableTwoFactorWithRecoveryKey({
    required String userId,
    required String recoveryKey,
  }) async {
    try {
      if (!await verifyRecoveryKey(userId, recoveryKey)) {
        throw Exception('Invalid recovery key');
      }

      // Remove all 2FA settings
      await _storage.delete(key: '2fa_secret_$userId');
      await _storage.delete(key: '2fa_enabled_$userId');
      await _storage.delete(key: '2fa_backup_codes_$userId');
      await _storage.delete(key: '2fa_recovery_key_$userId');

      return true;
    } catch (e) {
      throw Exception('Failed to disable 2FA with recovery key: $e');
    }
  }
}
