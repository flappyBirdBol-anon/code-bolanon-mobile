import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/user_model.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:code_bolanon/services/user_service.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

class AuthService with ListenableServiceMixin {
  final ApiService _apiService = ApiService();
  final _userService = locator<UserService>();

  final ReactiveValue<UserModel?> _currentUser =
      ReactiveValue<UserModel?>(null);
  UserModel? get currentUser => _currentUser.value;

  AuthService() {
    listenToReactiveValues([_currentUser]);
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiService.post('/login', data: {
        'email': email,
        'password': password,
        'platform': 'mobile',
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        if (token != null) {
          await _apiService.setAuthToken(token);
          await _userService.fetchUserProfile();
          return true;
        } else {
          // Token is unexpectedly null, handle this case
          print('Login successful but token is null');
          return false;
        }
      } else if (response.statusCode == 401) {
        // Incorrect credentials
        print('Login failed: Incorrect credentials');
        print('Response data: ${response.data}');
        throw Exception(response.data['message'] ??
            'Incorrect credentials'); // Or a custom exception
      } else if (response.statusCode == 403) {
        // Unverified user
        print('Login failed: User unverified');
        print('Response data: ${response.data}');
        throw Exception(response.data['message'] ??
            'User unverified'); // Or a custom exception
      } else {
        // Other error codes
        print('Login failed with status: ${response.statusCode}');
        print('Response data: ${response.data}');
        throw Exception(
            'Login failed with status code: ${response.statusCode}'); // Generic exception
      }
    } on DioException catch (e) {
      // DioError handles network errors, timeouts, etc.
      print('DioError during login: $e');
      rethrow; // Re-throw to allow the calling code to handle the error
    } catch (e) {
      // Catch any other unexpected errors
      print('Login error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(
      String firstName,
      String lastName,
      String email,
      String password,
      String role,
      List<String> selectedTechStacks,
      String? specialization,
      String? organization) async {
    try {
      final response = await _apiService.post('/register', data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'role': role,
        'specialization': specialization,
        'organization': organization,
        'stack_ids':
            selectedTechStacks.map((stack) => int.parse(stack)).toList(),
      });

      return handleRegistrationResponse(response);
    } on DioException catch (e) {
      print('Registration DioError: $e');
      // Extract error message from response if available
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Registration failed',
          'errors': e.response?.data['errors']
        };
      }
      return {
        'success': false,
        'message': e.message ?? 'Network error during registration'
      };
    } catch (e) {
      print('Registration error: $e');
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  Map<String, dynamic> handleRegistrationResponse(dynamic response) {
    if (response.statusCode == 201) {
      // Registration successful, but user needs to verify email
      return {
        'success': true,
        'message': response.data['message'] ??
            'Registration successful, please verify your email'
      };
    }

    //not 201 response, validation error or endpoint error
    String errorMessage = 'An unexpected error occurred.';
    if (response.data is List && response.data.isNotEmpty) {
      //if it has message key
      final firstError = response.data.first;
      if (firstError is Map) {
        //get first err
        final firstKey = firstError.keys.first;
        if (firstError[firstKey] is List &&
            (firstError[firstKey] as List).isNotEmpty) {
          errorMessage = (firstError[firstKey] as List).first;
        } else if (firstError[firstKey] is String) {
          errorMessage = firstError[firstKey];
        } else {
          errorMessage = firstError.toString();
        }
      } else {
        errorMessage = firstError.toString();
      }
    } else if (response.data is String) {
      errorMessage = response.data;
    } else {
      errorMessage = response.data.toString();
    }
//return data, safe since it has default value
    return {
      'success': false,
      'message': errorMessage,
    };
  }

  Future<bool> logout() async {
    try {
      final response = await _apiService.post('/logout');

      if (response.statusCode == 200) {
        await _apiService.clearAuthToken();
        _userService.setUser(null);
        clearUserData();
        return true;
      }
      return false;
    } catch (e) {
      print('Logout error: $e');
      return false;
    }
  }

  Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _apiService.getAuthToken();
    if (token != null && _currentUser.value == null) {
      await _userService.fetchUserProfile();
    }
    return token != null;
  }
}
