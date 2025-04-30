import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app_base_view_model.dart';
import 'package:code_bolanon/models/appointment_model.dart';
import 'package:code_bolanon/services/appointment_service.dart';
import 'package:code_bolanon/services/user_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentDetailsViewModel extends AppBaseViewModel {
  final _appointmentService = locator<AppointmentService>();
  final _userService = locator<UserService>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AppointmentModel? _appointment;
  AppointmentModel? get appointment => _appointment;

  bool _showRescheduleForm = false;
  bool get showRescheduleForm => _showRescheduleForm;

  bool get isBooked => _appointment?.status.toLowerCase() == 'ongoing';
  bool get isCompleted => _appointment?.status.toLowerCase() == 'completed';
  bool get isTrainerView => _userService.currentUser?.role == 'trainer';

  bool get canReschedule {
    if (_appointment == null) return false;
    if (isCompleted) return false;
    if (!isTrainerView)
      return false; // If user is not a trainer, they can't reschedule

    // Only trainers can reschedule their own available slots and ongoing appointments
    return _appointment!.status.toLowerCase() == 'available' ||
        _appointment!.status.toLowerCase() == 'ongoing';
  }

  Future<void> initialize(String appointmentId) async {
    await loadAppointment(appointmentId);
  }

  Future<void> loadAppointment(String appointmentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _appointment = await _appointmentService.getAppointment(appointmentId);
    } catch (e) {
      _errorMessage = 'Failed to load appointment details';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> launchGoogleMeet() async {
    if (_appointment?.gmeetLink == null) return;

    final uri = Uri.parse(_appointment!.gmeetLink!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void openRescheduleForm() {
    _showRescheduleForm = true;
    notifyListeners();
  }

  void hideRescheduleForm() {
    if (_showRescheduleForm) {
      _showRescheduleForm = false;
      loadAppointment(
          _appointment!.id.toString()); // Refresh the appointment data
      notifyListeners();
    }
  }
}
