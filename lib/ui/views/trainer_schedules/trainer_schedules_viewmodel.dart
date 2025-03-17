import 'package:code_bolanon/app/app_base_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleTimeSlot {
  final String id;
  final String startTime;
  final String endTime;
  final bool isBooked;

  ScheduleTimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.isBooked = false,
  });
}

class ScheduledAppointment {
  final String id;
  final String learnerName;
  final DateTime date;
  final String startTime;
  final String endTime;

  ScheduledAppointment({
    required this.id,
    required this.learnerName,
    required this.date,
    required this.startTime,
    required this.endTime,
  });
}

class TrainerSchedulesViewModel extends AppBaseViewModel {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isBusy = false;
  @override
  bool get isBusy => _isBusy;

  // Calendar navigation
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
  List<ScheduleTimeSlot> _availableTimeSlots = [];
  List<ScheduleTimeSlot> get availableTimeSlots => _availableTimeSlots;

  // Scheduled appointments
  List<ScheduledAppointment> _scheduledAppointments = [];
  List<ScheduledAppointment> get scheduledAppointments =>
      _scheduledAppointments;

  // For add/edit schedule form
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

  String? _selectedTimeSlotId;
  String? get selectedTimeSlotId => _selectedTimeSlotId;

  // Sample data maps for different dates
  final Map<String, List<ScheduleTimeSlot>> _sampleAvailableSlots = {};
  final Map<String, List<ScheduledAppointment>> _sampleScheduledAppointments =
      {};

  // Initialize the view model
  void initialize() {
    _initializeSampleData();
    fetchAvailableTimeSlots();
    fetchScheduledAppointments();
  }

