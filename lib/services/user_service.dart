import 'dart:convert';

import 'package:code_bolanon/models/tech_stack_model.dart';
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

  final ReactiveValue<List<TechStackModel>> _userTechStacks =
      ReactiveValue<List<TechStackModel>>([]);
  List<TechStackModel> get userTechStacks => _userTechStacks.value;

  UserService() {
    listenToReactiveValues([_currentUser, _userTechStacks]);
  }

  Future<void> fetchUserProfile() async {
    try {
      final profileResponse = await getProfile();
      if (profileResponse != null) {
        // Handle user profile data
        if (profileResponse['userData'] != null) {
          _currentUser.value = UserModel.fromJson(profileResponse['userData']);

          // Save to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          final userJson = json.encode(_currentUser.value?.toJson());
          await prefs.setString('current_user', userJson);
          _loggedInUser.value = await getUserFromPrefs();
        }

        // Handle tech stacks data
        if (profileResponse['stacks'] != null) {
          _userTechStacks.value = (profileResponse['stacks'] as List)
              .map((stack) => TechStackModel.fromJson(stack))
              .toList();

          // Save tech stacks to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          final stacksJson = json.encode(
              _userTechStacks.value.map((stack) => stack.toJson()).toList());
          await prefs.setString('user_tech_stacks', stacksJson);
        }
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

  Future<TechStackModel?> getUserTechStackFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_tech_stacks');

      if (userJson != null) {
        final userData = json.decode(userJson);

        return TechStackModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('Error retrieving user tech stack from SharedPreferences: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await ApiService().get('/profile/me');

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = {};

        // Extract user data
        if (response.data['data'] != null) {
          result['userData'] = response.data['data'];
        }

        // Extract tech stacks (if available)
        if (response.data['stacks'] != null) {
          result['stacks'] = response.data['stacks'];
        }

        return result;
      }
      return null;
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }

  // Get tech stacks from shared preferences
  Future<List<TechStackModel>> getTechStacksFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stacksJson = prefs.getString('user_tech_stacks');

      if (stacksJson != null) {
        final List<dynamic> stacksData = json.decode(stacksJson);
        return stacksData
            .map((stack) => TechStackModel.fromJson(stack))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error retrieving tech stacks from SharedPreferences: $e');
      return [];
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
