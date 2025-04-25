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
  List<UserModel> _unfilteredTrainers = []; // Keep original list
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
      _selectedTechStacks.clear();
    } else {
      _selectedTechStacks.clear();
      _selectedTechStacks.add(tag);
    }
    validateTechStack();
    _filterTrainers(); // Apply both search and tech stack filters
    notifyListeners();
  }

  bool isStackSelected(String tag) {
    return _selectedTechStacks.contains(tag);
  }

  Future<void> fetchAvailableTrainers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final trainers = await _appointmentService.getAvailableTrainers();
      _unfilteredTrainers = trainers;
      _availableTrainers = List.from(_unfilteredTrainers);
      _searchQuery = ''; // Reset search query
    } catch (e) {
      setError('Error fetching trainers: $e');
      debugPrint('Error fetching trainers: $e');
      _unfilteredTrainers = [];
      _availableTrainers = [];
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
    _searchQuery = query.toLowerCase().trim();
    _filterTrainers();
    notifyListeners();
  }

  void _filterTrainers() {
    if (_searchQuery.isEmpty) {
      // Reset to original list when search is empty
      _availableTrainers = List.from(_unfilteredTrainers);
    } else {
      // Filter by name
      _availableTrainers = _unfilteredTrainers.where((trainer) {
        return trainer.fullName.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Apply tech stack filter if needed
    if (_selectedTechStacks.isNotEmpty) {
      _availableTrainers = _availableTrainers.where((trainer) {
        return trainer.stacks?.any((stack) =>
                _selectedTechStacks.contains(stack.stack?.tags ?? "")) ??
            false;
      }).toList();
    }
  }

  void resetSearch() {
    _searchQuery = '';
    _availableTrainers = List.from(_unfilteredTrainers);
    notifyListeners();
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
    // Navigate to book appointment view and refresh on return
    await navigationService.navigateToLearnerBookAppointmentView(
        trainerId: trainerId);
    // Refresh the trainers list when returning from booking
    await fetchAvailableTrainers();
  }
}
