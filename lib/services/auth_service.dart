import 'package:code_bolanon/services/api_service.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiService.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'] ?? response.data['access_token'];
        if (token != null) {
          await _apiService.setAuthToken(token);
          return true;
        }
      }

      print('Login failed with status: ${response.statusCode}');
      print('Response data: ${response.data}');
      return false;
    } catch (e) {
      print('Login error: $e');
      rethrow; // Rethrow to handle in UI
    }
  }

  Future<bool> register(String firstName, String lastName, String email,
      String password, String role) async {
    try {
      final response = await _apiService.post('/register', data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'role': role,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'] ?? response.data['access_token'];
        if (token != null) {
          await _apiService.setAuthToken(token);
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
    return token != null;
  }
}
