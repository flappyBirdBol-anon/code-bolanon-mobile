import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app_base_view_model.dart';
import 'package:code_bolanon/models/appointment_model.dart';
import 'package:code_bolanon/services/appointment_service.dart';
import 'package:code_bolanon/ui/common/enums/enums.dart';
import 'package:flutter/material.dart';

class RescheduleAppointmentViewModel extends AppBaseViewModel {
  final _appointmentService = locator<AppointmentService>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay get startTime => _startTime;

  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay get endTime => _endTime;

  double _price = 500.0;
  double get price => _price;

  bool _hasChanges = false;
  bool get hasChanges => _hasChanges;

  AppointmentModel? _originalAppointment;
  bool _isEdit = false;

  Future<void> initialize(String appointmentId, bool isEdit) async {
    _isEdit = isEdit;
    await _loadAppointment(appointmentId);
  }

  Future<void> _loadAppointment(String appointmentId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final appointment =
          await _appointmentService.getAppointment(appointmentId);
      _originalAppointment = appointment;

      // Set initial values from appointment
      _selectedDate = appointment.startAt;
      _startTime = TimeOfDay(
          hour: appointment.startAt.hour, minute: appointment.startAt.minute);
      _endTime = TimeOfDay(
          hour: appointment.endAt.hour, minute: appointment.endAt.minute);
      _price = appointment.price;
      _hasChanges = false;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load appointment details';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _checkForChanges();
    notifyListeners();
  }

  void setStartTime(TimeOfDay time) {
    _startTime = time;
    _checkForChanges();
    notifyListeners();
  }

  void setEndTime(TimeOfDay time) {
    _endTime = time;
    _checkForChanges();
    notifyListeners();
  }

  void setPrice(double value) {
    _price = value;
    _checkForChanges();
    notifyListeners();
  }

  void _checkForChanges() {
    if (_originalAppointment != null) {
      final newStart = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime.hour,
        _startTime.minute,
      );
      final newEnd = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      _hasChanges = newStart != _originalAppointment!.startAt ||
          newEnd != _originalAppointment!.endAt ||
          (_isEdit && _price != _originalAppointment!.price);
      notifyListeners();
    }
  }

  bool _validateTimes() {
    if (_startTime.hour >= _endTime.hour &&
        (_startTime.hour != _endTime.hour ||
            _startTime.minute >= _endTime.minute)) {
      _errorMessage = 'End time must be after start time';
      notifyListeners();
      return false;
    }
    return true;
  }

  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<Map<String, dynamic>> updateAppointment() async {
    if (!_validateTimes())
      return {'success': false, 'message': 'Invalid time range'};
    if (!_hasChanges) {
      snackbarService.showCustomSnackBar(
        message: 'No changes have been made',
        duration: const Duration(seconds: 3),
        variant: SnackbarType.error,
      );
      return {'success': false, 'message': 'No changes made'};
    }

    _isLoading = true;
    notifyListeners();

    try {
      final updatedAppointment = AppointmentModel(
        id: _originalAppointment!.id,
        startAt: DateTime(_selectedDate.year, _selectedDate.month,
            _selectedDate.day, _startTime.hour, _startTime.minute),
        endAt: DateTime(_selectedDate.year, _selectedDate.month,
            _selectedDate.day, _endTime.hour, _endTime.minute),
        price: _isEdit ? _price : _originalAppointment!.price,
        contextDetails: _originalAppointment!.contextDetails,
        status: _originalAppointment!.status,
        trainerId: _originalAppointment!.trainerId,
        gmeetLink: _originalAppointment!.gmeetLink,
        trainer: _originalAppointment!.trainer,
      );

      final result = await _appointmentService.updateSchedule(
        _originalAppointment!.id.toString(),
        updatedAppointment,
      );

      if (result['success']) {
        snackbarService.showCustomSnackBar(
          message: result['message'],
          duration: const Duration(seconds: 3),
          variant: SnackbarType.success,
        );
        return {'success': true, 'message': result['message']};
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return {'success': false, 'message': result['message']};
      }
    } catch (e) {
      _errorMessage = 'Failed to update schedule';
      notifyListeners();
      return {'success': false, 'message': 'Failed to update schedule'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
