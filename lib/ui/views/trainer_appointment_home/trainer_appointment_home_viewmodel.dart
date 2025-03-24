import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/app/app_base_view_model.dart';

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

  // Mock function to simulate API call
  Future<void> fetchAppointments() async {
    setIsLoading(true);

    try {
      // Simulate API delay (shorter for better UX in demo)
      await Future.delayed(const Duration(milliseconds: 500));

      // Format: Feb 7 | 11:30 AM - 12:30 PM
      // Get current date to make sample data more realistic
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      final dayAfterTomorrow = today.add(const Duration(days: 2));

      // Format dates to ISO string for the CustomAppointmentList widget
      String formatDateTime(DateTime dt) {
        return dt.toIso8601String();
      }

      // Mock data for demonstration - using dates matching the wireframe
      _upcomingAppointments = [
        // Today's appointments
        Appointment(
          id: '1',
          learnerName: 'Zachary Albert Legariot',
          startAt: formatDateTime(
              DateTime(today.year, today.month, today.day, 11, 30)),
          endAt: formatDateTime(
              DateTime(today.year, today.month, today.day, 12, 30)),
        ),
        Appointment(
          id: '2',
          learnerName: 'Jelah Marie Dango',
          startAt: formatDateTime(
              DateTime(today.year, today.month, today.day, 13, 30)),
          endAt: formatDateTime(
              DateTime(today.year, today.month, today.day, 14, 30)),
        ),
        // Tomorrow's appointments
        Appointment(
          id: '3',
          learnerName: 'Jelah Marie Dango',
          startAt: formatDateTime(tomorrow.add(const Duration(hours: 10))),
          endAt: formatDateTime(tomorrow.add(const Duration(hours: 11))),
        ),
        // Day after tomorrow appointments
        Appointment(
          id: '4',
          learnerName: 'Mark Anthony Santos',
          startAt:
              formatDateTime(dayAfterTomorrow.add(const Duration(hours: 15))),
          endAt:
              formatDateTime(dayAfterTomorrow.add(const Duration(hours: 16))),
        ),
        Appointment(
          id: '5',
          learnerName: 'Christian James Prado',
          startAt:
              formatDateTime(dayAfterTomorrow.add(const Duration(hours: 17))),
          endAt:
              formatDateTime(dayAfterTomorrow.add(const Duration(hours: 18))),
        ),
      ];

      _completedAppointments = [
        Appointment(
          id: '6',
          learnerName: 'Zachary Albert Legariot',
          startAt: formatDateTime(
              DateTime(today.year, today.month, today.day - 1, 11, 30)),
          endAt: formatDateTime(
              DateTime(today.year, today.month, today.day - 1, 12, 30)),
          isCompleted: true,
        ),
        Appointment(
          id: '7',
          learnerName: 'Jelah Marie Dango',
          startAt: formatDateTime(
              DateTime(today.year, today.month, today.day - 1, 13, 30)),
          endAt: formatDateTime(
              DateTime(today.year, today.month, today.day - 1, 14, 30)),
          isCompleted: true,
        ),
        Appointment(
          id: '8',
          learnerName: 'Mark Anthony Santos',
          startAt: formatDateTime(
              DateTime(today.year, today.month, today.day - 3, 15, 0)),
          endAt: formatDateTime(
              DateTime(today.year, today.month, today.day - 3, 16, 0)),
          isCompleted: true,
        ),
      ];
    } catch (e) {
      // Handle errors
      print('Error fetching appointments: $e');
      _upcomingAppointments = [];
      _completedAppointments = [];
    } finally {
      // Ensure loading state is set to false even if there's an error
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
