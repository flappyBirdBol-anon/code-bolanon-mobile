import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app_base_view_model.dart';
import 'package:code_bolanon/models/appointment_model.dart';
import 'package:code_bolanon/services/appointment_service.dart';
import 'package:code_bolanon/ui/common/enums/enums.dart';
import 'package:intl/intl.dart';

class LearnerBookAppointmentViewModel extends AppBaseViewModel {
  final _appointmentService = locator<AppointmentService>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Calendar State
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  DateTime _currentWeekStart =
      DateTime.now().subtract(Duration(days: DateTime.now().weekday % 7));
  DateTime get currentWeekStart => _currentWeekStart;

  final List<String> weekdays = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat'
  ];

  // Available Schedules
  List<AppointmentModel> _availableTimeSlots = [];
  List<AppointmentModel> get availableTimeSlots => _availableTimeSlots;

  // Initialize
  Future<void> initialize() async {
    await runBusyFuture(loadAvailableSchedules());
  }

  // Load available schedules for selected date
  Future<void> loadAvailableSchedules() async {
    setIsLoading(true);
    try {
      final appointments = await _appointmentService.fetchAllAppointments();

      // Filter appointments for the selected date and available status
      final selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

      _availableTimeSlots = appointments
          .where((apt) =>
              DateFormat('yyyy-MM-dd').format(apt.startAt) == selectedDateStr &&
              apt.status.toLowerCase() == 'available')
          .toList()
        ..sort((a, b) => a.startAt.compareTo(b.startAt));

      notifyListeners();
    } catch (e) {
      _showErrorMessage('Failed to load available schedules: $e');
    } finally {
      setIsLoading(false);
    }
  }

// Book appointment
  Future<void> bookAppointment(int appointmentId, String contextDetails) async {
    print('Booking appointment with ID: $appointmentId');
    setIsLoading(true);
    try {
      final result = await _appointmentService.bookSchedule(
          appointmentId.toString(), contextDetails);

      if (result['success']) {
        _showSuccessMessage(result['message']);
        await loadAvailableSchedules();
      } else {
        _showErrorMessage(result['message']);
      }
      _showSuccessMessage('Appointment booked successfully');
      await loadAvailableSchedules();
    } catch (e) {
      _showErrorMessage('Failed to book appointment: $e');
    } finally {
      setIsLoading(false);
    }
  }

  // Calendar navigation methods
  void previousWeek() {
    _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    notifyListeners();
  }

  void nextWeek() {
    _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    notifyListeners();
  }

  List<DateTime> getWeekDays() {
    return List.generate(
        7, (index) => _currentWeekStart.add(Duration(days: index)));
  }

  void selectDateFromCalendar(DateTime date) {
    _selectedDate = date;
    final dayOfWeek = date.weekday % 7;
    _currentWeekStart = date.subtract(Duration(days: dayOfWeek));
    loadAvailableSchedules();
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    loadAvailableSchedules();
    notifyListeners();
  }

  // Helper methods
  void setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _showSuccessMessage(String message) {
    snackbarService.showCustomSnackBar(
      message: message,
      duration: const Duration(seconds: 3),
      variant: SnackbarType.success,
    );
  }

  void _showErrorMessage(String message) {
    snackbarService.showCustomSnackBar(
      message: message,
      duration: const Duration(seconds: 3),
      variant: SnackbarType.error,
    );
  }

  bool isSelectedDateActive(DateTime date) {
    final now = DateTime.now();
    return date.isAfter(DateTime(now.year, now.month, now.day - 1));
  }
}