  // Initialize sample data for different dates
  void _initializeSampleData() {
    // Generate sample data for current week and next week
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Create sample data for each day of the current week
    for (int i = 0; i < 14; i++) {
      final date = today.add(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      // Different available slots for different days
      final slots = <ScheduleTimeSlot>[];

      // Add 3-5 time slots per day with varying times
      final slotCount = 3 + (date.day % 3); // 3-5 slots based on day

      for (int j = 0; j < slotCount; j++) {
        final startHour = 8 + (j * 2) + (date.day % 2); // Varies by day
        final endHour = startHour + 1 + (j % 2); // 1 or 2 hour slots

        slots.add(ScheduleTimeSlot(
          id: '$dateStr-slot-$j',
          startTime: formatTimeOfDay(TimeOfDay(hour: startHour, minute: 0)),
          endTime: formatTimeOfDay(TimeOfDay(hour: endHour, minute: 0)),
          isBooked: j == 1, // Some slots are already booked
        ));
      }

      _sampleAvailableSlots[dateStr] = slots;

      // Scheduled appointments for each day
      final appointments = <ScheduledAppointment>[];

      // 1-3 appointments per day
      final appointmentCount = 1 + (date.day % 3);

      final learners = [
        'Zachary Albert Legariot',
        'Jelah Marie Dango',
        'Mark Anthony Santos',
        'Christian James Prado',
        'Sofia Garcia',
        'Nathan Williams',
        'Emily Johnson'
      ];

      for (int k = 0; k < appointmentCount; k++) {
        final startHour = 10 + (k * 2);
        final endHour = startHour + 1;
        final learnerIndex = (date.day + k) % learners.length;

        appointments.add(ScheduledAppointment(
          id: '$dateStr-appt-$k',
          learnerName: learners[learnerIndex],
          date: date,
          startTime: formatTimeOfDay(TimeOfDay(hour: startHour, minute: 30)),
          endTime: formatTimeOfDay(TimeOfDay(hour: endHour, minute: 30)),
        ));
      }

      _sampleScheduledAppointments[dateStr] = appointments;
    }

    // Add specific sample data for March 17 (Monday) and March 19 (Wednesday), 2024
    _addSpecificDateSample(DateTime(2024, 3, 17), true); // Monday, March 17
    _addSpecificDateSample(DateTime(2024, 3, 19), false); // Wednesday, March 19
  }

  // Helper method to add sample data for specific dates
  void _addSpecificDateSample(DateTime date, bool isMonday) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    // Create sample time slots for the specific date
    final slots = <ScheduleTimeSlot>[];

    // Monday slots (Morning and afternoon)
    if (isMonday) {
      slots.add(ScheduleTimeSlot(
        id: '$dateStr-slot-1',
        startTime: formatTimeOfDay(const TimeOfDay(hour: 9, minute: 0)),
        endTime: formatTimeOfDay(const TimeOfDay(hour: 10, minute: 30)),
        isBooked: false,
      ));

      slots.add(ScheduleTimeSlot(
        id: '$dateStr-slot-2',
        startTime: formatTimeOfDay(const TimeOfDay(hour: 11, minute: 0)),
        endTime: formatTimeOfDay(const TimeOfDay(hour: 12, minute: 30)),
        isBooked: true, // Already booked
      ));

      slots.add(ScheduleTimeSlot(
        id: '$dateStr-slot-3',
        startTime: formatTimeOfDay(const TimeOfDay(hour: 14, minute: 0)),
        endTime: formatTimeOfDay(const TimeOfDay(hour: 16, minute: 0)),
        isBooked: false,
      ));
    }
    // Wednesday slots (Afternoon and evening)
    else {
      slots.add(ScheduleTimeSlot(
        id: '$dateStr-slot-1',
        startTime: formatTimeOfDay(const TimeOfDay(hour: 13, minute: 0)),
        endTime: formatTimeOfDay(const TimeOfDay(hour: 14, minute: 30)),
        isBooked: true, // Already booked
      ));

      slots.add(ScheduleTimeSlot(
        id: '$dateStr-slot-2',
        startTime: formatTimeOfDay(const TimeOfDay(hour: 15, minute: 0)),
        endTime: formatTimeOfDay(const TimeOfDay(hour: 16, minute: 30)),
        isBooked: false,
      ));

      slots.add(ScheduleTimeSlot(
        id: '$dateStr-slot-3',
        startTime: formatTimeOfDay(const TimeOfDay(hour: 17, minute: 0)),
        endTime: formatTimeOfDay(const TimeOfDay(hour: 18, minute: 30)),
        isBooked: false,
      ));
    }

    // Set the available slots for the date
    _sampleAvailableSlots[dateStr] = slots;

    // Create sample appointments for the specific date
    final appointments = <ScheduledAppointment>[];

    final learners = ['Michael Robertson', 'Sophia Garcia', 'Andrew Thomas'];

    if (isMonday) {
      // One appointment for Monday
      appointments.add(ScheduledAppointment(
        id: '$dateStr-appt-1',
        learnerName: learners[0],
        date: date,
        startTime: formatTimeOfDay(const TimeOfDay(hour: 11, minute: 0)),
        endTime: formatTimeOfDay(const TimeOfDay(hour: 12, minute: 30)),
      ));
    } else {
      // Two appointments for Wednesday
      appointments.add(ScheduledAppointment(
        id: '$dateStr-appt-1',
        learnerName: learners[1],
        date: date,
        startTime: formatTimeOfDay(const TimeOfDay(hour: 13, minute: 0)),
        endTime: formatTimeOfDay(const TimeOfDay(hour: 14, minute: 30)),
      ));

      appointments.add(ScheduledAppointment(
        id: '$dateStr-appt-2',
        learnerName: learners[2],
        date: date,
        startTime: formatTimeOfDay(const TimeOfDay(hour: 9, minute: 0)),
        endTime: formatTimeOfDay(const TimeOfDay(hour: 10, minute: 30)),
      ));
    }

    // Set the scheduled appointments for the date
    _sampleScheduledAppointments[dateStr] = appointments;
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

    // Refresh available slots and appointments
    fetchAvailableTimeSlots();
    fetchScheduledAppointments();

    notifyListeners();
  }

