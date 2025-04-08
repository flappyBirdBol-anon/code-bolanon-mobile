import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/models/appointment_model.dart';
import 'package:code_bolanon/models/payment_param.dart';
import 'package:code_bolanon/models/user_model.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:stacked_services/stacked_services.dart';

class AppointmentService {
  final ApiService _apiService;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  final NavigationService _navigationService; // Added property

  AppointmentService(
      {ApiService? apiService, NavigationService? navigationService})
      : _apiService = apiService ?? locator<ApiService>(),
        _navigationService =
            navigationService ?? locator<NavigationService>(); // Initialize

  final List<AppointmentModel> _appointments = [];
  List<AppointmentModel> get appointmentList => _appointments;

  Future<AppointmentModel> createSchedule(
      Map<String, dynamic> appointmentData) async {
    try {
      final Map<String, dynamic> appointment = {
        'start_at': dateFormat.format(appointmentData['startAt']),
        'end_at': dateFormat.format(appointmentData['endAt']),
        'price': (appointmentData['price'] as num).toString(),
      };

      final response =
          await _apiService.post('/appointments', data: appointment);

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      return AppointmentModel.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw Exception('Failed to create schedule: $e');
    }
  }

  Future<Map<String, dynamic>> updateSchedule(
      String appointmentId, AppointmentModel appointment) async {
    try {
      final Map<String, dynamic> appointmentData = {
        'start_at': dateFormat.format(appointment.startAt),
        'end_at': dateFormat.format(appointment.endAt),
        'price': appointment.price.toString(),
      };

      print('Updating appointment: $appointmentId');
      print('Request data: $appointmentData');

      final response = await _apiService.put('/appointments/$appointmentId',
          data: appointmentData);

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      // Handle specific error cases
      if (response.statusCode == 409) {
        return {
          'success': false,
          'message': response.data['message'] ??
              'Schedule overlaps with existing appointment'
        };
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        return {
          'success': false,
          'message': 'Failed to update schedule: ${response.statusCode}'
        };
      }

      if (response.data == null) {
        return {'success': false, 'message': 'No response data received'};
      }

      return {'success': true, 'message': 'Schedule updated successfully'};
    } catch (e) {
      print('Error updating schedule: $e');
      return {
        'success': false,
        'message': 'Failed to update schedule. Please try again.'
      };
    }
  }

  Future<void> deleteSchedule(String id) async {
    try {
      await _apiService.delete('/appointments/$id');
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
          title: appointmentModel.contextDetails ?? 'No context provided',
          price: appointmentModel.price,
          startAt: appointmentModel.startAt,
          endAt: appointmentModel.endAt,
        ),
      );
      print('Payment result: $paymentResult');

      // If payment was successful, proceed to book the appointment
      if (paymentResult != null && paymentResult['success'] == true) {
        final Map<String, dynamic> bookingData = {
          'context': context,
        };

        print('Booking appointment: $appointmentId');
        print('Request data: $bookingData');

        final response = await _apiService.put('/appointments/$appointmentId',
            data: bookingData);

        print('Response status: ${response.statusCode}');
        print('Response data: ${response.data}');

        if (response.statusCode != 200 && response.statusCode != 201) {
          return {
            'success': false,
            'message': 'Failed to book a schedule: ${response.statusCode}'
          };
        }

        if (response.data == null) {
          return {'success': false, 'message': 'No response data received'};
        }

        return {'success': true, 'message': 'Schedule booked successfully'};
      } else {
        return {
          'success': false,
          'message': 'Payment was not successful. Booking canceled.'
        };
      }
    } catch (e) {
      print('Error booking schedule: $e');
      return {
        'success': false,
        'message': 'Failed to book schedule. Please try again.'
      };
    }
  }
}
