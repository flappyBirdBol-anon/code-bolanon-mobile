import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/app/app_base_view_model.dart';
import 'package:code_bolanon/models/tech_stack_model.dart';
import 'package:code_bolanon/models/user_model.dart';
import 'package:code_bolanon/services/appointment_service.dart';
import 'package:flutter/material.dart';

class LearnerAppointmentHomeViewModel extends AppBaseViewModel {
  final _appointmentService = locator<AppointmentService>();

  List<UserModel> _availableTrainers = [];
  List<String> techStacks = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String? techStackError;

  List<UserModel> get availableTrainers => _availableTrainers;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;
  List<TechStackModel> get userTechStacks => userService.userTechStacks;

  Future<void> initialize() async {
    setBusy(true);
    try {
      // Fetch user tech stacks first
      await userService.fetchUserProfile();
      techStacks = userService.userTechStacks.map((e) => e.tags).toList();
      await fetchAvailableTrainers();
    } catch (e) {
      setError(e.toString());
    } finally {
      setBusy(false);
    }
  }

  final Set<String> _selectedTechStacks = {};
  List<String> get selectedTechStacks => _selectedTechStacks.toList();

  void toggleTechStack(String tag) {
    if (_selectedTechStacks.contains(tag)) {
      _selectedTechStacks.remove(tag);
    } else {
      _selectedTechStacks.add(tag);
    }
    validateTechStack();
    fetchAvailableTrainers(); // Refresh the list when tech stacks are toggled
    notifyListeners();
  }

  bool isStackSelected(String tag) {
    return _selectedTechStacks.contains(tag);
  }

  Future<void> fetchAvailableTrainers() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get available trainer IDs from AppointmentService
      final availableTrainers =
          await _appointmentService.getAvailableTrainers();

      if (_selectedTechStacks.isEmpty) {
        _availableTrainers = availableTrainers;
      } else {
        _availableTrainers = availableTrainers.where((trainer) {
          // Extract tech stack tags from each trainer
          final techStackTags = trainer.stacks
                  ?.map((selectedStack) =>
                      selectedStack.stack?.tags.toLowerCase() ?? "")
                  .where((tag) => tag.isNotEmpty)
                  .toList() ??
              [];

          // Check if any selected tech stack matches any trainer tech stack
          return _selectedTechStacks.any(
              (selected) => techStackTags.contains(selected.toLowerCase()));
        }).toList();
      }
    } catch (e) {
      setError('Error fetching trainers: $e');
      debugPrint('Error fetching trainers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void validateTechStack() {
    if (techStackError != null && _selectedTechStacks.isNotEmpty) {
      techStackError = null;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
    // TODO: Implement search filtering
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
    // TODO: Implement filter logic
  }

  void navigateToAppointments() {
    navigationService.navigateTo(Routes.learnerScheduleView);
  }

  Color getTechColor(String tech, bool isDark) {
    // Define colors for different tech stacks
    final colors = {
      'Flutter': const Color(0xFF02569B),
      'React Native': const Color(0xFF61DAFB),
      'iOS': const Color(0xFF000000),
      'Android': const Color(0xFF3DDC84),
      'React': const Color(0xFF61DAFB),
      'Vue.js': const Color(0xFF4FC08D),
      'Node.js': const Color(0xFF339933),
      'TypeScript': const Color(0xFF3178C6),
    };

    return colors[tech] ?? (isDark ? Colors.grey[700]! : Colors.grey[300]!);
  }

  Future<void> bookSession(int trainerId) async {
    navigationService.navigateToLearnerBookAppointmentView(
        trainerId: trainerId);
  }
}
