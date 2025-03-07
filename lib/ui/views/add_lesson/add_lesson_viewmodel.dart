import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/services/lesson_service.dart';
import 'package:code_bolanon/ui/common/enums/enums.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class AddLessonViewModel extends BaseViewModel {
//model
  CourseModel? course;

  // Services
  final _navigationService = locator<NavigationService>();
  final _lessonsService = locator<LessonsService>();
  final _snackbarService = locator<SnackbarService>();
  final _dialogService = locator<DialogService>();

  // Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController fileNameController = TextEditingController();

  // File properties
  PlatformFile? _selectedFile;
  PlatformFile? get selectedFile => _selectedFile;

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

  Future<void> initialize(CourseModel? courses) async {
    final args = _navigationService.currentArguments;

    if (args is CourseModel) {
      print("has course");
      course = args;
    } else if (courses != null) {
      course = courses;
    }
    notifyListeners();
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

    if (_selectedFile == null || _selectedFile!.path == null) {
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

      _updateProgress(0.5, 'Uploading lesson content...');
      await Future.delayed(const Duration(milliseconds: 500));
      print("course id: ${course!.id}");

      // Create the lesson with file upload
      final lesson = await _lessonsService.createLesson(
        label: titleController.text,
        description: descriptionController.text,
        courseId: int.tryParse(course!.id) ?? 0,
        duration: durationController.text,
        filePath: _selectedFile!.path!,
        fileName: _selectedFile!.name,
        fileType: _getFileType(_selectedFile!.extension),
        // fileSize: _selectedFile!.size,
      );

      _updateProgress(1.0, 'Upload complete!');

      // Show success dialog
      await _showSuccessDialog(lesson.label);

      // Navigate back
      _navigationService.back(result: true);
    } catch (e) {
      _updateProgress(0, 'Upload failed');
      _showErrorSnackbar('Error uploading lesson: ${e.toString()}');
    } finally {
      _isUploading = false;
      setBusy(false);
    }
  }

  // Helper methods
  bool _validateForm() {
    if (titleController.text.isEmpty) {
      _showErrorSnackbar('Please enter a lesson title');
      return false;
    }

    if (durationController.text.isEmpty) {
      _showErrorSnackbar('Please enter a lesson duration');
      return false;
    }

    if (descriptionController.text.isEmpty) {
      _showErrorSnackbar('Please enter a lesson description');
      return false;
    }

    if (!hasFile) {
      _showErrorSnackbar('Please select a file');
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
      case 'ppt':
      case 'pptx':
        return 'PowerPoint';
      default:
        return 'Unknown File Type';
    }
  }

  void _showErrorSnackbar(String message) {
    _snackbarService.showCustomSnackBar(
      variant: SnackbarType.info,
      message: message,
      duration: const Duration(seconds: 3),
      title: 'Error',
    );
  }

  Future<void> _showSuccessDialog(String lessonTitle) async {
    await _dialogService.showCustomDialog(
      variant: DialogType.success,
      title: 'Lesson Uploaded Successfully!',
      description:
          'Your lesson "$lessonTitle" has been uploaded and is now available for students.',
      mainButtonTitle: 'Great!',
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
