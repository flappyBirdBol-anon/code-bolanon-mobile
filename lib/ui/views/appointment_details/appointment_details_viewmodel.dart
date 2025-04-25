import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/app/app_base_view_model.dart';
import 'package:code_bolanon/models/appointment_model.dart';
import 'package:code_bolanon/services/appointment_service.dart';
import 'package:code_bolanon/ui/common/enums/enums.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentDetailsViewModel extends AppBaseViewModel {
  final _appointmentService = locator<AppointmentService>();

  AppointmentModel? _appointment;
  AppointmentModel? get appointment => _appointment;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool get isTrainerView =>
      userService.currentUser?.role.toLowerCase() == 'trainer';
  bool get isBooked => appointment?.status.toLowerCase() == 'ongoing';
  bool get isCompleted => appointment?.status.toLowerCase() == 'completed';
  bool get canReschedule => isTrainerView && isBooked;
  bool get canViewMeetLink => isBooked || isCompleted;

  Future<void> initialize(String appointmentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final appointments = await _appointmentService.fetchAllAppointments();
      _appointment =
          appointments.firstWhere((apt) => apt.id.toString() == appointmentId);
      notifyListeners();
    } catch (e) {
      setError('Failed to load appointment details: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> launchGoogleMeet() async {
    if (_appointment?.gmeetLink == null || _appointment!.gmeetLink!.isEmpty) {
      snackbarService.showCustomSnackBar(
        message: 'No Google Meet link available for this appointment',
        duration: const Duration(seconds: 2),
        variant: SnackbarType.error,
      );
      return;
    }

    try {
      final Uri url = Uri.parse(_appointment!.gmeetLink!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        snackbarService.showCustomSnackBar(
          message: 'Could not launch Google Meet',
          duration: const Duration(seconds: 2),
          variant: SnackbarType.error,
        );
      }
    } catch (e) {
      setError('Error launching Google Meet: $e');
    }
  }

  void showRescheduleForm() {
    if (_appointment != null) {
      navigationService.back();
      navigationService.navigateTo(Routes.trainerSchedulesView);
    }
  }
}
