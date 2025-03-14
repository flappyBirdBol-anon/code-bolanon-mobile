import 'dart:convert';

import 'package:code_bolanon/models/user_model.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

class UserService with ListenableServiceMixin {
  final ReactiveValue<UserModel?> _currentUser =
      ReactiveValue<UserModel?>(null);
  UserModel? get currentUser => _currentUser.value;

  final ReactiveValue<UserModel?> _loggedInUser =
      ReactiveValue<UserModel?>(null);
  UserModel? get loggedInUser => _loggedInUser.value;

  UserService() {
    listenToReactiveValues([_currentUser]);
  }

  Future<void> fetchUserProfile() async {
    try {
      final profileData = await getProfile();
      if (profileData != null) {
        _currentUser.value = UserModel.fromJson(profileData);

        // Save to SharedPreferences

        final prefs = await SharedPreferences.getInstance();
        final userJson = json.encode(_currentUser.value?.toJson());
        await prefs.setString('current_user', userJson);
        _loggedInUser.value = await getUserFromPrefs();
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  Future<UserModel?> getUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');

      if (userJson != null) {
        final userData = json.decode(userJson);

        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('Error retrieving user from SharedPreferences: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await ApiService().get('/profile');

      if (response.statusCode == 200) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> updatePassword(String oldPassword,
      String newPassword, String newPasswordConfirmation) async {
    try {
      final userId = _currentUser.value?.id;
      if (userId == null) {
        return {'success': false, 'message': 'User ID is null'};
      }
      final response = await ApiService().post('/change-password', data: {
        'current_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation
      });
      if (response.statusCode == 200) {
        return {'success': true, 'message': response.data['message']};
      }
      return {'success': false, 'message': response.data['message']};
    } catch (e) {
      print('Update error: $e');
      return {'success': false, 'message': 'Failed to update password'};
    }
  }

  Future<bool> updateProfile(
    String firstName,
    String lastName,
    String profilePicture,
    String specialization,
    String organization,
    int userId, // Add userId parameter
  ) async {
    try {
      final response = await ApiService().put(
        '/profile/', // Use the correct user ID in the URL
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'profile_image': profilePicture,
          'specialization': specialization,
          'organization': organization,
        },
      );

      if (response.statusCode == 200) {
        // Update current user data
        _currentUser.value = _currentUser.value?.copyWith(
          firstName: firstName,
          lastName: lastName,
          profileImage: profilePicture,
          specialization: specialization,
          organization: organization,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Update error: $e');
      return false;
    }
  }

  void setUser(UserModel? user) {
    _currentUser.value = user;
  }
}
