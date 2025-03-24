import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app_base_view_model.dart';
import 'package:code_bolanon/models/tech_stack_model.dart';
import 'package:code_bolanon/models/user_model.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:code_bolanon/services/appointment_service.dart';
import 'package:flutter/material.dart';

class LearnerAppointmentHomeViewModel extends AppBaseViewModel {
  final _apiService = locator<ApiService>();
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
      final availableTrainerIds =
          await _appointmentService.getAvailableTrainers();

      // Fetch full trainer details for these IDs
      final response = await _apiService.get('/trainers');
      final allTrainers = (response.data as List)
          .map((item) => UserModel.fromJson(item))
          .where((trainer) => availableTrainerIds.contains(trainer.id))
          .toList();

      if (_selectedTechStacks.isEmpty) {
        _availableTrainers = allTrainers;
      } else {
        _availableTrainers = allTrainers.where((trainer) {
          final trainerTechStacks = trainer.specialization?.split(',') ?? [];
          return _selectedTechStacks.any((selected) => trainerTechStacks.any(
              (stack) => stack.trim().toLowerCase() == selected.toLowerCase()));
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
    // TODO: Implement booking logic
    debugPrint('Booking session with trainer: $trainerId');
  }
}
