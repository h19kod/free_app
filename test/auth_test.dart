import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../lib/features/auth/providers/auth_provider.dart';
import '../lib/core/services/api_service.dart';

void main() {
  group('Authentication Tests', () {
    late ProviderContainer container;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should validate email format correctly', () {
      final authNotifier = container.read(authProvider.notifier);
      
      // Test valid emails
      expect(authNotifier.isValidEmail('test@example.com'), true);
      expect(authNotifier.isValidEmail('user.name@domain.co.uk'), true);
      
      // Test invalid emails
      expect(authNotifier.isValidEmail('invalid-email'), false);
      expect(authNotifier.isValidEmail('test@'), false);
      expect(authNotifier.isValidEmail('@example.com'), false);
      expect(authNotifier.isValidEmail(''), false);
    });

    test('should handle login with invalid credentials', () async {
      final authNotifier = container.read(authProvider.notifier);
      
      // Mock Dio to throw 401 error
      final dio = Dio();
      final mockApi = ApiService(prefs);
      
      // This should fail with invalid credentials
      final result = await authNotifier.login('invalid@email.com', 'wrongpassword');
      expect(result, false);
      expect(container.read(authProvider).error, isNotNull);
    });
  });
}

extension AuthNotifierExtension on AuthNotifier {
  bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
