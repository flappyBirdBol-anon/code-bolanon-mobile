import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/user_model.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:code_bolanon/services/user_service.dart';
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
        final token = response.data['token'] ?? response.data['access_token'];
        if (token != null) {
          await _apiService.setAuthToken(token);
          await _userService.fetchUserProfile();
          return true;
        }
      }
      print('Login failed with status: ${response.statusCode}');
      print('Response data: ${response.data}');
      return false;
    } catch (e) {
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
        'tech_stacks': selectedTechStacks,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'] ?? response.data['access_token'];
        if (token != null) {
          await _apiService.setAuthToken(token);
          // Fetch user profile after successful registration
          await _userService.fetchUserProfile();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Registration error: $e');
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
