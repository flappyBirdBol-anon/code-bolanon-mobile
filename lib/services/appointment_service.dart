import 'package:code_bolanon/app/app.dialogs.dart';
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/models/appointment_model.dart';
import 'package:code_bolanon/models/payment_param.dart';
import 'package:code_bolanon/models/transaction_model.dart';
import 'package:code_bolanon/models/user_model.dart';
import 'package:code_bolanon/services/api_service.dart';
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
        'start_at': dateFormat.format(appointmentData['startAt']),
        'end_at': dateFormat.format(appointmentData['endAt']),
        'price': (appointmentData['price'] as num).toString(),
      };

      final response =
          await _apiService.post('/appointments', data: appointment);

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      final newAppointment =
          AppointmentModel.fromJson(response.data['data'] ?? response.data);

      // Update local appointments and notify
      await refreshAppointments();
      return newAppointment;
    } catch (e) {
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
        return {
          'success': false,
          'message': 'Failed to update schedule: ${response.statusCode}'
        };
      }

      // Update local appointments and notify
      await refreshAppointments();
      return {
        'success': true,
        'message': 'Schedule updated successfully',
        'data': response.data
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to update schedule: $e'};
    }
  }

  Future<void> deleteSchedule(String appointmentId) async {
    try {
      await _apiService.delete('/appointments/$appointmentId');

      // Update local appointments and notify
      await refreshAppointments();
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

        // Update local appointments and notify
        await refreshAppointments();
        return {
          'success': true,
          'message': 'Appointment booked successfully',
          'data': response.data
        };
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
