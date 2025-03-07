// lib/ui/views/lessons_full/lessons_full_viewmodel.dart
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/models/lessons_model.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/services/lesson_service.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class LessonsFullViewModel extends BaseViewModel {
  final _lessonsService = locator<LessonsService>();
  final _courseService = locator<CourseService>();
  final _imageService = locator<ImageService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();

  int _courseId = 0;
  CourseModel? _course;
  List<Lesson> _lessons = [];

  List<Lesson> get lessons => _lessons;
  String get courseName => _course?.title ?? 'Course Lessons';
  String get courseDescription =>
      _course?.description ?? 'No description available';
  String get courseRating => (_course?.rating ?? 0.0).toString();

  Future<void> initialize(int courseId) async {
    _courseId = courseId;
    setBusy(true);

    // Load course details
    await _loadCourseDetails();

    // Load lessons
    await _loadLessons();

    setBusy(false);
  }

  Future<void> _loadCourseDetails() async {
    try {
      if (_courseId > 0) {
        _course = await _courseService.getCourseById(_courseId);
      }
    } catch (e) {
      // Handle error
      await _dialogService.showDialog(
        title: 'Error Loading Course',
        description: 'Could not load course details. Please try again later.',
      );
    }
  }

  Future<void> _loadLessons() async {
    try {
      _lessons = await _lessonsService.getLessons();
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
    await _lessonsService.getLessons(forceRefresh: true);
    await _loadLessons();
    setBusy(false);
  }

  // Get course image widget
  Widget getCourseImageWidget({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (_course == null) {
      return _buildDefaultErrorWidget(width, height);
    }

    // Handle local assets differently
    if (_course!.thumbnail.startsWith('assets/')) {
      return Image.asset(
        _course!.thumbnail,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultErrorWidget(width, height);
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
      placeholder: _buildDefaultPlaceholder(width, height),
      errorWidget: _buildDefaultErrorWidget(width, height),
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

  // Navigation methods
  void navigateToAddLesson() {
    _navigationService.navigateTo(Routes.addLessonView);
  }

  void navigateToLessonDetails(Lesson lesson) {
    _navigationService.navigateTo(
      Routes.lessonDetailsView,
      arguments: lesson,
    );
  }

  void navigateToEditLesson(Lesson lesson) {
    _navigationService.navigateTo(
      Routes.addLessonView,
      arguments: lesson,
    );
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

  // Download lesson
  Future<void> downloadLesson(Lesson lesson) async {
    try {
      setBusy(true);

      // Show a dialog to indicate download is starting
      await _dialogService.showDialog(
        title: 'Downloading',
        description: 'Starting download for ${lesson.label}...',
      );

      // Here you would implement the actual download logic
      // For now, we'll just simulate a download
      await Future.delayed(const Duration(seconds: 2));

      await _dialogService.showDialog(
        title: 'Download Complete',
        description: '${lesson.label} has been downloaded successfully.',
      );
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Download Failed',
        description: 'Could not download the lesson: $e',
      );
    } finally {
      setBusy(false);
    }
  }

  // Share lesson
  Future<void> shareLesson(Lesson lesson) async {
    try {
      final String shareText =
          'Check out this lesson: ${lesson.label}\n${lesson.fileUrl}';
      await Share.share(shareText);
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Share Failed',
        description: 'Could not share the lesson: $e',
      );
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
