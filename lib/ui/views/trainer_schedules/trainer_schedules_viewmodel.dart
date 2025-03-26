import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app_base_view_model.dart';
import 'package:code_bolanon/models/appointment_model.dart';
import 'package:code_bolanon/services/appointment_service.dart';
import 'package:code_bolanon/ui/common/enums/enums.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TrainerSchedulesViewModel extends AppBaseViewModel {
  final _appointmentService = locator<AppointmentService>();

  // UI State
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Calendar State
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  int _selectedWeekday = DateTime.now().weekday;
  int get selectedWeekday => _selectedWeekday;

  // Day selections from Sunday (1) to Saturday (7)
  final List<String> weekdays = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat'
  ];

  // Current displayed week (for the calendar)
  DateTime _currentWeekStart =
      DateTime.now().subtract(Duration(days: DateTime.now().weekday % 7));
  DateTime get currentWeekStart => _currentWeekStart;

  // Available time slots for the selected date
  List<AppointmentModel> _availableTimeSlots = [];
  List<AppointmentModel> get availableTimeSlots => _availableTimeSlots;

  // Appointments State
  List<AppointmentModel> _scheduledAppointments = [];
  List<AppointmentModel> get scheduledAppointments => _scheduledAppointments;

  // Form State
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay get startTime => _startTime;

  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay get endTime => _endTime;

  bool _showAddScheduleForm = false;
  bool get showAddScheduleForm => _showAddScheduleForm;

  bool _showEditScheduleForm = false;
  bool get showEditScheduleForm => _showEditScheduleForm;

  bool _showRescheduleForm = false;
  bool get showRescheduleForm => _showRescheduleForm;

  String? _selectedAppointmentId;
  String? get selectedAppointmentId => _selectedAppointmentId;

  int? _selectedTimeSlotId;
  int? get selectedTimeSlotId => _selectedTimeSlotId;

  double _price = 500.0;
  double get price => _price;

  bool isSelectedDateActive(DateTime date) {
    final now = DateTime.now();
    return date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day &&
        date.isAfter(DateTime(now.year, now.month, now.day));
  }

  void setPrice(double value) {
    _price = value;
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

  // Initialize
  Future<void> initialize() async {
    await runBusyFuture(loadAppointments());
  }

  // Load appointments for selected date
  Future<void> loadAppointments() async {
    setIsLoading(true);
    try {
      final appointments = await _appointmentService.fetchAllAppointments();

      // Filter appointments for the selected date
      final selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

      // Filter and sort available time slots and completed slots with no learner
      _availableTimeSlots = appointments
          .where((apt) =>
              DateFormat('yyyy-MM-dd').format(apt.startAt) == selectedDateStr &&
              (apt.status.toLowerCase() == 'available' ||
                  (apt.status.toLowerCase() == 'completed' &&
                      apt.contextDetails == null)))
          .toList()
        ..sort((a, b) => a.startAt.compareTo(b.startAt));

      // Filter and sort scheduled appointments (status: 'ongoing' or 'completed' with learner)
      _scheduledAppointments = appointments
          .where((apt) =>
              DateFormat('yyyy-MM-dd').format(apt.startAt) == selectedDateStr &&
              ((apt.status.toLowerCase() == 'ongoing') ||
                  (apt.status.toLowerCase() == 'completed' &&
                      apt.contextDetails != null)))
          .toList()
        ..sort((a, b) => a.startAt.compareTo(b.startAt));

      notifyListeners();
    } catch (e) {
      _showErrorMessage('Failed to load appointments: $e');
    } finally {
      setIsLoading(false);
    }
  }

  // Create new appointment slot (trainer availability)
  Future<void> createAvailableTimeSlot() async {
    if (!_validateTimes()) return;
    if (_checkForOverlap()) {
      _showErrorMessage('This time slot overlaps with an existing appointment');
      return;
    }

    setIsLoading(true);
    try {
      final newAppointment = {
        'startAt': DateTime(_selectedDate.year, _selectedDate.month,
            _selectedDate.day, _startTime.hour, _startTime.minute),
        'endAt': DateTime(_selectedDate.year, _selectedDate.month,
            _selectedDate.day, _endTime.hour, _endTime.minute),
        'price': _price,
      };
      await _appointmentService.createSchedule(newAppointment);

      _showSuccessMessage('Schedule added successfully');
      await loadAppointments();
      resetForm();
      _showAddScheduleForm = false;
    } catch (e) {
      _showErrorMessage('Failed to create schedule: $e');
    } finally {
      setIsLoading(false);
    }
  }

  // Add helper method to check for overlapping appointments
  bool _checkForOverlap({int? excludeId}) {
    final newStart = DateTime(_selectedDate.year, _selectedDate.month,
        _selectedDate.day, _startTime.hour, _startTime.minute);
    final newEnd = DateTime(_selectedDate.year, _selectedDate.month,
        _selectedDate.day, _endTime.hour, _endTime.minute);

    // Check overlap with available time slots
    for (var slot in _availableTimeSlots) {
      if (excludeId != null && slot.id == excludeId) continue;
      if (_isOverlapping(newStart, newEnd, slot.startAt, slot.endAt)) {
        return true;
      }
    }

    // Check overlap with scheduled appointments
    for (var apt in _scheduledAppointments) {
      if (excludeId != null && apt.id == excludeId) continue;
      if (_isOverlapping(newStart, newEnd, apt.startAt, apt.endAt)) {
        return true;
      }
    }

    return false;
  }

  // Helper method to check if two time ranges overlap
  bool _isOverlapping(
      DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
    return start1.isBefore(end2) && end1.isAfter(start2);
  }

  // Single unified method for editing/rescheduling
  void showEditForm(String id) {
    try {
      // Find the appointment in either list
      final appointment = [..._availableTimeSlots, ..._scheduledAppointments]
          .firstWhere((apt) => apt.id.toString() == id);

      _selectedTimeSlotId = appointment.id;
      _selectedAppointmentId = null;
      _showRescheduleForm = true;

      // Set form data
      _startTime = TimeOfDay(
        hour: appointment.startAt.hour,
        minute: appointment.startAt.minute,
      );
      _endTime = TimeOfDay(
        hour: appointment.endAt.hour,
        minute: appointment.endAt.minute,
      );
      _price = appointment.price ?? 500.0;

      notifyListeners();
    } catch (e) {
      _showErrorMessage('Failed to load appointment details');
      hideRescheduleForm();
    }
  }

  // Replace these methods to use the unified showEditForm
  void showRescheduleFormForAppointment(String id) => showEditForm(id);
  void openEditScheduleForm(int slotId) => showEditForm(slotId.toString());

  // Update this method to be simpler
  Future<void> updateAppointment() async {
    if (!_validateTimes()) return;

    try {
      if (_selectedTimeSlotId == null) {
        throw Exception('No appointment selected for update');
      }

      // Find the appointment to update
      final appointmentToUpdate = [
        ..._availableTimeSlots,
        ..._scheduledAppointments
      ].firstWhere((apt) => apt.id == _selectedTimeSlotId);

      // Check for overlaps excluding current appointment
      if (_checkForOverlap(excludeId: _selectedTimeSlotId)) {
        _showErrorMessage(
            'This time slot overlaps with an existing appointment');
        return;
      }

      setIsLoading(true);

      final updatedAppointment = AppointmentModel(
        id: appointmentToUpdate.id,
        startAt: DateTime(_selectedDate.year, _selectedDate.month,
            _selectedDate.day, _startTime.hour, _startTime.minute),
        endAt: DateTime(_selectedDate.year, _selectedDate.month,
            _selectedDate.day, _endTime.hour, _endTime.minute),
        price: _price,
        contextDetails: appointmentToUpdate.contextDetails,
        status: appointmentToUpdate.status,
        trainerId: appointmentToUpdate.trainerId,
        gmeetLink: appointmentToUpdate.gmeetLink,
      );

      final result = await _appointmentService.updateSchedule(
          appointmentToUpdate.id.toString(), updatedAppointment);

      if (result['success']) {
        _showSuccessMessage(result['message']);
        await loadAppointments();
        hideRescheduleForm();
      } else {
        _showErrorMessage(result['message']);
      }
    } catch (e) {
      _showErrorMessage('Failed to update schedule');
    } finally {
      setIsLoading(false);
    }
  }

  // Postpone or cancel an appointment
  Future<void> postponeAppointment(String id) async {
    setIsLoading(true);
    try {
      await _appointmentService.deleteSchedule(id);
      _showSuccessMessage('Appointment cancelled successfully');
      await loadAppointments();
    } catch (e) {
      _showErrorMessage('Failed to cancel appointment: $e');
    } finally {
      setIsLoading(false);
    }
  }

  // Helper methods
  bool _validateTimes() {
    if (_startTime.hour >= _endTime.hour &&
        (_startTime.hour != _endTime.hour ||
            _startTime.minute >= _endTime.minute)) {
      setErrorMessage('End time must be after start time');
      return false;
    }
    return true;
  }

  void resetForm() {
    _startTime = const TimeOfDay(hour: 9, minute: 0);
    _endTime = const TimeOfDay(hour: 10, minute: 0);
    _price = 500.0;
    _showAddScheduleForm = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Select a specific date from date picker and update weekly view
  void selectDateFromCalendar(DateTime date) {
    // Update the selected date
    _selectedDate = date;

    // Update the current week start to show the week containing the selected date
    final dayOfWeek = date.weekday % 7; // 0 for Sunday, 1 for Monday, etc.
    _currentWeekStart = date.subtract(Duration(days: dayOfWeek));

    // Update the selected weekday
    _selectedWeekday = dayOfWeek;

    // Refresh appointments for the new date
    loadAppointments();

    notifyListeners();
  }

  // Set loading state
  void setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Set error message
  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Navigate to previous week
  void previousWeek() {
    _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    notifyListeners();
  }

  // Navigate to next week
  void nextWeek() {
    _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    notifyListeners();
  }

  // Select a date from the calendar
  void selectDate(DateTime date, int weekday) {
    _selectedDate = date;
    _selectedWeekday = weekday;
    loadAppointments(); // Refresh appointments for the new date
    notifyListeners();
  }

  // Get the current week days for display in the calendar
  List<DateTime> getWeekDays() {
    return List.generate(7, (index) {
      return _currentWeekStart.add(Duration(days: index));
    });
  }

  // Format date as MM/dd/yy
  String formatDate(DateTime date) {
    return DateFormat('MM/dd/yy').format(date);
  }

  // Convert TimeOfDay to formatted string (e.g., "09:00 AM")
  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // Set start time for new schedule
  void setStartTime(TimeOfDay time) {
    _startTime = time;
    notifyListeners();
  }

  // Set end time for new schedule
  void setEndTime(TimeOfDay time) {
    _endTime = time;
    notifyListeners();
  }

  // Toggle add schedule form visibility
  void toggleAddScheduleForm() {
    _showAddScheduleForm = !_showAddScheduleForm;
    if (_showAddScheduleForm) {
      // Reset to default times when opening the form
      _startTime = const TimeOfDay(hour: 9, minute: 0);
      _endTime = const TimeOfDay(hour: 10, minute: 0);
    }
    notifyListeners();
  }

  // Hide edit schedule form
  void hideEditScheduleForm() {
    _showEditScheduleForm = false;
    _selectedTimeSlotId = null;
    notifyListeners();
  }

  // Hide reschedule form
  void hideRescheduleForm() {
    _showRescheduleForm = false;
    _selectedAppointmentId = null;
    notifyListeners();
  }

  // Remove an available time slot
  Future<void> removeTimeSlot(int id) async {
    setIsLoading(true);
    try {
      await _appointmentService.deleteSchedule(id.toString());
      await loadAppointments();
    } catch (e) {
      setErrorMessage('Failed to remove time slot: $e');
    } finally {
      setIsLoading(false);
    }
  }

  void handleAppointmentTap(appointmentId) {
    print('Appointment tapped: $appointmentId');
  }
}
