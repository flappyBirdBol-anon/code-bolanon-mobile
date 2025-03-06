import 'package:code_bolanon/models/course.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/ui/views/course_details/course_details_view.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class AvailableCoursesViewModel extends BaseViewModel {
  final CourseService _courseService;
  final ImageService _imageService;

  List<Course> _allCourses = [];
  List<Course> _filteredCourses = [];
  final Set<String> _activeFilters = {};
  String _searchQuery = '';

  List<Course> get filteredCourses => _filteredCourses;
  Set<String> get activeFilters => _activeFilters;
  ImageService get imageService => _imageService;

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

  AvailableCoursesViewModel({
    required CourseService courseService,
    required ImageService imageService,
  })  : _courseService = courseService,
        _imageService = imageService {
    _loadInitialData();
  }

  void _loadInitialData() {
    setBusy(true);
    _allCourses = [];
    _filteredCourses = [];
    setBusy(false);
    notifyListeners();
  }

  Future<void> init() async {
    await refreshCourses();
  }

  Future<void> refreshCourses() async {
    setBusy(true);
    try {
      _allCourses = await _courseService.getCourses();
      _filteredCourses = List.from(_allCourses);
      _applyFilters();
    } catch (e) {
      debugPrint('Error refreshing courses: $e');
      _allCourses = [];
      _filteredCourses = [];
    } finally {
      setBusy(false);
    }
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
        if (_activeFilters.contains('Free') && course.price > 0) return false;
        if (_activeFilters.contains('Premium') && course.price == 0)
          return false;
      }

      return true;
    }).toList();

    // Apply sorting
    if (_activeFilters.contains('Most Popular')) {
      _filteredCourses
          .sort((a, b) => b.studentsEnrolled.compareTo(a.studentsEnrolled));
    } else if (_activeFilters.contains('Highest Rated')) {
      _filteredCourses.sort((a, b) => b.rating.compareTo(a.rating));
    }

    notifyListeners();
  }

  Widget getCourseImageWidget({
    required Course course,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    // Handle local assets differently
    if (course.thumbnail.startsWith('assets/')) {
      return Image.asset(
        course.thumbnail,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildDefaultErrorWidget(width, height);
        },
      );
    }

    // If it's a remote image, use the ImageService
    if (course.thumbnail.isNotEmpty) {
      final imageUrl =
          _imageService.getCourseThumbnailFromPath(course.thumbnail);

      return _imageService.loadImage(
        imageUrl: imageUrl,
        courseId: course.id,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder,
        errorWidget: errorWidget,
      );
    }

    // If no image path, return error widget
    return errorWidget ?? _buildDefaultErrorWidget(width, height);
  }

  Widget _buildDefaultErrorWidget(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
    );
  }

  void navigateToMyCourses() {
    // Implement navigation to enrolled courses
  }
  void navigateToCourseDetails(BuildContext context, Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailsView(course: course),
      ),
    );
  }
}
