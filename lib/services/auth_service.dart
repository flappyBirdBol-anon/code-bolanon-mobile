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
        'platform': 'mobile',
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

  Future<bool> isLoggedIn() async {
    final token = await _apiService.getAuthToken();
    if (token != null && _currentUser.value == null) {
      await _fetchUserProfile();
    }
    return token != null;
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

  Future<bool> updatePassword(String oldPassword, String newPassword) async {
    try {
      final userId =
          _currentUser.value?.id; // Assuming UserModel has an 'id' field
      if (userId == null) {
        print('User ID is null');
        return false;
      }
      final response = await _apiService.patch('/users/$userId/password',
          data: {'oldPassword': oldPassword, 'newPassword': newPassword});
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Update error: $e');
      return false;
    }
  }

  Future<bool> updateProfile(
      String firstName,
      String lastName,
      String profilePicture,
      String? specialization,
      String? organization) async {
    try {
      final userId = _currentUser.value?.id;
      if (userId == null) {
        print('User ID is null');
        return false;
      }

      // Debug print before update
      print('Updating profile with:');
      print('First Name: $firstName');
      print('Last Name: $lastName');

      final response = await _apiService.put('/users/$userId', data: {
        'first_name': firstName,
        'last_name': lastName,
        'profile_image': profilePicture, // Changed from profile_picture
        'specialization': specialization,
        'organization': organization
      });

      if (response.statusCode == 200) {
        // Debug print response
        print('Server response: ${response.data}');

        if (_currentUser.value != null) {
          // Create updated user without immediately assigning
          final updatedUser = _currentUser.value!.copyWith(
            firstName: firstName,
            lastName: lastName,
            profileImage: profilePicture,
            specialization: specialization,
            organization: organization,
          );

          // Debug print the updated user
          print('Updated user:');
          print('First Name: ${updatedUser.firstName}');
          print('Last Name: ${updatedUser.lastName}');

          // Now assign the updated user
          _currentUser.value = updatedUser;
        }

        // Removed _fetchUserProfile() call temporarily for debugging
        return true;
      }
      return false;
    } catch (e) {
      print('Update error: $e');
      return false;
    }
  }
}
