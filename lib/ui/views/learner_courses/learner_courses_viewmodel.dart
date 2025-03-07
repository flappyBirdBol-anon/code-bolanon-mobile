import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/app/app_base_view_model.dart';
import 'package:code_bolanon/models/completed_lessons.dart';
import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/models/registration_model.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/ui/common/widgets/images/png_images.dart';
import 'package:flutter/material.dart';

class LearnerCoursesViewModel extends AppBaseViewModel {
  final CourseService _courseService;
  final ImageService _imageService;

  List<CourseModel> _myCourses = [];
  List<CourseModel> _filteredCourses = [];
  String _selectedFilter = 'All';

  List<CourseModel> get filteredCourses => _filteredCourses;
  String get selectedFilter => _selectedFilter;
  ImageService get imageService => _imageService;

  List<String> get availableFilters => [
        'All',
        'Free',
        'Premium',
      ];

  List<CourseModel> _registeredCourses = [];
  List<CourseModel> get registeredCourses => _registeredCourses;

  LearnerCoursesViewModel({
    required CourseService courseService,
    required ImageService imageService,
  })  : _courseService = courseService,
        _imageService = imageService {
    _loadInitialData();
  }

  void _loadInitialData() {
    setBusy(true);
    // Sample data until endpoint is ready
    _myCourses = [
      CourseModel(
        id: "1",
        title: "Sample Course 1",
        price: 0,
        description: "Free course description",
        thumbnail: PngImages.image1,
        lessons: 10,
        registration: RegistrationModel(
          id: 1,
          courseId: 1,
          userId: 1,
          isReported: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          completedLessons: CompletedLessons(
            id: 1,
            isCompleted: true,
            lessonId: 1,
            registrationId: 1,
          ),
        ),
      ),
      CourseModel(
        id: "2",
        title: "Premium Course 1",
        price: 29.99,
        description: "Premium course description",
        thumbnail: PngImages.image2,
        lessons: 15,
        registration: RegistrationModel(
          id: 2,
          courseId: 2,
          userId: 1,
          isReported: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          completedLessons: CompletedLessons(
            id: 2,
            isCompleted: false,
            lessonId: 1,
            registrationId: 2,
          ),
        ),
      ),
    ];
    _filterCourses(_selectedFilter);
    setBusy(false);
    notifyListeners();
  }

  double calculateProgress(CourseModel course) {
    if (course.registration?.completedLessons == null) return 0.0;

    final completedLessons = course.registration!.completedLessons!;
    return completedLessons.isCompleted ? 1.0 / course.lessons : 0.0;
  }

  Future<void> init() async {
    await refreshCourses();
  }

  Future<void> refreshCourses() async {
    setBusy(true);
    try {
      final registrations = await _courseService.getUserRegistrations();
      _registeredCourses =
          await _courseService.getRegisteredCourses(registrations);
      _filterCourses(_selectedFilter);
    } catch (e) {
      debugPrint('Error refreshing courses: $e');
      _registeredCourses = [];
      _filteredCourses = _myCourses;
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  void setFilter(String filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      _filterCourses(filter);
      notifyListeners();
    }
  }

  void _filterCourses(String filter) {
    switch (filter) {
      case 'Free':
        _filteredCourses =
            _myCourses.where((course) => course.price == 0).toList();
        break;
      case 'Premium':
        _filteredCourses =
            _myCourses.where((course) => course.price > 0).toList();
        break;
      default:
        _filteredCourses = _myCourses;
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }

  double computeProgress(CourseModel course) {
    if (course.registration?.completedLessons == null) return 0.0;
    if (course.lessons == 0) return 0.0;

    final completedLessons = course.registration!.completedLessons!;
    return completedLessons.isCompleted ? 1.0 / course.lessons : 0.0;
  }

  @override
  notifyListeners();

  Widget getCourseImageWidget({
    required CourseModel
        course, // Changed from RegistrationModel to CourseModel
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

  void navigateToWishlist() {
    navigationService.navigateTo(Routes.learnerWishlistsView);
  }
}
