import 'package:code_bolanon/app/app.dialogs.dart';
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/models/payment_param.dart';
import 'package:code_bolanon/models/registration_model.dart';
import 'package:code_bolanon/models/transaction_model.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class RegistrationService with ReactiveServiceMixin {
  final ApiService _apiService;
  final NavigationService _navigationService = locator<NavigationService>();
  final DialogService _dialogService = locator<DialogService>();

  RegistrationService({ApiService? apiService})
      : _apiService = apiService ?? locator<ApiService>();

  List<RegistrationModel> _registrations = [];
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
      // First get the course details
      final courseResponse = await _apiService.get('/courses/$courseId');
      if (courseResponse.statusCode != 200) {
        throw Exception('Failed to fetch course: ${courseResponse.statusCode}');
      }

      final courseData = courseResponse.data['data'];
      final courseModel = CourseModel.fromJson(courseData);
      dynamic paymentResult;
      if (courseModel.price == 0) {
        //set
        paymentResult = {'success': true};
        print('Payment result for free course: $paymentResult');
      } else {
        // Navigate to payment view first with PaymentParam
        paymentResult = await _navigationService.navigateToPaymentView(
          payment: PaymentParam(
            id: courseModel.id,
            title: courseModel.title,
            description: courseModel.description,
            price: courseModel.price,
            taxRate: 0.00,
            discountPercentage: 0.00,
          ),
        );
      }
      print('Payment result: $paymentResult');
      // If payment was successful, create the registration
      if (paymentResult != null && paymentResult['success'] == true) {
        final response = await _apiService.post('/registrations', data: {
          'course_id': courseId.toString(),
        });

        if (response.statusCode == 201) {
          final registrationJson = response.data['data'];
          print('Registration JSON: $registrationJson');
          final newRegistration = RegistrationModel.fromJson(registrationJson);
          _registrations.add(newRegistration);
          _registeredCourses.add(courseId.toString());
          notifyListeners();

          // Ensure we have transaction data to show in receipt
          if (paymentResult.containsKey('transaction')) {
            print('Transaction data found, showing receipt dialog');
            final transactionData = paymentResult['transaction'];

            Transaction transaction;
            if (transactionData is Map<String, dynamic>) {
              print('Parsing transaction from map');
              transaction = Transaction.fromJson(transactionData);
            } else {
              print('Using transaction object directly');
              transaction = transactionData as Transaction;
            }
            // Use Future.delayed to ensure the dialog appears after navigation completes
            await Future.delayed(const Duration(milliseconds: 300));
            await _showReceiptDialog(courseModel, transaction);
          } else {
            print('No transaction data in payment result: $paymentResult');
          }

          return true;
        } else {
          throw Exception(
              'Failed to create registration: ${response.data['message']}');
        }
      } else {
        return false;
      }
    } catch (e) {
      print('Error in createRegistration: $e');
      return false;
    }
  }

  // Show receipt dialog
  Future<void> _showReceiptDialog(
      CourseModel course, Transaction transaction) async {
    final payment = PaymentParam(
      id: course.id.toString(),
      title: course.title,
      price: course.price,
      description: course.description,
    );
    await _dialogService.showCustomDialog(
      variant: DialogType.receipt,
      title: 'Payment Receipt',
      description: 'Your payment was successful!',
      mainButtonTitle: 'Close',
      data: {
        'payment': payment,
        'transaction': transaction,
      },
    );
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

      // More detailed logging of the structure
      print('Response has data key: ${response.data.containsKey('data')}');
      if (response.data.containsKey('data')) {
        final dataType = response.data['data'] != null
            ? response.data['data'].runtimeType.toString()
            : 'null';
        print('Data field type: $dataType');

        if (response.data['data'] is List) {
          print('Data is a List with ${response.data['data'].length} items');
          if (response.data['data'].isNotEmpty) {
            print('First item type: ${response.data['data'][0].runtimeType}');
            print(
                'First item sample keys: ${response.data['data'][0].keys.take(5).join(', ')}');
          }
        }
      }

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
        print('Number of registrations found: ${registrationsJson.length}');

        if (registrationsJson.isEmpty) {
          print('No registrations found in data');
          return [];
        }

        try {
          _registrations = [];
          for (var json in registrationsJson) {
            try {
              print('Processing registration entry: ${json['id']}');
              final registration = RegistrationModel.fromJson(json);
              print('Successfully parsed registration ${registration.id}');
              _registrations.add(registration);
            } catch (e, stackTrace) {
              print('Error parsing individual registration: $e');
              print('StackTrace: $stackTrace');
            }
          }

          print(
              'Successfully processed ${_registrations.length} registrations');

          // Check if registrations have course data
          int registrationsWithCourseData =
              _registrations.where((reg) => reg.course != null).length;
          print(
              'Registrations with course data: $registrationsWithCourseData/${_registrations.length}');

          notifyListeners();
          return _registrations;
        } catch (e, stackTrace) {
          print('Error processing registrations list: $e');
          print('StackTrace: $stackTrace');
          return [];
        }
      }
      print('Unexpected response status: ${response.statusCode}');
      return [];
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

      // First, check if registrations have nested course data
      for (var registration in registrations) {
        if (registration.course != null) {
          // Create a course model with the registration data included
          final courseWithRegistration = registration.course!.copyWith(
            registration: registration,
          );
          courses.add(courseWithRegistration);
        }
      }

      // If we already have all courses from nested data, return them
      if (courses.length == registrations.length) {
        return courses;
      }

      // Otherwise, fetch missing courses individually (fall back to old approach)
      List<Future<CourseModel>> futures = [];
      for (var registration in registrations) {
        if (registration.course == null) {
          futures.add(_fetchRegisteredCourse(registration));
        }
      }

      // Wait for all futures to complete
      if (futures.isNotEmpty) {
        final results = await Future.wait(futures);
        courses.addAll(results);
      }

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

  // Submit a review and/or report for a registration
  Future<bool> submitReviewOrReport({
    required String registrationId,
    double? rating,
    String? feedback,
    bool? isReported,
    String? reportedReason,
    String? type,
  }) async {
    try {
      print('Submitting review/report for registration: $registrationId');

      // Prepare request data with nullable fields
      final Map<String, dynamic> requestData = {};

      // Handle based on type for Laravel expectations
      if (type == 'review') {
        requestData['rating'] = rating;
        requestData['feedback'] = feedback;
        requestData['type'] = 'review';
      } else if (type == 'report') {
        requestData['report_reason'] = reportedReason;
        requestData['is_reported'] = true;
        requestData['type'] = 'report';
      } else {
        // Fallback to old approach for backward compatibility
        if (rating != null) requestData['rating'] = rating;
        if (feedback != null) requestData['feedback'] = feedback;
        if (isReported != null) requestData['is_reported'] = isReported;
        if (reportedReason != null)
          requestData['report_reason'] = reportedReason;
      }

      // Send PUT request to update registration
      final response = await _apiService.put(
        '/registrations/$registrationId', // Laravel RESTful convention
        data: requestData,
      );

      if (response.statusCode == 200) {
        // Update the local registration data
        final updatedRegistrationJson = response.data['data'];
        final index = _registrations.indexWhere((r) => r.id == registrationId);

        if (index != -1) {
          _registrations[index] =
              RegistrationModel.fromJson(updatedRegistrationJson);
          notifyListeners();
        }

        return true;
      } else {
        print('Failed to update registration: ${response.data}');
        return false;
      }
    } catch (e, stackTrace) {
      print('Error in submitReviewOrReport: $e');
      print('StackTrace: $stackTrace');
      return false;
    }
  }
}
