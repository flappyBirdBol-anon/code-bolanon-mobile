// lib/views/course_details/course_details_viewmodel.dart
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/models/course.dart';
import 'package:code_bolanon/models/lessons_model.dart';
import 'package:code_bolanon/services/auth_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/services/lesson_service.dart';
import 'package:code_bolanon/services/user_service.dart';
import 'package:code_bolanon/ui/views/add_lesson/add_lesson_view.dart';
import 'package:code_bolanon/ui/views/lessons_full/lessons_full_view.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class CourseDetailsViewModel extends ReactiveViewModel {
  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;
  final _userService = locator<UserService>();
  final _imageService = locator<ImageService>();
  final _lessonsService = locator<LessonsService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_lessonsService];

  // Filter lessons for this course
  List<Lesson> get courseLessons =>
      _lessonsService.lessons!.where((l) => l.courseId == course!.id).toList();

  String get profilePictureUrl => _userService.currentUser?.profileImage ?? '';
  String get userName => _userService.currentUser?.fullName ?? 'User';
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  notifyListeners();
  // Reference to the course
  Course? _course;
  Course? get course => _course;

  // Lessons for the course
  List<Lesson> _lessons = [];
  List<Lesson> get lessons => _lessons;

//for toggle lessons
  bool _showAllLessons = false;
  bool get showAllLessons => _showAllLessons;
  // Initialize with a course
  Future<void> initialize(Course? course) async {
    _course = course;
    setBusy(true);

    if (_course != null && _course!.thumbnail != null) {
      // Prefetch the course image to ensure it's cached
      final imageUrl =
          _imageService.getCourseThumbnailFromPath(_course!.thumbnail);
      await _imageService.prefetchImage(imageUrl, courseId: _course!.id);
    }

    // Load lessons
    await _loadLessons();

    _isLoading = false;
    setBusy(false);
    notifyListeners();
  }

  // Load lessons from the service
  Future<void> _loadLessons() async {
    try {
      _lessons = await _lessonsService.getLessons(courseId: course!.id);
      notifyListeners();
    } catch (e) {
      // Handle error
      await _dialogService.showDialog(
        title: 'Error Loading Lessons',
        description: 'Could not load lessons. Please try again later.',
      );
    }
  }

  // Refresh lessons
  Future<void> refreshLessons() async {
    setBusy(true);
    await _loadLessons();
    setBusy(false);
  }

  // Get a widget to display the course image
  Widget getCourseImageWidget({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (_course == null || _course!.thumbnail == null) {
      return errorWidget ?? _buildDefaultErrorWidget(width, height);
    }

    // Handle local assets differently
    if (_course!.thumbnail!.startsWith('assets/')) {
      return Image.asset(
        _course!.thumbnail,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildDefaultErrorWidget(width, height);
        },
      );
    }

    // Use ImageService for remote images
    final imageUrl =
        _imageService.getCourseThumbnailFromPath(_course!.thumbnail);

    return _imageService.loadImage(
      imageUrl: imageUrl,
      courseId: _course!.id,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder ?? _buildDefaultPlaceholder(width, height),
      errorWidget: errorWidget ?? _buildDefaultErrorWidget(width, height),
    );
  }

  Widget _buildDefaultPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildDefaultErrorWidget(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
    );
  }

  void setTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void navigateToAddLesson(Course course) {
    _navigationService.navigateTo(Routes.addLessonView, arguments: course);
  }

  void navigateToLessonsFullView() {
    _navigationService.navigateToView(
      LessonsFullView(
          courseId: _course?.id != null
              ? int.tryParse(_course!.id.toString()) ?? 0
              : 0),
    );
  }

  void navigateToLessonDetails(Lesson lesson) {
    _navigationService.navigateTo(
      Routes.lessonDetailsView,
      arguments: LessonDetailsViewArguments(lesson: lesson),
    );
  }

  void toggleShowAllLessons() {
    _showAllLessons = !_showAllLessons;
    notifyListeners();
  }

  // Delete a lesson
  Future<void> deleteLesson(Lesson lesson) async {
    final dialogResponse = await _dialogService.showConfirmationDialog(
      title: 'Delete Lesson',
      description: 'Are you sure you want to delete "${lesson.label}"?',
      confirmationTitle: 'Delete',
      cancelTitle: 'Cancel',
    );

    if (dialogResponse?.confirmed ?? false) {
      setBusy(true);
      try {
        final success = await _lessonsService.deleteLesson(lesson.id);
        if (success) {
          await refreshLessons();
          await _dialogService.showDialog(
            title: 'Success',
            description: 'Lesson deleted successfully',
          );
        }
      } catch (e) {
        await _dialogService.showDialog(
          title: 'Error',
          description: 'Failed to delete lesson: $e',
        );
      } finally {
        setBusy(false);
      }
    }
  }

  // Get total duration of all lessons
  String get totalDuration {
    if (_lessons.isEmpty) return '0 min';

    int totalMinutes = 0;
    for (var lesson in _lessons) {
      // Extract minutes from duration string (e.g., "12 min" -> 12)
      final durationStr = lesson.duration;
      final regex = RegExp(r'(\d+)');
      final match = regex.firstMatch(durationStr);
      if (match != null) {
        totalMinutes += int.tryParse(match.group(1) ?? '0') ?? 0;
      }
    }

    if (totalMinutes < 60) {
      return '$totalMinutes min';
    } else {
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      return '$hours h ${minutes > 0 ? '$minutes min' : ''}';
    }
  }
}