  // Set loading state
  void setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Set busy state
  void setIsBusy(bool value) {
    _isBusy = value;
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
    fetchAvailableTimeSlots(); // Refresh available slots for the new date
    fetchScheduledAppointments(); // Refresh appointments for the new date
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

  // Show edit schedule form with pre-filled data
  void openEditScheduleForm(String slotId) {
    _selectedTimeSlotId = slotId;
    _showEditScheduleForm = true;

    // Find the time slot to pre-fill form
    final slot = _availableTimeSlots.firstWhere(
      (slot) => slot.id == slotId,
      orElse: () => _availableTimeSlots.first,
    );

    // Parse time strings to TimeOfDay
    _parseAndSetTimes(slot.startTime, slot.endTime);

    notifyListeners();
  }

  // Hide edit schedule form
  void hideEditScheduleForm() {
    _showEditScheduleForm = false;
    _selectedTimeSlotId = null;
    notifyListeners();
  }

  // Show reschedule form for specific appointment
  void showRescheduleFormForAppointment(String appointmentId) {
    _selectedAppointmentId = appointmentId;
    _showRescheduleForm = true;

    // Find the appointment to pre-fill form
    final appointment = _scheduledAppointments.firstWhere(
      (apt) => apt.id == appointmentId,
      orElse: () => _scheduledAppointments.first,
    );

    // Parse time strings to TimeOfDay
    _parseAndSetTimes(appointment.startTime, appointment.endTime);

    notifyListeners();
  }

  // Helper method to parse time strings and set TimeOfDay values
  void _parseAndSetTimes(String startTimeStr, String endTimeStr) {
    final startTimeParts = startTimeStr.split(':');
    final startHour = int.parse(startTimeParts[0]);
    final startMinute = int.parse(startTimeParts[1].split(' ')[0]);
    final isStartAM = startTimeStr.contains('AM');

    final endTimeParts = endTimeStr.split(':');
    final endHour = int.parse(endTimeParts[0]);
    final endMinute = int.parse(endTimeParts[1].split(' ')[0]);
    final isEndAM = endTimeStr.contains('AM');

    _startTime = TimeOfDay(
      hour: isStartAM
          ? (startHour == 12 ? 0 : startHour)
          : (startHour == 12 ? 12 : startHour + 12),
      minute: startMinute,
    );

    _endTime = TimeOfDay(
      hour: isEndAM
          ? (endHour == 12 ? 0 : endHour)
          : (endHour == 12 ? 12 : endHour + 12),
      minute: endMinute,
    );
  }

  // Hide reschedule form
  void hideRescheduleForm() {
    _showRescheduleForm = false;
    _selectedAppointmentId = null;
    notifyListeners();
  }

  // Add a new available time slot
  Future<void> addAvailableTimeSlot() async {
    if (_startTime.hour >= _endTime.hour &&
        (_startTime.hour != _endTime.hour ||
            _startTime.minute >= _endTime.minute)) {
      // Show error: End time must be after start time
      setErrorMessage('End time must be after start time');
      return;
    }

    setIsBusy(true);
    setIsLoading(true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final newSlot = ScheduleTimeSlot(
        id: id,
        startTime: formatTimeOfDay(_startTime),
        endTime: formatTimeOfDay(_endTime),
        isBooked: false,
      );

      _availableTimeSlots.add(newSlot);

      // Sort time slots by start time
      _sortTimeSlots();

      // Reset form
      _startTime = const TimeOfDay(hour: 9, minute: 0);
      _endTime = const TimeOfDay(hour: 10, minute: 0);
      _showAddScheduleForm = false;

      // Update sample data
      final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
      if (_sampleAvailableSlots.containsKey(dateKey)) {
        _sampleAvailableSlots[dateKey]!.add(newSlot);
        _sortSampleTimeSlots(dateKey);
      } else {
        _sampleAvailableSlots[dateKey] = [newSlot];
      }
    } catch (e) {
      setErrorMessage('Failed to add time slot: $e');
    } finally {
      setIsBusy(false);
      setIsLoading(false);
    }
  }

  // Update an existing available time slot
  Future<void> updateAvailableTimeSlot() async {
    if (_selectedTimeSlotId == null) return;

    if (_startTime.hour >= _endTime.hour &&
        (_startTime.hour != _endTime.hour ||
            _startTime.minute >= _endTime.minute)) {
      // Show error: End time must be after start time
      setErrorMessage('End time must be after start time');
      return;
    }

    setIsBusy(true);
    setIsLoading(true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      final index = _availableTimeSlots
          .indexWhere((slot) => slot.id == _selectedTimeSlotId);
      if (index != -1) {
        final slot = _availableTimeSlots[index];
        _availableTimeSlots[index] = ScheduleTimeSlot(
          id: slot.id,
          startTime: formatTimeOfDay(_startTime),
          endTime: formatTimeOfDay(_endTime),
          isBooked: slot.isBooked,
        );
      }

      // Sort time slots by start time
      _sortTimeSlots();

      // Reset form
      _showEditScheduleForm = false;
      _selectedTimeSlotId = null;

      // Update sample data
      final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
      if (_sampleAvailableSlots.containsKey(dateKey)) {
        final sampleIndex = _sampleAvailableSlots[dateKey]!
            .indexWhere((slot) => slot.id == _selectedTimeSlotId);
        if (sampleIndex != -1) {
          final slot = _sampleAvailableSlots[dateKey]![sampleIndex];
          _sampleAvailableSlots[dateKey]![sampleIndex] = ScheduleTimeSlot(
            id: slot.id,
            startTime: formatTimeOfDay(_startTime),
            endTime: formatTimeOfDay(_endTime),
            isBooked: slot.isBooked,
          );
          _sortSampleTimeSlots(dateKey);
        }
      }
    } catch (e) {
      setErrorMessage('Failed to update time slot: $e');
    } finally {
      setIsBusy(false);
      setIsLoading(false);
    }
  }

  // Sort time slots helper
  void _sortTimeSlots() {
    _availableTimeSlots.sort((a, b) {
      final aTime = a.startTime;
      final bTime = b.startTime;

      final aHour = int.parse(aTime.split(':')[0]);
      final bHour = int.parse(bTime.split(':')[0]);

      if (aHour != bHour) return aHour.compareTo(bHour);

      final aMinute = int.parse(aTime.split(':')[1].split(' ')[0]);
      final bMinute = int.parse(bTime.split(':')[1].split(' ')[0]);

      return aMinute.compareTo(bMinute);
    });
  }

  // Sort sample time slots for a specific date
  void _sortSampleTimeSlots(String dateKey) {
    if (_sampleAvailableSlots.containsKey(dateKey)) {
      _sampleAvailableSlots[dateKey]!.sort((a, b) {
        final aTime = a.startTime;
        final bTime = b.startTime;

        final aHour = int.parse(aTime.split(':')[0]);
        final bHour = int.parse(bTime.split(':')[0]);

        if (aHour != bHour) return aHour.compareTo(bHour);

        final aMinute = int.parse(aTime.split(':')[1].split(' ')[0]);
        final bMinute = int.parse(bTime.split(':')[1].split(' ')[0]);

        return aMinute.compareTo(bMinute);
      });
    }
  }

  // Update an existing appointment (reschedule)
  Future<void> updateAppointment() async {
    if (_selectedAppointmentId == null) return;

    if (_startTime.hour >= _endTime.hour &&
        (_startTime.hour != _endTime.hour ||
            _startTime.minute >= _endTime.minute)) {
      // Show error: End time must be after start time
      setErrorMessage('End time must be after start time');
      return;
    }

    setIsBusy(true);
    setIsLoading(true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      final index = _scheduledAppointments
          .indexWhere((apt) => apt.id == _selectedAppointmentId);
      if (index != -1) {
        final appointment = _scheduledAppointments[index];
        _scheduledAppointments[index] = ScheduledAppointment(
          id: appointment.id,
          learnerName: appointment.learnerName,
          date: _selectedDate,
          startTime: formatTimeOfDay(_startTime),
          endTime: formatTimeOfDay(_endTime),
        );
      }

      // Reset form
      _showRescheduleForm = false;
      _selectedAppointmentId = null;

      // Update sample data
      final oldDateKey = _scheduledAppointments.isNotEmpty
          ? DateFormat('yyyy-MM-dd').format(_scheduledAppointments[index].date)
          : DateFormat('yyyy-MM-dd').format(_selectedDate);

      final newDateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);

      if (_sampleScheduledAppointments.containsKey(oldDateKey)) {
        final sampleIndex = _sampleScheduledAppointments[oldDateKey]!
            .indexWhere((apt) => apt.id == _selectedAppointmentId);

        if (sampleIndex != -1) {
          final appointment =
              _sampleScheduledAppointments[oldDateKey]![sampleIndex];

          // Remove from old date
          _sampleScheduledAppointments[oldDateKey]!.removeAt(sampleIndex);

          // Add to new date
          final updatedAppointment = ScheduledAppointment(
            id: appointment.id,
            learnerName: appointment.learnerName,
            date: _selectedDate,
            startTime: formatTimeOfDay(_startTime),
            endTime: formatTimeOfDay(_endTime),
          );

          if (_sampleScheduledAppointments.containsKey(newDateKey)) {
            _sampleScheduledAppointments[newDateKey]!.add(updatedAppointment);
          } else {
            _sampleScheduledAppointments[newDateKey] = [updatedAppointment];
          }
        }
      }
    } catch (e) {
      setErrorMessage('Failed to update appointment: $e');
    } finally {
      setIsBusy(false);
      setIsLoading(false);
    }
  }

