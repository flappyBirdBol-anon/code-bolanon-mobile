import 'package:code_bolanon/app/app.dialogs.dart' show DialogType;
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/models/lessons_model.dart';
import 'package:code_bolanon/services/lesson_service.dart';
import 'package:code_bolanon/services/file_service.dart';
import 'package:code_bolanon/ui/common/enums/enums.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'dart:io';

class AddLessonViewModel extends BaseViewModel {
//model
  CourseModel? course;

  // Services
  final _navigationService = locator<NavigationService>();
  final _lessonsService = locator<LessonsService>();
  final _snackbarService = locator<SnackbarService>();
  final _dialogService = locator<DialogService>();
  final _fileService = locator<FileService>();

  // Edit mode tracking
  bool _isEditingLesson = false;
  Lesson? _editingLesson;

  bool get isEditMode => _isEditingLesson;

  dynamic get currentArguments {
    if (_isEditingLesson && _editingLesson != null) {
      return _editingLesson;
    }
    final args = _navigationService.currentArguments;
    if (args is AddLessonViewArguments) {
      course = args.course;
      return args.course;
    }
    return args;
  }

  // Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController fileNameController = TextEditingController();

  // File properties
  PlatformFile? _selectedFile;
  PlatformFile? get selectedFile => _selectedFile;
  bool _isLoadingCachedFile = false;
  bool get isLoadingCachedFile => _isLoadingCachedFile;

  // Upload status
  bool _isUploading = false;
  bool get isUploading => _isUploading;

  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;

  String _uploadStatus = '';
  String get uploadStatus => _uploadStatus;

  bool get hasFile => _selectedFile != null;
  bool get isFormValid =>
      titleController.text.isNotEmpty &&
      durationController.text.isNotEmpty &&
      descriptionController.text.isNotEmpty &&
      hasFile;

  Future<void> initialize(CourseModel? courses, [Lesson? initialLesson]) async {
    // Clear any previous state
    _isEditingLesson = false;
    _editingLesson = null;
    clearForm();

    // Handle edit mode if lesson is provided
    if (initialLesson != null) {
      _isEditingLesson = true;
      _editingLesson = initialLesson;

      // Populate form fields
      titleController.text = initialLesson.label;
      descriptionController.text = initialLesson.description;
      durationController.text = initialLesson.duration;

      // Set course from the lesson's courseId if no course provided
      if (courses == null) {
        course = CourseModel(
          id: initialLesson.courseId.toString(),
          title: 'Course', // Placeholder value
          price: 0.0, // Default price
          description: '',
          thumbnail: '', // Required field
        );
      } else {
        course = courses;
      }

      // Load the file from cache if available
      _loadCachedFile(initialLesson);

      // Display edit mode message
      _snackbarService.showCustomSnackBar(
        variant: SnackbarType.info,
        message: 'Editing lesson: ${initialLesson.label}',
        duration: const Duration(seconds: 2),
      );
    } else {
      // Handle new lesson mode
      course = courses;
    }

    notifyListeners();
  }

  // New method to load file from cache
  Future<void> _loadCachedFile(Lesson lesson) async {
    if (lesson.fileName == null || lesson.fileName!.isEmpty) return;

    _isLoadingCachedFile = true;
    _updateProgress(0.1, 'Checking cache...');
    notifyListeners();

    try {
      final fileUrl = _fileService.getLessonFileUrl(lesson);
      final cachedFile = await _fileService.getCachedFile(
        fileUrl,
        fileName: lesson.fileName,
      );

      if (cachedFile != null) {
        // Convert File to PlatformFile
        final fileStats = await cachedFile.stat();
        final String extension = lesson.fileName!.contains('.')
            ? lesson.fileName!.split('.').last
            : '';

        _selectedFile = PlatformFile(
          path: cachedFile.path,
          name: lesson.fileName!,
          size: fileStats.size,
          // Use the extracted extension
          bytes: null,
        );

        print('Cached file loaded: ${cachedFile.path}');
        _updateProgress(1.0, 'File loaded from cache');
      } else {
        print('No cached file found for lesson: ${lesson.id}');

        // If not found in cache, try to download the file
        _updateProgress(0.3, 'File not in cache, downloading...');

        try {
          // Try to prefetch the file
          await _fileService.prefetchFile(
            fileUrl,
            lessonId: lesson.id.toString(),
            fileName: lesson.fileName,
          );

          // Check if we now have the file
          final downloadedFile = await _fileService.getCachedFile(
            fileUrl,
            fileName: lesson.fileName,
          );

          if (downloadedFile != null) {
            // Convert to PlatformFile
            final fileStats = await downloadedFile.stat();
            final String extension = lesson.fileName!.contains('.')
                ? lesson.fileName!.split('.').last
                : '';

            _selectedFile = PlatformFile(
              path: downloadedFile.path,
              name: lesson.fileName!,
              size: fileStats.size,
              bytes: null,
            );

            print('File downloaded and loaded: ${downloadedFile.path}');
            _updateProgress(1.0, 'File downloaded successfully');
          } else {
            _updateProgress(0, 'Could not retrieve file');
            print('Could not download file for lesson: ${lesson.id}');
          }
        } catch (downloadError) {
          print('Error downloading file: $downloadError');
          _updateProgress(0, 'Download failed');
        }
      }
    } catch (e) {
      print('Error loading cached file: $e');
      _updateProgress(0, 'Error loading file');
    } finally {
      _isLoadingCachedFile = false;
      notifyListeners();
    }
  }

