import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/appointment_model.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:code_bolanon/services/user_service.dart';
import 'package:intl/intl.dart';

class AppointmentService {
  final ApiService _apiService;
  final UserService _userService = locator<UserService>();
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  AppointmentService({ApiService? apiService})
      : _apiService = apiService ?? locator<ApiService>();

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

  Future<void> updateSchedule(String id, AppointmentModel appointment) async {
    try {
      await _apiService.put('/appointments/$id', data: appointment.toJson());
    } catch (e) {
      throw Exception('Failed to update schedule: $e');
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

  Future<List<int>> getAvailableTrainers() async {
    try {
      final appointments = await fetchAllAppointments();

      return appointments
          .where((appointment) => appointment.status == 'available')
          .map((appointment) => appointment.trainerId)
          .toSet()
          .toList();
    } catch (e) {
      throw Exception('Failed to determine available trainers: $e');
    }
  }
}