  // Remove an available time slot
  Future<void> removeTimeSlot(String id) async {
    setIsBusy(true);
    setIsLoading(true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      _availableTimeSlots.removeWhere((slot) => slot.id == id);

      // Update sample data
      final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
      if (_sampleAvailableSlots.containsKey(dateKey)) {
        _sampleAvailableSlots[dateKey]!.removeWhere((slot) => slot.id == id);
      }
    } catch (e) {
      setErrorMessage('Failed to remove time slot: $e');
    } finally {
      setIsBusy(false);
      setIsLoading(false);
    }
  }

  // Postpone an appointment
  Future<void> postponeAppointment(String id) async {
    setIsBusy(true);
    setIsLoading(true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Find the appointment to get its date
      final appointment = _scheduledAppointments.firstWhere(
        (apt) => apt.id == id,
        orElse: () => _scheduledAppointments.first,
      );

      // For demo purposes, just remove the appointment
      _scheduledAppointments.removeWhere((apt) => apt.id == id);

      // Update sample data
      final dateKey = DateFormat('yyyy-MM-dd').format(appointment.date);
      if (_sampleScheduledAppointments.containsKey(dateKey)) {
        _sampleScheduledAppointments[dateKey]!
            .removeWhere((apt) => apt.id == id);
      }
    } catch (e) {
      setErrorMessage('Failed to postpone appointment: $e');
    } finally {
      setIsBusy(false);
      setIsLoading(false);
    }
  }

