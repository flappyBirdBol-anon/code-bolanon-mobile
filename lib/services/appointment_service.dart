import 'package:code_bolanon/app/app.dialogs.dart';
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/models/appointment_model.dart';
import 'package:code_bolanon/models/payment_param.dart';
import 'package:code_bolanon/models/transaction_model.dart';
import 'package:code_bolanon/models/user_model.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class AppointmentService extends BaseViewModel {
  final ApiService _apiService;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  final NavigationService _navigationService;
  final DialogService _dialogService = locator<DialogService>();

  AppointmentService(
      {ApiService? apiService, NavigationService? navigationService})
      : _apiService = apiService ?? locator<ApiService>(),
        _navigationService = navigationService ?? locator<NavigationService>();

  final List<AppointmentModel> _appointments = [];
  List<AppointmentModel> get appointmentList => _appointments;

  // Notify all listeners that appointments have changed
  void notifyAppointmentsChanged() {
    notifyListeners();
  }

  // Updates the internal appointments list and notifies listeners
  Future<void> refreshAppointments() async {
    try {
      final fetchedAppointments = await fetchAllAppointments();
      _appointments.clear();
      _appointments.addAll(fetchedAppointments);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to refresh appointments: $e');
    }
  }

  Future<AppointmentModel> createSchedule(
      Map<String, dynamic> appointmentData) async {
    try {
      final Map<String, dynamic> appointment = {
        'start_at': dateFormat.format(appointmentData['startAt'].toUtc()),
        'end_at': dateFormat.format(appointmentData['endAt'].toUtc()),
        'price': (appointmentData['price'] as num).toString(),
      };

      // Debug print the request
      print('Creating appointment with data: $appointment');
      final response =
          await _apiService.post('/appointments', data: appointment);

      // Debug print the response
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      // Check for error response
      if (response.statusCode != 200 && response.statusCode != 201) {
        // Handle validation errors (422) or other errors
        if (response.data is Map && response.data.containsKey('errors')) {
          var errors = response.data['errors'];
          if (errors is Map) {
            List<String> errorMessages = [];
            errors.forEach((field, messages) {
              if (messages is List && messages.isNotEmpty) {
                errorMessages.add(messages.first.toString());
              }
            });
            if (errorMessages.isNotEmpty) {
              throw Exception(errorMessages.join('. '));
            }
          }
        }

        // If no specific errors found, use the general message
        if (response.data is Map && response.data.containsKey('message')) {
          throw Exception(response.data['message']);
        }

        throw Exception('Server error: ${response.statusCode}');
      }

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      final newAppointment =
          AppointmentModel.fromJson(response.data['data'] ?? response.data);

      // Update local appointments and notify
      await refreshAppointments();
      return newAppointment;
    } on DioException catch (e) {
      // Debug the error response in detail
      print('DioException on createSchedule: ${e.message}');
      print('DioException type: ${e.type}');
      if (e.response != null) {
        print('Error status: ${e.response!.statusCode}');
        print(
            'Error data: ${e.response!.data.runtimeType} - ${e.response!.data}');

        if (e.response!.data is Map) {
          final responseData = e.response!.data as Map;
          responseData.forEach((key, value) {
            print(
                'Response key: $key, value type: ${value.runtimeType}, value: $value');
          });
        }
      }

      // Extract error message from Dio response if available
      String errorMessage = 'Failed to create schedule';

      if (e.response != null && e.response!.data != null) {
        var responseData = e.response!.data;

        if (responseData is Map) {
          // Check for errors field first
          if (responseData.containsKey('errors')) {
            var errors = responseData['errors'];

            if (errors is Map) {
              // Build a clear error message from validation errors
              List<String> errorMessages = [];

              errors.forEach((field, messages) {
                if (messages is List && messages.isNotEmpty) {
                  String errorMsg = messages.first.toString();
                  errorMessages.add(errorMsg);
                }
              });

              if (errorMessages.isNotEmpty) {
                errorMessage = errorMessages.join('. ');
                print('Extracted error messages: $errorMessage');
              }
            } else if (errors is String) {
              errorMessage = errors;
            }
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        } else if (responseData is String) {
          errorMessage = responseData;
        }
      }

      throw Exception(errorMessage);
    } catch (e) {
      // Debug general exceptions
      print('General exception in createSchedule: $e');
      throw Exception('Failed to create schedule: $e');
    }
  }

  Future<Map<String, dynamic>> updateSchedule(
      String appointmentId, AppointmentModel appointment) async {
    try {
      final response = await _apiService.put(
        '/appointments/$appointmentId',
        data: appointment.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        String errorMessage = 'Failed to update schedule';
        if (response.data != null && response.data is Map) {
          var responseData = response.data;
          if (responseData.containsKey('errors') &&
              responseData['errors'] is Map) {
            // Extract validation errors and join them
            var errors = responseData['errors'] as Map;
            List<String> errorMessages = [];

            errors.forEach((field, messages) {
              if (messages is List && messages.isNotEmpty) {
                errorMessages.add(messages.first.toString());
              }
            });

            if (errorMessages.isNotEmpty) {
              errorMessage = errorMessages.join('. ');
            }
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        }

        return {'success': false, 'message': errorMessage};
      }

      // Update local appointments and notify
      await refreshAppointments();
      return {
        'success': true,
        'message': response.data is Map && response.data.containsKey('message')
            ? response.data['message']
            : 'Schedule updated successfully',
        'data': response.data
      };
    } on DioException catch (e) {
      String errorMessage = 'Failed to update schedule';

      if (e.response != null && e.response!.data != null) {
        var responseData = e.response!.data;
        if (responseData is Map) {
          if (responseData.containsKey('errors') &&
              responseData['errors'] is Map) {
            // Extract validation errors and join them
            var errors = responseData['errors'] as Map;
            List<String> errorMessages = [];

            errors.forEach((field, messages) {
              if (messages is List && messages.isNotEmpty) {
                errorMessages.add(messages.first.toString());
              }
            });

            if (errorMessages.isNotEmpty) {
              errorMessage = errorMessages.join('. ');
            }
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        } else if (responseData is String) {
          errorMessage = responseData;
        }
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Failed to update schedule: $e'};
    }
  }

  Future<void> deleteSchedule(String appointmentId) async {
    try {
      await _apiService.delete('/appointments/$appointmentId');

      // Update local appointments and notify
      await refreshAppointments();
    } on DioException catch (e) {
      String errorMessage = 'Failed to delete schedule';

      if (e.response != null && e.response!.data != null) {
        var responseData = e.response!.data;
        if (responseData is Map) {
          if (responseData.containsKey('errors') &&
              responseData['errors'] is Map) {
            // Extract validation errors and join them
            var errors = responseData['errors'] as Map;
            List<String> errorMessages = [];

            errors.forEach((field, messages) {
              if (messages is List && messages.isNotEmpty) {
                errorMessages.add(messages.first.toString());
              }
            });

            if (errorMessages.isNotEmpty) {
              errorMessage = errorMessages.join('. ');
            }
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        } else if (responseData is String) {
          errorMessage = responseData;
        }
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to delete schedule: $e');
    }
  }

  Future<List<AppointmentModel>> fetchAllAppointments() async {
    try {
      final response = await _apiService.get('/appointments');
      final data = (response.data['data'] as List)
          .map(
              (item) => AppointmentModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return data;
    } catch (e) {
      throw Exception('Failed to fetch active appointments: $e');
    }
  }

  Future<List<UserModel>> getAvailableTrainers() async {
    try {
      print('Fetching appointments...');
      final appointments = await fetchAllAppointments();
      print('Fetched ${appointments.length} appointments');

      // Filter for available appointments
      final availableAppointments = appointments
          .where((appointment) => appointment.status == 'available')
          .toList();
      print('Found ${availableAppointments.length} available appointments');

      // Create a set to track unique trainers (by ID)
      final uniqueTrainerIds = <int>{};
      final availableTrainers = <UserModel>[];

      // Extract unique trainer info
      for (var appointment in availableAppointments) {
        // Skip if trainer data is missing
        if (appointment.trainer == null) continue;

        // Only add if we haven't seen this trainer ID before
        if (!uniqueTrainerIds.contains(appointment.trainerId)) {
          uniqueTrainerIds.add(appointment.trainerId);
          availableTrainers.add(appointment.trainer!);
        }
      }

      print('Found ${availableTrainers.length} unique available trainers');
      return availableTrainers;
    } catch (e) {
      print('Error in getAvailableTrainers: $e');
      throw Exception('Failed to determine available trainers: $e');
    }
  }

  Future<Map<String, dynamic>> bookSchedule(
      String appointmentId, String context) async {
    try {
      // Fetch the appointment details first
      final appointmentResponse =
          await _apiService.get('/appointments/$appointmentId');
      if (appointmentResponse.statusCode != 200) {
        throw Exception(
            'Failed to fetch appointment: ${appointmentResponse.statusCode}');
      }

      final appointmentData = appointmentResponse.data['data'];
      final appointmentModel = AppointmentModel.fromJson(appointmentData);

      // Navigate to payment view first with Appointment details
      final paymentResult = await _navigationService.navigateToPaymentView(
        payment: PaymentParam(
          id: appointmentModel.id.toString(),
          title: 'Appointment with ${appointmentModel.trainer?.fullName}',
          description: context,
          price: appointmentModel.price,
          taxRate: 0.00,
          discountPercentage: 0.00,
          startAt: appointmentModel.startAt,
          endAt: appointmentModel.endAt,
        ),
      );

      // If payment was successful, proceed to book the appointment
      if (paymentResult != null && paymentResult['success'] == true) {
        print('Payment successful - paymentResult: $paymentResult');
        final Map<String, dynamic> bookingData = {
          'context': context,
        };

        final response = await _apiService.put('/appointments/$appointmentId',
            data: bookingData);

        if (response.statusCode != 200 && response.statusCode != 201) {
          return {
            'success': false,
            'message': 'Failed to book a schedule: ${response.statusCode}'
          };
        }

        // Extract transaction data from paymentResult to pass back to the ViewModel
        final result = {
          'success': true,
          'message': 'Appointment booked successfully',
          'data': response.data
        };

        // Include the transaction data in the result if available
        if (paymentResult.containsKey('transaction')) {
          print('Transaction data found in paymentResult, adding to result');
          result['transaction'] = paymentResult['transaction'];
        } else {
          print('No transaction data found in paymentResult: $paymentResult');
        }

        // Update local appointments and notify
        await refreshAppointments();
        print('Returning result with data: ${result.keys}');
        return result;
      }

      return {'success': false, 'message': 'Payment was not completed'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to book schedule: $e'};
    }
  }

  Future<AppointmentModel> getAppointment(String appointmentId) async {
    try {
      final response = await _apiService.get('/appointments/$appointmentId');

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch appointment: ${response.statusCode}');
      }

      if (response.data == null || response.data['data'] == null) {
        throw Exception('No appointment data received');
      }

      return AppointmentModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get appointment details: $e');
    }
  }

  Future<void> getAppointmentByDate() {
    // Implementation for fetching appointments by date
    throw UnimplementedError();
  }

  // Method to get appointments for the current logged-in user
  Future<List<AppointmentModel>> getUserAppointments() async {
    try {
      print('Fetching user appointments...');
      final response = await _apiService.get('/appointments/user');

      if (response.statusCode != 200) {
        print('Failed to fetch user appointments: ${response.statusCode}');
        // Try an alternative endpoint as fallback
        try {
          print('Trying alternative endpoint...');
          final altResponse = await _apiService.get('/appointments');
          if (altResponse.statusCode == 200 && altResponse.data != null) {
            print('Alternative endpoint successful!');
            return _processAppointmentsResponse(altResponse);
          }
        } catch (altError) {
          print('Alternative endpoint also failed: $altError');
        }

        return [];
      }

      return _processAppointmentsResponse(response);
    } catch (e) {
      print('Error fetching user appointments: $e');
      return [];
    }
  }

  // Helper method to process appointment response data
  List<AppointmentModel> _processAppointmentsResponse(Response response) {
    if (response.data == null || response.data['data'] == null) {
      print('No appointment data in response: ${response.data}');
      return [];
    }

    final appointmentsList = (response.data['data'] as List)
        .map((item) => AppointmentModel.fromJson(item as Map<String, dynamic>))
        .toList();

    print('Processed ${appointmentsList.length} appointments from API');

    // Debug each appointment
    for (var appointment in appointmentsList) {
      print('Appointment ID: ${appointment.id}, Status: ${appointment.status}');
      print('  Start: ${appointment.startAt}, End: ${appointment.endAt}');
      print('  Trainer: ${appointment.trainer?.fullName ?? "Unknown"}');
    }

    // Sort appointments by start date (upcoming first)
    appointmentsList.sort((a, b) => a.startAt.compareTo(b.startAt));

    // Be more inclusive in filtering - include appointments starting today or in the future,
    // and those that are currently ongoing
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final filteredAppointments = appointmentsList
        .where((appointment) =>
            // Include if starts today or in the future
            appointment.startAt
                .isAfter(todayStart.subtract(const Duration(hours: 1))) ||
            // Or if currently in progress
            (appointment.startAt.isBefore(now) &&
                appointment.endAt.isAfter(now)))
        .toList();

    print('After filtering: ${filteredAppointments.length} valid appointments');

    return filteredAppointments;
  }

  Future<void> _showAppointmentReceiptDialog(AppointmentModel appointment,
      Transaction transaction, String context) async {
    final payment = PaymentParam(
      id: appointment.id.toString(),
      title: ' Appointment with ${appointment.trainer?.fullName}',
      price: appointment.price,
      description: context,
      startAt: appointment.startAt,
      endAt: appointment.endAt,
    );
    await _dialogService.showCustomDialog(
      variant: DialogType.receipt,
      title: context,
      description: payment.description,
      data: {
        'payment': payment,
        'transaction': transaction,
      },
    );
  }
}