  // File handling methods
  void setSelectedFile(PlatformFile file) {
    _selectedFile = file;
    notifyListeners();
  }

  void clearFile() {
    _selectedFile = null;
    notifyListeners();
  }

  void clearForm() {
    titleController.clear();
    durationController.clear();
    descriptionController.clear();
    clearFile();
  }

  // Update upload progress
  void _updateProgress(double progress, String status) {
    _uploadProgress = progress;
    _uploadStatus = status;
    notifyListeners();
  }

  // Main action methods
  Future<void> saveLessonData() async {
    // Validate form
    if (!_validateForm()) {
      return;
    }

    // Skip file validation when editing and no new file selected
    final bool isEditMode =
        _isEditingLesson || _navigationService.currentArguments is Lesson;
    if (_selectedFile == null && !isEditMode) {
      _showErrorSnackbar('Please select a valid file');
      return;
    }

    _isUploading = true;
    _updateProgress(0.1, 'Preparing upload...');
    setBusy(true);

    try {
      // Simulate progress updates (in a real app, you might get this from the API)
      _updateProgress(0.3, 'Processing file...');
      await Future.delayed(const Duration(milliseconds: 300));

      if (isEditMode) {
        // Get the lesson being edited
        final existingLesson = _isEditingLesson && _editingLesson != null
            ? _editingLesson!
            : _navigationService.currentArguments as Lesson;

        // Update existing lesson
        final updatedLesson = await _lessonsService.updateLesson(
          id: existingLesson.id,
          label: titleController.text,
          description: descriptionController.text,
          duration: durationController.text,
          courseId: existingLesson.courseId.toString(),
          filePath: _selectedFile?.path,
          fileName: _selectedFile?.name ?? existingLesson.fileName,
          fileType: _selectedFile != null
              ? _getFileType(_selectedFile!.extension)
              : existingLesson.fileType,
        );
        _updateProgress(1.0, 'Update complete!');
        await _showSuccessDialog(updatedLesson.label);
      } else {
        // Ensure course is available for creating new lesson
        if (course == null) {
          throw Exception(
              'Cannot create lesson: Course information is missing');
        }

        // Create new lesson
        final lesson = await _lessonsService.createLesson(
          label: titleController.text,
          description: descriptionController.text,
          courseId: int.tryParse(course!.id) ?? 0,
          duration: durationController.text,
          filePath: _selectedFile!.path!,
          fileName: _selectedFile!.name,
          fileType: _getFileType(_selectedFile!.extension),
        );
        _updateProgress(1.0, 'Upload complete!');
        await _showSuccessDialog(lesson.label);
      }

      // Navigate back
      _navigationService.back(result: true);
    } catch (e) {
      _updateProgress(0, 'Failed');
      _showErrorSnackbar('Error saving lesson: ${e.toString()}');
    } finally {
      _isUploading = false;
      setBusy(false);
      notifyListeners();
    }
  }

  // Helper methods
  bool _validateForm() {
    if (titleController.text.isEmpty) {
      _showErrorSnackbar('Please enter a lesson title');
      return false;
    }

    // if (durationController.text.isEmpty) {
    //   _showErrorSnackbar('Please enter a lesson duration');
    //   return false;
    // }

    if (descriptionController.text.isEmpty) {
      _showErrorSnackbar('Please enter a lesson description');
      return false;
    }

    return true;
  }

  String _getFileType(String? extension) {
    if (extension == null) return 'Unknown';

    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'PDF Document';
      case 'doc':
      case 'docx':
        return 'Word Document';
      case 'xls':
      case 'xlsx':
        return 'Excel Spreadsheet';
      case 'txt':
        return 'Text File';
      case 'mp4':
      case 'mov':
      case 'avi':
        return 'Video File';
      case 'mp3':
      case 'wav':
        return 'Audio File';
      case 'ppt':
      case 'pptx':
        return 'Presentation';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return 'Image';
      default:
        return 'Unknown';
    }
  }

  void _showErrorSnackbar(String message) {
    _snackbarService.showCustomSnackBar(
      message: message,
      duration: const Duration(seconds: 3),
      variant: SnackbarType.error,
    );
  }

  Future<void> _showSuccessDialog(String lessonName) async {
    await _dialogService.showCustomDialog(
      variant: DialogType.success,
      title: 'Success',
      description: 'Lesson "$lessonName" saved successfully!',
      mainButtonTitle: 'OK',
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    durationController.dispose();
    descriptionController.dispose();
    fileNameController.dispose();
    super.dispose();
  }
}
