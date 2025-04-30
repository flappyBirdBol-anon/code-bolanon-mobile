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

enum AppointmentFilter { all, today, upcoming, completed }

class TrainerAppointmentHomeViewModel extends AppBaseViewModel {
  final _appointmentService = locator<AppointmentService>();

  AppointmentFilter _currentFilter = AppointmentFilter.all;
  AppointmentFilter get currentFilter => _currentFilter;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Appointment> _upcomingAppointments = [];
  List<Appointment> get upcomingAppointments => _upcomingAppointments;

  List<Appointment> _completedAppointments = [];
  List<Appointment> get completedAppointments => _completedAppointments;

  List<Appointment> _availableSchedules = [];
  List<Appointment> get availableSchedules => _availableSchedules;

  // Reschedule form state
  bool _showRescheduleForm = false;
  bool get showRescheduleForm => _showRescheduleForm;

  String? _selectedAppointmentId;
  String? get selectedAppointmentId => _selectedAppointmentId;

  @override
  void dispose() {
    _appointmentService.removeListener(_onAppointmentsChanged);
    super.dispose();
  }

  // Called when view is initialized
  void initialize() {
    _appointmentService.addListener(_onAppointmentsChanged);
    fetchAppointments();
  }

  // New callback method to react when AppointmentService notifies
  void _onAppointmentsChanged() {
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
      final fetchedAppointments =
          await _appointmentService.fetchAllAppointments();

      _upcomingAppointments = [];
      _completedAppointments = [];
      _availableSchedules = [];

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
        } else if (appointment.status.toLowerCase() == 'available') {
          _availableSchedules.add(Appointment(
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
      _availableSchedules = [];
      notifyListeners();
    } finally {
      setIsLoading(false);
    }
  }

  void setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void navigateToAppointmentDetails(String appointmentId) {
    navigationService.navigateToAppointmentDetailsView(
        appointmentId: appointmentId);
  }

  void navigateToSchedules() {
    navigationService.navigateTo(Routes.trainerSchedulesView);
  }

  // Show reschedule form for appointment
  void rescheduleAppointment(String appointmentId) {
    _selectedAppointmentId = appointmentId;
    _showRescheduleForm = true;
    notifyListeners();
  }

  // Hide reschedule form
  void hideRescheduleForm() {
    _showRescheduleForm = false;
    _selectedAppointmentId = null;
    notifyListeners();
    fetchAppointments(); // Refresh to show any changes
  }

  // Cancel/postpone appointment
  Future<void> postponeAppointment(String appointmentId) async {
    try {
      setIsLoading(true);

      // Only allow cancellation of available appointments
      final appointments = [..._availableSchedules, ..._upcomingAppointments];
      final appointment = appointments.firstWhere(
        (apt) => apt.id == appointmentId,
        orElse: () => throw Exception('Appointment not found'),
      );

      await _appointmentService.deleteSchedule(appointmentId);

      snackbarService.showCustomSnackBar(
        message: 'Schedule cancelled successfully',
        duration: const Duration(seconds: 3),
        variant: SnackbarType.success,
      );

      // Fetch appointments again to refresh the UI
      await fetchAppointments();
    } catch (e) {
      snackbarService.showCustomSnackBar(
        message: 'Failed to cancel schedule: $e',
        duration: const Duration(seconds: 3),
        variant: SnackbarType.error,
      );
    } finally {
      setIsLoading(false);
    }
  }

  void setFilter(AppointmentFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  List<Appointment> getFilteredAppointments() {
    switch (_currentFilter) {
      case AppointmentFilter.today:
        return getTodayAppointments();
      case AppointmentFilter.upcoming:
        return _upcomingAppointments.where((appointment) {
          return !isAppointmentToday(appointment);
        }).toList();
      case AppointmentFilter.completed:
        return _completedAppointments;
      case AppointmentFilter.all:
      default:
        return [..._upcomingAppointments, ..._completedAppointments];
    }
  }
}
