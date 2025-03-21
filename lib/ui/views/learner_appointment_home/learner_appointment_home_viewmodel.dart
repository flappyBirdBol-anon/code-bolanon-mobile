import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/user_model.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class LearnerAppointmentHomeViewModel extends BaseViewModel {
  final _apiService = locator<ApiService>();
  List<UserModel> _availableTrainers = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  List<UserModel> get availableTrainers => _availableTrainers;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;

  Future<void> initialize() async {
    await fetchAvailableTrainers();
  }

  Future<void> fetchAvailableTrainers() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Replace with actual API call
      // For now, using mock data
      await Future.delayed(const Duration(seconds: 1));
      _availableTrainers = [
        UserModel(
          id: 1,
          firstName: 'John',
          lastName: 'Doe',
          email: 'john.doe@example.com',
          role: 'trainer',
          profileImage: '',
          specialization: 'Mobile Development',
          organization: 'Tech Corp',
        ),
        UserModel(
          id: 2,
          firstName: 'Jane',
          lastName: 'Smith',
          email: 'jane.smith@example.com',
          role: 'trainer',
          profileImage: '',
          specialization: 'Web Development',
          organization: 'Web Solutions',
        ),
      ];
    } catch (e) {
      // Handle error
      debugPrint('Error fetching trainers: $e');
    } finally {
      _isLoading = false;
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
