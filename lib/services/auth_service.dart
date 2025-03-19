import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/user_model.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:code_bolanon/services/user_service.dart';
import 'package:code_bolanon/utils/performance_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Data class for login credentials (isolate-friendly)
class _LoginData {
  final String email;
  final String password;

  _LoginData({required this.email, required this.password});
}

// Isolate function for login processing
Future<Map<String, dynamic>> _processLoginInIsolate(_LoginData data) async {
  // This is a placeholder for the actual implementation
  // In a real implementation, you'd need to reimplement the network call here
  // since you can't pass ApiService through isolates
  return {
    'success': true,
    'email': data.email,
    // Other data you'd expect from login
  };
}

class AuthService with ListenableServiceMixin {
  final ApiService _apiService = ApiService();
  final _userService = locator<UserService>();
  final _storage = const FlutterSecureStorage();

  final ReactiveValue<UserModel?> _currentUser =
      ReactiveValue<UserModel?>(null);
  UserModel? get currentUser => _currentUser.value;

  // Lazy loading for shared preferences
  final LazyResource<SharedPreferences> _prefs =
      LazyResource<SharedPreferences>(() => SharedPreferences.getInstance());

  bool _isInitialized = false;

  AuthService() {
    listenToReactiveValues([_currentUser]);
  }

  // Initialize only what's needed at startup
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize in background to avoid blocking UI
    PerformanceUtils.runInBackground([
      () async {
        // Pre-fetch token to speed up isLoggedIn calls
        await _apiService.getAuthToken();

        // Pre-load onboarding status
        await getOnboardingStatus();
      },
    ]);

    _isInitialized = true;
  }

  Future<bool> login(String email, String password) async {
    try {
      // For very lightweight logins, you could use the isolate approach
      // For actual implementation, we need to use the API service directly
      // because we can't pass it to an isolate

      final response = await _apiService.post('/login', data: {
        'email': email,
        'password': password,
        'platform': 'mobile',
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        if (token != null) {
          // Store token - run in background
          Future.microtask(() async {
            await _apiService.setAuthToken(token);
          });

          // Fetch user profile in parallel with completing login
          _userService.fetchUserProfile().fireAndForget();

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
      // Registration is typically not a performance-critical operation
      // as it happens infrequently, but we can still optimize
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

      // Process response in background using compute for heavy responses
      if (response.data != null &&
          response.data is Map &&
          (response.data as Map).length > 100) {
        // Only use compute for large response payloads
        return await compute(_processRegistrationResponse, response.data);
      }

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

  // Function that can be called in an isolate
  static Map<String, dynamic> _processRegistrationResponse(dynamic data) {
    // Implement the response processing logic here
    // This is just a simplified example
    if (data is Map && data.containsKey('message')) {
      return {
        'success': true,
        'message': data['message'] ?? 'Registration successful'
      };
    }
    return {'success': false, 'message': 'Unknown response format'};
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
        // Clear token and user data in parallel
        await Future.wait([
          _apiService.clearAuthToken(),
          Future(() => _userService.setUser(null)),
          clearUserData(),
        ]);
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
      // Use lazy-loaded shared preferences
      final prefs = await _prefs.resource;
      await prefs.remove('current_user');
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }

  // Optimized isLoggedIn check with caching
  bool? _cachedLoginStatus;
  DateTime? _loginStatusCacheTime;
  final Duration _loginStatusCacheDuration = const Duration(minutes: 5);

  Future<bool> isLoggedIn() async {
    // Check cache first for very fast response
    final now = DateTime.now();
    if (_cachedLoginStatus != null && _loginStatusCacheTime != null) {
      if (now.difference(_loginStatusCacheTime!) < _loginStatusCacheDuration) {
        return _cachedLoginStatus!;
      }
    }

    // Cache miss, check token
    final token = await _apiService.getAuthToken();
    final isLoggedIn = token != null;

    // Only fetch profile if logged in and not already loaded
    if (isLoggedIn && _currentUser.value == null) {
      // Fetch in background to speed up startup
      _userService.fetchUserProfile().fireAndForget();
    }

    // Update cache
    _cachedLoginStatus = isLoggedIn;
    _loginStatusCacheTime = now;

    return isLoggedIn;
  }

  /// Checks if onboarding has been completed
  /// Returns true if onboarding has been viewed
  Future<bool> getOnboardingStatus() async {
    try {
      // First check secure storage for more permanent storage
      final token = await _apiService.getAuthToken();
      if (token != null) {
        // If user is logged in, they've definitely completed onboarding
        return true;
      }

      // Also check secure storage directly
      final onboardingValue = await _storage.read(key: 'onboarding_completed');
      if (onboardingValue == 'true') {
        return true;
      }

      // Check if onboarding has at least started
      final onboardingStarted = await _storage.read(key: 'onboarding_started');
      if (onboardingStarted == 'true') {
        return true;
      }

      // Otherwise check shared preferences
      final prefs = await _prefs.resource;
      return prefs.getBool('has_seen_onboarding') ?? false;
    } catch (e) {
      print('Error getting onboarding status: $e');
      return false;
    }
  }

  /// Sets the onboarding completed status
  /// This is a backup method in case SharedPreferences fails
  Future<void> setOnboardingCompleted(bool completed) async {
    try {
      // First try shared preferences
      final prefs = await _prefs.resource;
      await prefs.setBool('has_seen_onboarding', completed);

      // Also store in secure storage for redundancy
      // This only stores the fact that onboarding was completed, not any user data
      if (completed) {
        await _storage.write(key: 'onboarding_completed', value: 'true');
      }
    } catch (e) {
      print('Error setting onboarding status: $e');
    }
  }

  /// Marks that onboarding has started even if not completed
  /// This ensures users who exit during onboarding won't see it again
  Future<void> setOnboardingStarted() async {
    try {
      // Use both storage methods for redundancy
      final prefs = await _prefs.resource;
      await prefs.setBool('onboarding_started', true);

      // More permanent storage with secure storage
      await _storage.write(key: 'onboarding_started', value: 'true');
    } catch (e) {
      print('Error marking onboarding as started: $e');

      // Try alternative storage if first attempt failed
      try {
        await _storage.write(key: 'onboarding_started', value: 'true');
      } catch (_) {
        // If both methods fail, just log and continue
        print('Failed to mark onboarding as started in any storage');
      }
    }
  }
}
