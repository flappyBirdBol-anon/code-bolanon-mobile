import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/app/app_base_view_model.dart';
import 'package:code_bolanon/services/appointment_service.dart';
import 'package:code_bolanon/ui/common/enums/enums.dart';

class Appointment {
  final String id;
  final String learnerName;
  final String startAt;
  final String endAt;
  final bool isCompleted;

  Appointment({
    required this.id,
    required this.learnerName,
    required this.startAt,
    required this.endAt,
    this.isCompleted = false,
  });
}

class TrainerAppointmentHomeViewModel extends AppBaseViewModel {
  bool _isLoading = false; // Set initial loading to false
  bool get isLoading => _isLoading;

  List<Appointment> _upcomingAppointments = [];
  List<Appointment> get upcomingAppointments => _upcomingAppointments;

  List<Appointment> _completedAppointments = [];
  List<Appointment> get completedAppointments => _completedAppointments;

  // Called when view is initialized
  void initialize() {
    fetchAppointments();
  }

  // Get appointments that are scheduled for today
  List<Appointment> getTodayAppointments() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _upcomingAppointments.where((appointment) {
      final appointmentDate = DateTime.parse(appointment.startAt);
      return DateTime(
              appointmentDate.year, appointmentDate.month, appointmentDate.day)
          .isAtSameMomentAs(today);
    }).toList();
  }

  // Check if an appointment is scheduled for today
  bool isAppointmentToday(Appointment appointment) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDate = DateTime.parse(appointment.startAt);

    return DateTime(
            appointmentDate.year, appointmentDate.month, appointmentDate.day)
        .isAtSameMomentAs(today);
  }

  // Get count of today's appointments
  int getTodayAppointmentsCount() {
    return getTodayAppointments().length;
  }

  // Get count of appointments for this week
  int getThisWeekAppointmentsCount() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Find the start of the week (Sunday)
    final startOfWeek = today.subtract(Duration(days: today.weekday % 7));

    // End of week is start of week + 6 days
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return _upcomingAppointments.where((appointment) {
      final appointmentDate = DateTime.parse(appointment.startAt);
      final appointmentDay = DateTime(
          appointmentDate.year, appointmentDate.month, appointmentDate.day);

      return appointmentDay.isAtSameMomentAs(today) ||
          (appointmentDay.isAfter(startOfWeek) &&
              appointmentDay.isBefore(endOfWeek.add(const Duration(days: 1))));
    }).length;
  }

  Future<void> fetchAppointments() async {
    setIsLoading(true);

    try {
      final appointmentService = locator<AppointmentService>();
      final fetchedAppointments =
          await appointmentService.fetchAllAppointments();

      _upcomingAppointments = [];
      _completedAppointments = [];

      final now = DateTime.now();
      for (var appointment in fetchedAppointments) {
        if (appointment.status.toLowerCase() == 'completed') {
          _completedAppointments.add(Appointment(
            id: appointment.id.toString(),
            learnerName: appointment.learnerName ?? '',
            startAt: appointment.startAt.toString(),
            endAt: appointment.endAt.toString(),
            isCompleted: true,
          ));
        } else if (appointment.status.toLowerCase() == 'ongoing') {
          _upcomingAppointments.add(Appointment(
            id: appointment.id.toString(),
            learnerName: appointment.learnerName ?? '',
            startAt: appointment.startAt.toString(),
            endAt: appointment.endAt.toString(),
          ));
        }
      }

      notifyListeners();
    } catch (e) {
      snackbarService.showCustomSnackBar(
        message: 'Failed to load appointments: $e',
        duration: const Duration(seconds: 3),
        variant: SnackbarType.error,
      );
      _upcomingAppointments = [];
      _completedAppointments = [];
    } finally {
      setIsLoading(false);
    }
  }

  void setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void navigateToAppointmentDetails(String appointmentId) {
    //navigationService.navigateTo();
  }

  void navigateToSchedules() {
    navigationService.navigateTo(Routes.trainerSchedulesView);
  }

  void postponeAppointment(appointmentId) {
    // Postpone appointment logic here
  }
}
