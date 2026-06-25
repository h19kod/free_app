import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum BiometricType {
  fingerprint,
  face,
  iris,
  none,
}

class BiometricResult {
  final bool success;
  final String? error;
  final BiometricType type;

  BiometricResult({
    required this.success,
    this.error,
    required this.type,
  });
}

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Check if device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      return isSupported;
    } catch (e) {
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final availableBiometrics = await _auth.getAvailableBiometrics();
      final types = <BiometricType>[];
      
      for (final biometric in availableBiometrics) {
        switch (biometric) {
          case BiometricType.fingerprint:
            types.add(BiometricType.fingerprint);
            break;
          case BiometricType.face:
            types.add(BiometricType.face);
            break;
          case BiometricType.iris:
            types.add(BiometricType.iris);
            break;
          default:
            break;
        }
      }
      
      return types;
    } catch (e) {
      return [];
    }
  }

  // Check if biometric authentication is enabled for user
  Future<bool> isBiometricEnabled(String userId) async {
    try {
      final enabled = await _storage.read(key: 'biometric_enabled_$userId');
      return enabled == 'true';
    } catch (e) {
      return false;
    }
  }

  // Enable biometric authentication
  Future<BiometricResult> enableBiometric({
    required String userId,
    required String reason,
  }) async {
    try {
      // Check device support
      final isSupported = await isDeviceSupported();
      if (!isSupported) {
        return BiometricResult(
          success: false,
          error: 'Device does not support biometric authentication',
          type: BiometricType.none,
        );
      }

      // Get available biometrics
      final availableBiometrics = await getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        return BiometricResult(
          success: false,
          error: 'No biometric sensors available',
          type: BiometricType.none,
        );
      }

      // Authenticate with biometrics
      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        // Store biometric preference
        await _storage.write(key: 'biometric_enabled_$userId', value: 'true');
        await _storage.write(
          key: 'biometric_type_$userId',
          value: availableBiometrics.first.name,
        );

        return BiometricResult(
          success: true,
          type: availableBiometrics.first,
        );
      } else {
        return BiometricResult(
          success: false,
          error: 'Biometric authentication failed',
          type: BiometricType.none,
        );
      }
    } on PlatformException catch (e) {
      String errorMessage = 'Biometric authentication failed';
      
      switch (e.code) {
        case 'NotAvailable':
          errorMessage = 'Biometric authentication is not available';
          break;
        case 'NotEnrolled':
          errorMessage = 'No biometrics enrolled on this device';
          break;
        case 'LockedOut':
          errorMessage = 'Biometric authentication is locked out';
          break;
        case 'PermanentlyLockedOut':
          errorMessage = 'Biometric authentication is permanently locked out';
          break;
        case 'OtherOperatingSystem':
          errorMessage = 'Biometric authentication is not supported on this OS';
          break;
        default:
          errorMessage = 'Biometric authentication error: ${e.message}';
          break;
      }

      return BiometricResult(
        success: false,
        error: errorMessage,
        type: BiometricType.none,
      );
    } catch (e) {
      return BiometricResult(
        success: false,
        error: 'Unexpected error: $e',
        type: BiometricType.none,
      );
    }
  }

  // Disable biometric authentication
  Future<bool> disableBiometric(String userId) async {
    try {
      await _storage.delete(key: 'biometric_enabled_$userId');
      await _storage.delete(key: 'biometric_type_$userId');
      return true;
    } catch (e) {
      return false;
    }
  }

  // Authenticate with biometrics
  Future<BiometricResult> authenticate({
    required String userId,
    required String reason,
  }) async {
    try {
      // Check if biometric is enabled
      final isEnabled = await isBiometricEnabled(userId);
      if (!isEnabled) {
        return BiometricResult(
          success: false,
          error: 'Biometric authentication is not enabled',
          type: BiometricType.none,
        );
      }

      // Get stored biometric type
      final storedType = await _storage.read(key: 'biometric_type_$userId');
      final biometricType = storedType != null
          ? BiometricType.values.firstWhere((type) => type.name == storedType)
          : BiometricType.none;

      // Authenticate
      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        return BiometricResult(
          success: true,
          type: biometricType,
        );
      } else {
        return BiometricResult(
          success: false,
          error: 'Biometric authentication failed',
          type: biometricType,
        );
      }
    } on PlatformException catch (e) {
      String errorMessage = 'Biometric authentication failed';
      
      switch (e.code) {
        case 'NotAvailable':
          errorMessage = 'Biometric authentication is not available';
          break;
        case 'NotEnrolled':
          errorMessage = 'No biometrics enrolled on this device';
          break;
        case 'LockedOut':
          errorMessage = 'Biometric authentication is locked out';
          break;
        case 'PermanentlyLockedOut':
          errorMessage = 'Biometric authentication is permanently locked out';
          break;
        default:
          errorMessage = 'Biometric authentication error: ${e.message}';
          break;
      }

      return BiometricResult(
        success: false,
        error: errorMessage,
        type: BiometricType.none,
      );
    } catch (e) {
      return BiometricResult(
        success: false,
        error: 'Unexpected error: $e',
        type: BiometricType.none,
      );
    }
  }

  // Get biometric type for user
  Future<BiometricType> getBiometricType(String userId) async {
    try {
      final storedType = await _storage.read(key: 'biometric_type_$userId');
      if (storedType != null) {
        return BiometricType.values.firstWhere((type) => type.name == storedType);
      }
      return BiometricType.none;
    } catch (e) {
      return BiometricType.none;
    }
  }

  // Check if biometrics are enrolled on device
  Future<bool> areBiometricsEnrolled() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get biometric authentication status
  Future<Map<String, dynamic>> getBiometricStatus(String userId) async {
    try {
      final isSupported = await isDeviceSupported();
      final availableBiometrics = await getAvailableBiometrics();
      final isEnabled = await isBiometricEnabled(userId);
      final enrolled = await areBiometricsEnrolled();
      final userBiometricType = await getBiometricType(userId);

      return {
        'isSupported': isSupported,
        'availableBiometrics': availableBiometrics.map((e) => e.name).toList(),
        'isEnabled': isEnabled,
        'isEnrolled': enrolled,
        'userBiometricType': userBiometricType.name,
      };
    } catch (e) {
      return {
        'isSupported': false,
        'availableBiometrics': [],
        'isEnabled': false,
        'isEnrolled': false,
        'userBiometricType': BiometricType.none.name,
        'error': e.toString(),
      };
    }
  }

  // Prompt user to enable biometrics
  Future<BiometricResult> promptEnableBiometrics({
    required String userId,
    required String title,
    required String description,
  }) async {
    try {
      // Check if already enabled
      final isEnabled = await isBiometricEnabled(userId);
      if (isEnabled) {
        final type = await getBiometricType(userId);
        return BiometricResult(
          success: true,
          error: 'Biometric authentication is already enabled',
          type: type,
        );
      }

      // Check device support
      final isSupported = await isDeviceSupported();
      if (!isSupported) {
        return BiometricResult(
          success: false,
          error: 'Device does not support biometric authentication',
          type: BiometricType.none,
        );
      }

      // Check if biometrics are enrolled
      final enrolled = await areBiometricsEnrolled();
      if (!enrolled) {
        return BiometricResult(
          success: false,
          error: 'No biometrics are enrolled on this device. Please set up fingerprint or face recognition in your device settings.',
          type: BiometricType.none,
        );
      }

      // Authenticate to enable
      return await enableBiometric(
        userId: userId,
        reason: '$title: $description',
      );
    } catch (e) {
      return BiometricResult(
        success: false,
        error: 'Failed to enable biometric authentication: $e',
        type: BiometricType.none,
      );
    }
  }

  // Reset biometric authentication (for troubleshooting)
  Future<bool> resetBiometricAuthentication(String userId) async {
    try {
      await _storage.delete(key: 'biometric_enabled_$userId');
      await _storage.delete(key: 'biometric_type_$userId');
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get human-readable biometric type name
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.face:
        return 'Face Recognition';
      case BiometricType.iris:
        return 'Iris Scanner';
      case BiometricType.none:
        return 'None';
    }
  }

  // Get biometric icon
  String getBiometricIcon(BiometricType type) {
    switch (type) {
      case BiometricType.fingerprint:
        return '👆';
      case BiometricType.face:
        return '👤';
      case BiometricType.iris:
        return '👁️';
      case BiometricType.none:
        return '🔒';
    }
  }
}
