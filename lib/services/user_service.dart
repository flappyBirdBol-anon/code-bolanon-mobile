import 'package:code_bolanon/models/user_model.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:stacked/stacked.dart';

class UserService with ListenableServiceMixin {
  final ReactiveValue<UserModel?> _currentUser =
      ReactiveValue<UserModel?>(null);
  UserModel? get currentUser => _currentUser.value;

  UserService() {
    listenToReactiveValues([_currentUser]);
  }

  Future<void> fetchUserProfile() async {
    try {
      final profileData = await getProfile();
      if (profileData != null) {
        _currentUser.value = UserModel.fromJson(profileData);
      }
    } catch (e) {
      print('Error fetching user profile: $e');
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

  Future<bool> updatePassword(String oldPassword, String newPassword) async {
    try {
      final userId =
          _currentUser.value?.id; // Assuming UserModel has an 'id' field
      if (userId == null) {
        print('User ID is null');
        return false;
      }
      final response = await ApiService().patch('/users/$userId/password',
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
