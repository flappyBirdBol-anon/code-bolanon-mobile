import 'package:code_bolanon/models/user_model.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:stacked/stacked.dart';

class AuthService with ListenableServiceMixin {
  final ApiService _apiService;

  final ReactiveValue<UserModel?> _currentUser =
      ReactiveValue<UserModel?>(null);
  UserModel? get currentUser => _currentUser.value;

  AuthService(this._apiService) {
    listenToReactiveValues([_currentUser]);
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiService.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'] ?? response.data['access_token'];
        if (token != null) {
          await _apiService.setAuthToken(token);
          await _fetchUserProfile();
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
        'organization': organization
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'] ?? response.data['access_token'];
        if (token != null) {
          await _apiService.setAuthToken(token);
          // Fetch user profile after successful registration
          await _fetchUserProfile();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      final profileData = await getProfile();
      if (profileData != null) {
        _currentUser.value = UserModel.fromJson(profileData);
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  Future<bool> logout() async {
    try {
      final response = await _apiService.post('/logout');

      if (response.statusCode == 200) {
        await _apiService.clearAuthToken();
        _currentUser.value = null;
        return true;
      }
      return false;
    } catch (e) {
      print('Logout error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await _apiService.get('/profile');

      if (response.statusCode == 200) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _apiService.getAuthToken();
    if (token != null && _currentUser.value == null) {
      await _fetchUserProfile();
    }
    return token != null;
  }
}
