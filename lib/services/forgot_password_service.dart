import 'package:stacked/stacked.dart';

import '../app/app.locator.dart';
import 'api_service.dart';

class ForgotPasswordService with ListenableServiceMixin {
  final _apiService = locator<ApiService>();

  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await _apiService.post(
        '/forgot-password',
        data: {'email': email},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      throw Exception(
          response.data['message'] ?? 'Failed to request password reset');
    } catch (e) {
      throw Exception('Password reset request failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> verifyResetCode(
      String email, String code) async {
    try {
      final response = await _apiService.post(
        '/verify-otp',
        data: {
          'email': email,
          'otp': code,
        },
      );

      if (response.statusCode == 200) {
        // Return the full response data to get the token
        return response.data;
      }
      throw Exception(response.data['message'] ?? 'Invalid reset code');
    } catch (e) {
      throw Exception('Verification failed: ${e.toString()}');
    }
  }

  Future<bool> resetPassword(
    String email,
    String token,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      final response = await _apiService.post(
        '/reset-password',
        data: {
          'email': email,
          'token': token, // Token from verify-otp response
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }
}
