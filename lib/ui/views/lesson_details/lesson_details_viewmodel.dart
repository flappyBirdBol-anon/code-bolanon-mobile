import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/models/lessons_model.dart';
import 'package:code_bolanon/services/file_service.dart';
import 'package:code_bolanon/services/lesson_service.dart';
import 'package:code_bolanon/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class LessonDetailsViewModel extends BaseViewModel {
  final _lessonsService = locator<LessonsService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _fileService = locator<FileService>();
  final _userService = locator<UserService>();

  Lesson? _lesson;
  final fileService = locator<FileService>();

  // Lesson state
  Lesson get lesson => _lesson ?? _createEmptyLesson();
  set lesson(Lesson value) => _lesson = value;
  bool _hasValidLesson = false;
  bool get hasValidLesson => _hasValidLesson;

  // File state
  bool _isFileCached = false;
  bool get isFileCached => _isFileCached;
  String _fileSize = 'Unknown size';
  String get fileSize => _fileSize;
  bool _isFileDownloadable = false;
  bool get isFileDownloadable => _isFileDownloadable;
  bool _isFileLoading = false;
  bool get isFileLoading => _isFileLoading;
  bool _hasFileError = false;
  bool get hasFileError => _hasFileError;
  String? _fileErrorMessage;
  String? get fileErrorMessage => _fileErrorMessage;
  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;
  double _downloadProgress = 0.0;
  double get downloadProgress => _downloadProgress;
  bool _canPlayFile = false;
  bool get canPlayFile => _canPlayFile;

  // UI state
  bool _isFullScreen = false;
  bool get isFullScreen => _isFullScreen;
  bool _isLessonCompleted = false;
  bool get isLessonCompleted => _isLessonCompleted;
  bool get isLearner => _userService.currentUser?.role == 'learner';
  bool get showCompletionToggle => isLearner;

  Lesson _createEmptyLesson() {
    return Lesson(
      id: 1,
      courseId: 1,
      label: 'No Lesson Available',
      description: '',
      fileUrl: '',
      fileType: 'unknown',
      fileName: 'No file',
      duration: '0:00',
    );
  }

  Future<void> initialize(Lesson? initialLesson) async {
    try {
      setBusy(true);

      if (initialLesson != null) {
        _lesson = initialLesson;
        _hasValidLesson = true;
      } else if (_navigationService.currentArguments is Lesson) {
        _lesson = _navigationService.currentArguments as Lesson;
        _hasValidLesson = true;
      } else if (_lessonsService.currentLesson != null) {
        _lesson = _lessonsService.currentLesson!;
        _hasValidLesson = true;
      } else {
        _hasValidLesson = false;
        _lesson = _createEmptyLesson();
        Future.microtask(() async {
          await _dialogService.showDialog(
            title: 'Error',
            description: 'No lesson data available',
          );
          _navigationService.back();
        });
        setBusy(false);
        return;
      }

      notifyListeners();

      if (_fileService.hasFile(lesson)) {
        _isFileCached = await _fileService.isFileCached(lesson);
        if (!_isFileCached) {
          try {
            await _fileService.prefetchFile(
              _fileService.getLessonFileUrl(lesson),
              lessonId: lesson.id.toString(),
              fileName: lesson.fileName,
            );
            _isFileCached = true;
          } catch (e) {
            print('Silent prefetch failed: $e');
          }
        }
      }

      final updatedLesson = await _lessonsService.getLesson(_lesson!.id);
      if (updatedLesson != null) {
        _lesson = updatedLesson;
      }

      await _checkFileStatus();
      _determineFilePlayability();

      _isLessonCompleted = false; // Default to false for now
    } catch (e) {
      print('Error initializing lesson details: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<void> _checkFileStatus() async {
    if (!_hasValidLesson) return;

    try {
      if (_fileService.hasFile(lesson)) {
        _isFileCached = await _fileService.isFileCached(lesson);
        _fileSize = await _fileService.getFileSize(lesson);
        _isFileDownloadable = await _fileService.isFileDownloadable(lesson);
      } else {
        _isFileCached = false;
        _fileSize = 'No file';
        _isFileDownloadable = false;
      }

      _hasFileError = false;
      _fileErrorMessage = null;
    } catch (e) {
      print('Error checking file status: $e');
      _isFileCached = false;
      _fileSize = 'Unknown size';
      _isFileDownloadable = false;
      _hasFileError = true;
      _fileErrorMessage = 'Could not determine file status: $e';
    }

    notifyListeners();
  }

  void _determineFilePlayability() {
    if (!_hasValidLesson || !_fileService.hasFile(lesson)) {
      _canPlayFile = false;
      return;
    }

    final fileType =
        lesson.fileType ?? _fileService.getFileType(lesson.fileName ?? '');
    _canPlayFile = fileType.contains('video') ||
        fileType.contains('audio') ||
        fileType.contains('pdf');
    notifyListeners();
  }

  void toggleFullScreen() {
    _isFullScreen = !_isFullScreen;

    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    notifyListeners();
  }

  void onFileOpened() {
    // Handle any necessary state updates when file is opened
    print('File opened successfully');
  }

  void onFileDownloaded() {
    // Handle any necessary state updates when file is downloaded
    print('File downloaded successfully');
  }

  Future<void> playLesson() async {
    if (!_hasValidLesson || !_fileService.hasFile(lesson)) {
      await _showNoFileDialog();
      return;
    }

    try {
      final result = await _fileService.openLessonFile(lesson);
      if (result.type != ResultType.done) {
        await _dialogService.showDialog(
          title: 'Cannot Play Lesson',
          description: 'Unable to open the lesson file: ${result.message}',
        );
      }
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to play lesson: $e',
      );
    }
  }

  Future<void> shareLesson() async {
    if (!_hasValidLesson || !_fileService.hasFile(lesson)) {
      await _showNoFileDialog();
      return;
    }

    try {
      final shareText =
          'Check out this lesson: ${lesson.label}\n${lesson.fileUrl ?? ""}';
      await Share.share(shareText);
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Share Failed',
        description: 'Could not share the lesson: $e',
      );
    }
  }

  void editLesson() {
    if (!_hasValidLesson) return;
    _navigationService.navigateTo(Routes.addLessonView, arguments: lesson);
  }

  Future<void> deleteLesson() async {
    if (!_hasValidLesson) return;

    final dialogResponse = await _dialogService.showConfirmationDialog(
      title: 'Delete Lesson',
      description:
          'Are you sure you want to delete "${lesson.label}"? This action cannot be undone.',
      confirmationTitle: 'Delete',
      cancelTitle: 'Cancel',
    );

    if (dialogResponse?.confirmed ?? false) {
      setBusy(true);
      try {
        final success = await _lessonsService.deleteLesson(lesson.id);
        if (success) {
          await _dialogService.showDialog(
            title: 'Success',
            description: 'Lesson has been deleted successfully.',
          );
          _navigationService.back();
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

  void toggleLessonCompletion() {
    if (!isLearner) return;
    _isLessonCompleted = !_isLessonCompleted;
    notifyListeners();
  }

  Widget getFileTypeIconWidget({double size = 24, Color? color}) {
    return _fileService.getFileTypeIcon(lesson, size: size, color: color);
  }

  Future<void> _showNoFileDialog() async {
    await _dialogService.showDialog(
      title: 'No File Available',
      description: 'This lesson does not have an associated file.',
    );
  }

  void navigateBack() {
    if (_isFullScreen) {
      toggleFullScreen();
    } else {
      _navigationService.back();
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
}
