import 'package:stacked/stacked.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String instructorName;
  final String instructorAvatar;
  final double rating;
  final int reviewsCount;
  final int enrolledCount;
  final double price;
  final List<String> categories;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.instructorName,
    required this.instructorAvatar,
    required this.rating,
    required this.reviewsCount,
    required this.enrolledCount,
    required this.price,
    required this.categories,
  });
}

class AvailableCoursesViewModel extends BaseViewModel {
  List<Course> _allCourses = [];
  List<Course> _filteredCourses = [];
  final Set<String> _activeFilters = {};
  String _searchQuery = '';

  List<Course> get filteredCourses => _filteredCourses;
  Set<String> get activeFilters => _activeFilters;
  List<String> get availableFilters => [
        'Free',
        'Premium',
        'Programming',
        'Design',
        'Business',
        'Marketing',
        'Most Popular',
        'Highest Rated',
      ];

  AvailableCoursesViewModel() {
    _loadInitialData();
  }

  void _loadInitialData() {
    _allCourses = [
      Course(
        id: '1',
        title: 'Flutter Complete Development Course',
        description:
            'Learn Flutter from basics to advanced. Build real-world applications with clean architecture.',
        thumbnailUrl: 'assets/images/1.jpg',
        instructorName: 'John Doe',
        instructorAvatar: 'assets/images/profile.jpg',
        rating: 4.8,
        reviewsCount: 1250,
        enrolledCount: 15000,
        price: 89.99,
        categories: ['Programming', 'Premium'],
      ),
      Course(
        id: '2',
        title: 'UI/UX Design Fundamentals',
        description:
            'Master the principles of modern UI/UX design with practical projects.',
        thumbnailUrl: 'assets/images/2.jpg',
        instructorName: 'Jane Smith',
        instructorAvatar: 'assets/images/profile.jpg',
        rating: 4.9,
        reviewsCount: 850,
        enrolledCount: 8500,
        price: 0,
        categories: ['Design', 'Free'],
      ),
      // Add more sample courses as needed
    ];
    _filteredCourses = List.from(_allCourses);
    notifyListeners();
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void toggleFilter(String filter) {
    if (_activeFilters.contains(filter)) {
      _activeFilters.remove(filter);
    } else {
      _activeFilters.add(filter);
    }
    _applyFilters();
    notifyListeners();
  }

  void removeFilter(String filter) {
    _activeFilters.remove(filter);
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredCourses = _allCourses.where((course) {
      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase();
        if (!course.title.toLowerCase().contains(searchLower) &&
            !course.description.toLowerCase().contains(searchLower)) {
          return false;
        }
      }

      // Apply category filters
      if (_activeFilters.isNotEmpty) {
        return course.categories
                .any((category) => _activeFilters.contains(category)) ||
            (_activeFilters.contains('Free') && course.price == 0) ||
            (_activeFilters.contains('Premium') && course.price > 0);
      }

      return true;
    }).toList();

    // Apply sorting
    if (_activeFilters.contains('Most Popular')) {
      _filteredCourses
          .sort((a, b) => b.enrolledCount.compareTo(a.enrolledCount));
    } else if (_activeFilters.contains('Highest Rated')) {
      _filteredCourses.sort((a, b) => b.rating.compareTo(a.rating));
    }

    notifyListeners();
  }

  Future<void> refreshCourses() async {
    // Implement actual API call here
    await Future.delayed(const Duration(seconds: 1));
    _loadInitialData();
  }

  void navigateToMyCourses() {
    // Implement navigation to my courses
  }
}
