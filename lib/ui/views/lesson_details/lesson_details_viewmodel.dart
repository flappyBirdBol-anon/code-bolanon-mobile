import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/models/lessons_model.dart';
import 'package:code_bolanon/services/lesson_service.dart';
import 'package:code_bolanon/services/file_service.dart';

import 'package:flutter/material.dart';
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

  Lesson? _lesson;
  final fileService = locator<FileService>();

  Lesson get lesson => _lesson ?? _createEmptyLesson();

  set lesson(Lesson value) => _lesson = value;

  bool _hasValidLesson = false;
  bool get hasValidLesson => _hasValidLesson;

  bool _isFileCached = false;
  bool get isFileCached => _isFileCached;

  String _fileSize = 'Unknown size';
  String get fileSize => _fileSize;

  bool _isFileDownloadable = false;
  bool get isFileDownloadable => _isFileDownloadable;

  // File viewing experience properties
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

      // Determine the lesson source with priority order
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

        // Show error dialog and navigate back after a short delay
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

      // Notify UI of initial state
      notifyListeners();

      // Check if the lesson has a file and prefetch if needed
      if (_fileService.hasFile(lesson)) {
        // Check if file is already cached
        _isFileCached = await _fileService.isFileCached(lesson);

        // Silent prefetch attempt if not cached
        if (!_isFileCached) {
          try {
            await _fileService.prefetchFile(
              _fileService.getLessonFileUrl(lesson),
              lessonId: lesson.id.toString(),
              fileName: lesson.fileName,
            );
            _isFileCached = true;
          } catch (e) {
            // Just log the error, don't show to user for silent prefetch
            print('Silent prefetch failed: $e');
          }
        }
      }

      // Get updated lesson data from service
      final updatedLesson = await _lessonsService.getLesson(_lesson!.id);
      if (updatedLesson != null) {
        _lesson = updatedLesson;
      }

      // Update file status and playability
      await _checkFileStatus();
      _determineFilePlayability();
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

    // Files that can be "played"
    _canPlayFile = fileType.contains('video') ||
        fileType.contains('audio') ||
        fileType.contains('pdf');

    notifyListeners();
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

  Future<void> openLesson() async {
    if (!_hasValidLesson || !_fileService.hasFile(lesson)) {
      await _showNoFileDialog();
      return;
    }

    if (_isFileLoading) {
      // Prevent multiple attempts
      return;
    }

    try {
      _isFileLoading = true;
      _hasFileError = false;
      notifyListeners();

      // Check if file is cached first
      if (!_isFileCached) {
        // Try to download the file first
        final shouldDownload = await _dialogService.showConfirmationDialog(
          title: 'File Not Downloaded',
          description:
              'This file needs to be downloaded before it can be opened. Download now?',
          confirmationTitle: 'Download',
          cancelTitle: 'Cancel',
        );

        if (shouldDownload?.confirmed ?? false) {
          await prefetchLessonFile();

          // If download failed, don't try to open
          if (_hasFileError) {
            _isFileLoading = false;
            notifyListeners();
            return;
          }
        } else {
          // User canceled download
          _isFileLoading = false;
          notifyListeners();
          return;
        }
      }

      final result = await _fileService.openLessonFile(lesson);

      if (result.type != ResultType.done) {
        _hasFileError = true;
        _fileErrorMessage = result.message;

        await _dialogService.showDialog(
          title: 'Cannot Open File',
          description: 'Unable to open the lesson file: ${result.message}',
        );
      }
    } catch (e) {
      _hasFileError = true;
      _fileErrorMessage = e.toString();

      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to open lesson: $e',
      );
    } finally {
      _isFileLoading = false;
      notifyListeners();
    }
  }

  Future<void> downloadLesson() async {
    if (!_hasValidLesson || !_fileService.hasFile(lesson)) {
      await _showNoFileDialog();
      return;
    }

    if (_isDownloading) {
      // Already downloading
      return;
    }

    try {
      _isDownloading = true;
      _downloadProgress = 0.0;
      notifyListeners();

      // Download the file
      final downloadedFile = await _fileService.downloadFile(lesson);

      if (downloadedFile != null) {
        _isFileCached = true;
        _hasFileError = false;
        _fileErrorMessage = null;

        await _dialogService.showDialog(
          title: 'Download Complete',
          description: '${lesson.label} has been downloaded successfully.',
        );

        await _checkFileStatus();
      } else {
        _hasFileError = true;
        _fileErrorMessage = 'Download failed for unknown reason';

        await _dialogService.showDialog(
          title: 'Download Failed',
          description: 'Could not download the lesson file.',
        );
      }
    } catch (e) {
      _hasFileError = true;
      _fileErrorMessage = e.toString();

      await _dialogService.showDialog(
        title: 'Download Failed',
        description: 'Could not download the lesson: $e',
      );
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  Future<void> shareLesson() async {
    if (!_hasValidLesson) return;

    try {
      if (_fileService.hasFile(lesson)) {
        final cachedFile = await _fileService
            .getCachedFile(_fileService.getLessonFileUrl(lesson));

        if (cachedFile != null) {
          await Share.shareXFiles(
            [XFile(cachedFile.path)],
            text: 'Check out this lesson: ${lesson.label}',
          );
          return;
        }
      }

      final String shareText =
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

    _navigationService.navigateTo(
      Routes.addLessonView,
      arguments: lesson,
    );
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
          await _fileService.clearLessonCache(lesson.id.toString());

          await _dialogService.showDialog(
            title: 'Success',
            description: 'Lesson deleted successfully',
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

  Future<void> prefetchLessonFile() async {
    if (!_hasValidLesson || !_fileService.hasFile(lesson)) {
      await _showNoFileDialog();
      return;
    }

    if (_isDownloading) {
      // Already downloading
      return;
    }

    try {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _hasFileError = false;
      notifyListeners();

      // Call the prefetch method
      final file = await _fileService.prefetchFile(
        _fileService.getLessonFileUrl(lesson),
        lessonId: lesson.id.toString(),
        fileName: lesson.fileName,
      );

      _isFileCached = true;
      await _checkFileStatus();

      // Show success message
      await _dialogService.showDialog(
        title: 'Download Complete',
        description: '${lesson.label} has been downloaded successfully.',
      );
    } catch (e) {
      print('Error prefetching lesson file: $e');
      _hasFileError = true;
      _fileErrorMessage = e.toString();

      // Show error message
      await _dialogService.showDialog(
        title: 'Download Failed',
        description: 'Could not download the lesson: ${e.toString()}',
      );
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  // Helper method to get file type icon and color
  Widget getFileTypeIconWidget({double size = 24, Color? color}) {
    return _fileService.getFileTypeIcon(
      lesson,
      size: size,
      color: color,
    );
  }

  IconData getFileIconData() {
    if (lesson.fileName == null || lesson.fileName!.isEmpty) {
      return Icons.insert_drive_file;
    }

    final extension = path.extension(lesson.fileName!).toLowerCase();

    if (extension == '.pdf') {
      return Icons.picture_as_pdf_rounded;
    } else if (extension == '.doc' || extension == '.docx') {
      return Icons.description_rounded;
    } else if (extension == '.xls' || extension == '.xlsx') {
      return Icons.table_chart_rounded;
    } else if (extension == '.ppt' || extension == '.pptx') {
      return Icons.slideshow_rounded;
    } else if (extension == '.txt') {
      return Icons.text_snippet_rounded;
    } else if (extension == '.jpg' ||
        extension == '.jpeg' ||
        extension == '.png' ||
        extension == '.gif') {
      return Icons.image_rounded;
    } else if (extension == '.mp4' ||
        extension == '.avi' ||
        extension == '.mov' ||
        extension == '.wmv') {
      return Icons.videocam_rounded;
    } else if (extension == '.mp3' ||
        extension == '.wav' ||
        extension == '.ogg' ||
        extension == '.m4a') {
      return Icons.audiotrack_rounded;
    }

    return Icons.insert_drive_file_rounded;
  }

  Color getFileIconColor() {
    if (lesson.fileName == null || lesson.fileName!.isEmpty) {
      return Colors.grey;
    }

    final extension = path.extension(lesson.fileName!).toLowerCase();

    if (extension == '.pdf') {
      return Colors.red;
    } else if (extension == '.doc' || extension == '.docx') {
      return Colors.blue;
    } else if (extension == '.xls' || extension == '.xlsx') {
      return Colors.green;
    } else if (extension == '.ppt' || extension == '.pptx') {
      return Colors.orange;
    } else if (extension == '.txt') {
      return Colors.grey;
    } else if (extension == '.jpg' ||
        extension == '.jpeg' ||
        extension == '.png' ||
        extension == '.gif') {
      return Colors.purple;
    } else if (extension == '.mp4' ||
        extension == '.avi' ||
        extension == '.mov' ||
        extension == '.wmv') {
      return Colors.red;
    } else if (extension == '.mp3' ||
        extension == '.wav' ||
        extension == '.ogg' ||
        extension == '.m4a') {
      return Colors.blue;
    }

    return Colors.grey;
  }

  Future<void> _showNoFileDialog() async {
    await _dialogService.showDialog(
      title: 'No File Available',
      description: 'This lesson does not have an associated file.',
    );
  }

  void navigateBack() {
    _navigationService.back();
  }
}