  // Fetch available time slots for the selected date
  Future<void> fetchAvailableTimeSlots() async {
    setIsBusy(true);
    setIsLoading(true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // Get sample data for the selected date
      final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);

      if (_sampleAvailableSlots.containsKey(dateKey)) {
        _availableTimeSlots = List.from(_sampleAvailableSlots[dateKey]!);
      } else {
        // Fallback to empty list if no data for the date
        _availableTimeSlots = [];
      }
    } catch (e) {
      setErrorMessage('Failed to fetch available time slots: $e');
      _availableTimeSlots = [];
    } finally {
      setIsBusy(false);
      setIsLoading(false);
    }
  }

  // Fetch scheduled appointments
  Future<void> fetchScheduledAppointments() async {
    setIsBusy(true);
    setIsLoading(true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // Get sample data for the selected date
      final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);

      if (_sampleScheduledAppointments.containsKey(dateKey)) {
        _scheduledAppointments =
            List.from(_sampleScheduledAppointments[dateKey]!);
      } else {
        // Fallback to empty list if no data for the date
        _scheduledAppointments = [];
      }
    } catch (e) {
      setErrorMessage('Failed to fetch scheduled appointments: $e');
      _scheduledAppointments = [];
    } finally {
      setIsBusy(false);
      setIsLoading(false);
    }
  }
}
