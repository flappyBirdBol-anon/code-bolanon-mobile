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

  Future<bool> register(
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

      if (response.statusCode == 201) {
        // Registration successful, but user needs to verify email
        // Don't set auth token or fetch profile yet
        return true;
      }
      return false;
    } catch (e) {
      print('Registration error: $e');
      if (e is Exception && e.toString().contains('422')) {
        // Handle validation errors
        rethrow;
      }
      rethrow;
    }
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
