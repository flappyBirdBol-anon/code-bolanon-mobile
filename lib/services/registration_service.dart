import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/models/registration_model.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:stacked/stacked.dart';

class RegistrationService with ReactiveServiceMixin {
  final ApiService _apiService;

  RegistrationService({ApiService? apiService})
      : _apiService = apiService ?? locator<ApiService>();

  List<RegistrationModel> _registrations =
      []; // Initialize empty list instead of using late
  List<RegistrationModel> get registrations => _registrations;

  final Set<String> _registeredCourses = {};
  Set<String> get registeredCourses => _registeredCourses;

  // Check if a course is registered
  bool isRegistered(String courseId) {
    return _registeredCourses.contains(courseId.toString());
  }

  // Create a new registration
  Future<bool> createRegistration(String courseId) async {
    try {
      final response = await _apiService.post('/registrations', data: {
        'course_id': courseId.toString(),
      });

      if (response.statusCode == 201) {
        final registrationJson = response.data['data'];
        final newRegistration = RegistrationModel.fromJson(registrationJson);
        _registrations.add(newRegistration);
        _registeredCourses.add(courseId.toString());
        notifyListeners();
        return true;
      } else {
        throw Exception(
            'Failed to create registration: ${response.data['message']}');
      }
    } catch (e) {
      return false;
    }
  }

  // Load user's registered courses
  Future<void> loadRegisteredCourses() async {
    try {
      final response = await _apiService.get('/registrations');
      if (response.statusCode == 200) {
        final List<dynamic> registrationsJson = response.data['data'] ?? [];
        _registrations = registrationsJson
            .map((json) {
              try {
                return RegistrationModel.fromJson(json);
              } catch (e, stackTrace) {
                print('Error parsing registration JSON: $json');
                print('Parse error: $e');
                print('StackTrace: $stackTrace');
                return null;
              }
            })
            .whereType<RegistrationModel>()
            .toList();

        _registeredCourses.clear();
        _registeredCourses
            .addAll(_registrations.map((r) => r.courseId.toString()));
        notifyListeners();
      } else {
        throw Exception('Failed to load registrations: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error in loadRegisteredCourses: $e');
      print('StackTrace: $stackTrace');
    }
  }

  Future<List<RegistrationModel>> getUserRegistrations() async {
    try {
      print('Fetching user registrations...');
      final response = await _apiService.get('/registrations');
      print('Registration Response Status: ${response.statusCode}');
      print('Registration Raw Data: ${response.data}');
      print('Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        if (response.data == null) {
          print('Response data is null');
          return [];
        }

        if (!response.data.containsKey('data')) {
          print('Response missing data key: ${response.data}');
          return [];
        }

        final List<dynamic> registrationsJson = response.data['data'] ?? [];
        print('Processing registration JSON data: $registrationsJson');

        _registrations = registrationsJson
            .map((json) {
              try {
                return RegistrationModel.fromJson(json);
              } catch (e, stackTrace) {
                print('Error parsing registration JSON: $json');
                print('Parse error: $e');
                print('StackTrace: $stackTrace');
                return null;
              }
            })
            .whereType<RegistrationModel>()
            .toList();

        print('Successfully parsed registrations: $_registrations');
        return _registrations;
      } else {
        print('Failed response: ${response.data}');
        throw Exception('Failed to load registrations: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error in getUserRegistrations: $e');
      print('StackTrace: $stackTrace');
      return [];
    }
  }

  Future<List<CourseModel>> getRegisteredCourses(
      List<RegistrationModel> registrations) async {
    try {
      List<CourseModel> courses = [];
      List<Future<CourseModel>> futures = [];

      // Create futures for parallel execution
      for (var registration in registrations) {
        futures.add(_fetchRegisteredCourse(registration));
      }

      // Wait for all futures to complete
      final results = await Future.wait(futures);
      courses.addAll(results);

      return courses;
    } catch (e) {
      throw Exception('Failed to get registered courses: ${e.toString()}');
    }
  }

  Future<CourseModel> _fetchRegisteredCourse(
      RegistrationModel registration) async {
    try {
      print('Fetching course for registration: ${registration.id}');
      final response =
          await _apiService.get('/courses/${registration.courseId}');
      print('Course API Response: ${response.data}');

      if (response.statusCode == 200) {
        final courseJson = response.data['data'];
        print('Course JSON before registration: $courseJson');
        courseJson['registration'] = registration.toJson();
        print('Course JSON after registration: $courseJson');
        return CourseModel.fromJson(courseJson);
      }
      throw Exception('Failed to fetch course: ${response.statusCode}');
    } catch (e, stackTrace) {
      print('Error fetching course ${registration.courseId}: $e');
      print('StackTrace: $stackTrace');
      rethrow;
    }
  }
}
