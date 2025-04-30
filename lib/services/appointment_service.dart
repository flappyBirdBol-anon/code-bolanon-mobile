import 'package:code_bolanon/app/app.dialogs.dart';
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/models/appointment_model.dart';
import 'package:code_bolanon/models/payment_param.dart';
import 'package:code_bolanon/models/transaction_model.dart';
import 'package:code_bolanon/models/user_model.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:stacked_services/stacked_services.dart';

class AppointmentService {
  final ApiService _apiService;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  final NavigationService _navigationService; // Added property
  final DialogService _dialogService = locator<DialogService>();

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
          title: 'Appointment with ${appointmentModel.trainer?.fullName}',
          description: context,
          price: appointmentModel.price,
          taxRate: 0.00,
          discountPercentage: 0.00,
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

        // Add the appointment to tracked appointments if successful
        final bookingJson = response.data['data'];
        print('Booking JSON: $bookingJson');

        // // Add to local state management (assuming you have these lists)
        // _bookedAppointments.add(AppointmentModel.fromJson(bookingJson));
        // notifyListeners();

        // Show receipt dialog if transaction data is available
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
          await _showAppointmentReceiptDialog(
              appointmentModel, transaction, context);
        } else {
          print('No transaction data in payment result: $paymentResult');
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
