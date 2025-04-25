import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/app/app_base_view_model.dart';
import 'package:code_bolanon/models/appointment_model.dart';
import 'package:code_bolanon/services/appointment_service.dart';
import 'package:url_launcher/url_launcher.dart';

class LearnerScheduleViewModel extends AppBaseViewModel {
  final _appointmentService = locator<AppointmentService>();

  final List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  String _selectedFilter = 'Today';

  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String get selectedFilter => _selectedFilter;

  // Filtered appointments based on selected filter
  List<AppointmentModel> get filteredAppointments {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedFilter) {
      case 'Today':
        return _appointments.where((appointment) {
          final appointmentDate = DateTime(appointment.startAt.year,
              appointment.startAt.month, appointment.startAt.day);
          return appointmentDate.isAtSameMomentAs(today) &&
              appointment.status.toLowerCase() != 'completed';
        }).toList();

      case 'Upcoming':
        return _appointments.where((appointment) {
          final appointmentDate = DateTime(appointment.startAt.year,
              appointment.startAt.month, appointment.startAt.day);
          return appointmentDate.isAfter(today) &&
              appointment.status.toLowerCase() != 'completed';
        }).toList();

      case 'Completed':
        return _appointments
            .where((appointment) =>
                appointment.status.toLowerCase() == 'completed')
            .toList();

      default:
        return _appointments;
    }
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      await userService.fetchUserProfile();
      await fetchAppointments();
    } catch (e) {
      setError(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<void> fetchAppointments() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedAppointments =
          await _appointmentService.fetchAllAppointments();

      // Clear the current appointments list
      _appointments.clear();

      // Filter appointments for current user
      final currentUserId = userService.currentUser?.id;

      if (currentUserId != null) {
        final filteredAppointments = fetchedAppointments
            .where((appointment) =>
                appointment.learnerId == currentUserId &&
                appointment.status.toLowerCase() != 'available')
            .toList();

        _appointments.addAll(filteredAppointments);

        // Sort appointments by date (nearest first)
        _appointments.sort((a, b) => a.startAt.compareTo(b.startAt));
      }
    } catch (e) {
      setError('Error fetching your appointments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> viewAppointmentDetails(int appointmentId) async {
    navigationService.navigateToAppointmentDetailsView(
        appointmentId: appointmentId.toString());
  }

  Future<void> launchGoogleMeet(String? meetLink) async {
    if (meetLink == null || meetLink.isEmpty) {
      snackbarService.showSnackbar(
        message: 'No Google Meet link available for this appointment',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      final Uri url = Uri.parse(meetLink);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        snackbarService.showSnackbar(
          message: 'Could not launch Google Meet',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      setError('Error launching Google Meet: $e');
    }
  }
}
