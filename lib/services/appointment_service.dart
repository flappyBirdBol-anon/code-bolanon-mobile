import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/appointment_model.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:code_bolanon/services/user_service.dart';

class AppointmentService {
  final ApiService _apiService;
  final UserService _userService = locator<UserService>();

  AppointmentService({ApiService? apiService})
      : _apiService = apiService ?? locator<ApiService>();

  final List<AppointmentModel> _appointments = [];
  List<AppointmentModel> get appointmentList => _appointments;

  Future<AppointmentModel> createSchedule(AppointmentModel appointment) async {
    try {
      final response =
          await _apiService.post('/appointments', data: appointment.toJson());
      return AppointmentModel.fromJson(response.data);
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
      return (response.data as List)
          .map((item) => AppointmentModel.fromJson(item))
          .toList();
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
