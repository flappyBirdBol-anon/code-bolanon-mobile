import 'dart:async';
import 'dart:io';

import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:code_bolanon/app/app_base_view_model.dart';
import 'package:code_bolanon/models/lessons_model.dart';
import 'package:code_bolanon/services/completed_lesson_service.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/file_service.dart';
import 'package:code_bolanon/services/lesson_service.dart';
import 'package:code_bolanon/services/registration_service.dart';
import 'package:code_bolanon/services/user_service.dart';
import 'package:code_bolanon/ui/common/enums/enums.dart'; // For SnackbarType
import 'package:excel/excel.dart'; // Import excel
import 'package:flutter/foundation.dart'; // Import compute
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart'; // Import just_audio
import 'package:media_kit/media_kit.dart'; // Import media_kit
import 'package:media_kit_video/media_kit_video.dart'; // Import media_kit_video
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart'; // Import path_provider
import 'package:share_plus/share_plus.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart'
    as xlsio; // Import Syncfusion Excel library

import '../../common/widgets/excel_data_source.dart'; // Import the new DataSource

class LessonDetailsViewModel extends AppBaseViewModel {
  final _lessonsService = locator<LessonsService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _snackbarService = locator<SnackbarService>(); // Add SnackbarService
  final _fileService = locator<FileService>();
  final _userService = locator<UserService>();
  final _completedLessonService = locator<CompletedLessonService>();
  final _registrationService =
      locator<RegistrationService>(); // Add RegistrationService

  FileService get fileService => _fileService;

  Lesson? _lesson;

  // --- Lesson State ---
  Lesson get lesson => _lesson ?? _createEmptyLesson();
  bool _hasValidLesson = false;
  bool get hasValidLesson => _hasValidLesson;
  bool _isLessonCompleted = false;
  bool get isLessonCompleted => _isLessonCompleted;
  bool get isLearner => _userService.currentUser?.role == 'learner';
  bool get showCompletionToggle => isLearner;

  ExcelDataSource? _excelDataSource;
  ExcelDataSource? get excelDataSource => _excelDataSource;
  List<String> _excelHeaders =
      []; // Store headers separately for column creation
  List<String> get excelHeaders => _excelHeaders;

  // --- File & Content State ---
  File? _cachedFile;
  File? get cachedFile => _cachedFile;
  String _fileType = 'unknown';
  String get fileType => _fileType;
  bool _contentLoading = true; // Separate loading state for content
  bool get contentLoading => _contentLoading;
  bool _contentHasError = false;
  bool get contentHasError => _contentHasError;
  String? _contentErrorMessage;
  String? get contentErrorMessage => _contentErrorMessage;
  bool _isDownloading = false; // For the download button
  bool get isDownloading => _isDownloading;

  // --- Media Kit (Video) State ---
  Player? _player;
  Player? get player => _player;
  VideoController? _videoController;
  VideoController? get videoController => _videoController;

  // --- Just Audio (Audio) State ---
  AudioPlayer? _audioPlayer;
  AudioPlayer? get audioPlayer => _audioPlayer;
  bool _isAudioPlaying = false;
  bool get isAudioPlaying => _isAudioPlaying;
  Duration _audioPosition = Duration.zero;
  Duration get audioPosition => _audioPosition;
  Duration _audioDuration = Duration.zero;
  Duration get audioDuration => _audioDuration;
  StreamSubscription? _audioPositionSubscription;
  StreamSubscription? _audioDurationSubscription;
  StreamSubscription? _audioStateSubscription;

  // --- Document State ---
  List<List<dynamic>>? _excelData;
  List<List<dynamic>>? get excelData => _excelData;
  String? _textData; // For text files
  String? get textData => _textData;

  // --- UI State ---
  bool _isFullScreen = false;
  bool get isFullScreen => _isFullScreen;

  // --- Initialization & Lifecycle ---

  Lesson _createEmptyLesson() {
    return Lesson(
      id: -1, // Use a distinct ID for empty/error state
      courseId: -1,
      label: 'No Lesson Available',
      description: '',
      fileUrl: '',
      fileType: 'unknown',
      fileName: 'No file',
      duration: '0:00',
    );
  }

  @override
  Future<void> initialize(Lesson? initialLesson) async {
    setBusy(true); // Overall ViewModel busy state
    _contentLoading = true; // Content specific loading state
    _contentHasError = false;
    _contentErrorMessage = null;
    notifyListeners();

    try {
      // 1. Determine the lesson
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
        _handleInvalidLesson();
        return; // Exit early
      }

      // 2. Fetch latest lesson data (optional but good practice)
      final updatedLesson = await _lessonsService.getLesson(_lesson!.id);
      if (updatedLesson != null) {
        _lesson = updatedLesson;
      } else {
        // Handle case where lesson might have been deleted since navigation
        _handleInvalidLesson(message: 'Lesson not found.');
        return;
      }

      // 3. Determine File Type
      _fileType = _lesson!.fileType ??
          _fileService.getFileType(_lesson!.fileName ?? '');

      // 4. Load File Content (if applicable)
      if (_fileService.hasFile(lesson)) {
        await _loadFileAndInitializeContent();
      } else {
        _contentLoading = false; // No content to load
      }

      // 5. Check if lesson is completed (for learners only)
      if (_hasValidLesson && _userService.currentUser != null && isLearner) {
        try {
          _isLessonCompleted =
              await _completedLessonService.isLessonCompleted(lesson.id);
          print("Lesson completion status loaded: $_isLessonCompleted");
        } catch (e) {
          print("Error checking lesson completion status: $e");
          // Don't fail initialization for this
        }
      }
    } catch (e, s) {
      print('Error initializing lesson details: $e\n$s');
      _contentLoading = false;
      _contentHasError = true;
      _contentErrorMessage = 'Failed to initialize lesson: $e';
    } finally {
      setBusy(false); // Overall ViewModel is no longer busy
      notifyListeners(); // Ensure UI reflects final state
    }
  }

  void _handleInvalidLesson({String message = 'No lesson data available'}) {
    _hasValidLesson = false;
    _lesson = _createEmptyLesson();
    _contentLoading = false;
    setBusy(false);
    notifyListeners();
    // Use microtask to show dialog after build cycle
    Future.microtask(() async {
      await _dialogService.showDialog(title: 'Error', description: message);
      // if (_navigationService.canGoBack) {
      _navigationService.back();
      // }
    });
  }

  Future<void> _loadFileAndInitializeContent() async {
    _contentLoading = true;
    _contentHasError = false;
    notifyListeners();

    try {
      final fileUrl = _fileService.getLessonFileUrl(lesson);
      // Get cached file path
      _cachedFile = await _fileService.getCachedFile(fileUrl);

      // If not cached, attempt download (prefetch)
      if (_cachedFile == null) {
        print('File not cached, attempting prefetch for $fileUrl...');
        try {
          await _fileService.prefetchFile(
            fileUrl,
            lessonId: lesson.id.toString(),
            fileName: lesson.fileName,
            // TODO: Add progress callback if FileService supports it
            // onProgress: (progress) {
            //   _downloadProgress = progress;
            //   notifyListeners();
            // },
          );
          _cachedFile = await _fileService.getCachedFile(fileUrl);

          if (_cachedFile == null) {
            throw Exception('File download failed after prefetch attempt.');
          }
          print('Prefetch successful, file cached at: ${_cachedFile?.path}');
          _snackbarService.showSnackbar(message: 'Lesson content downloaded.');
        } catch (e) {
          throw Exception('File not found and download failed: $e');
        }
      }

      // Ensure file exists and has content before proceeding
      if (_cachedFile == null ||
          !await _cachedFile!.exists() ||
          await _cachedFile!.length() == 0) {
        // Attempt to delete the invalid cached file entry if possible
        if (_cachedFile != null) {
          try {
            // await _fileService.deleteCachedFile(fileUrl);
            print("Deleted invalid cached file: ${_cachedFile!.path}");
          } catch (deleteError) {
            print("Failed to delete invalid cached file: $deleteError");
          }
          _cachedFile = null; // Nullify the reference
        }
        throw Exception('Cached file is invalid, empty, or does not exist.');
      }

      // Initialize content based on type
      await _initializeContentForType();

      _contentLoading = false;
      _contentHasError = false;
    } catch (e, s) {
      print('Error loading file or initializing content: $e\n$s');
      _contentLoading = false;
      _contentHasError = true;
      _contentErrorMessage = e.toString();
      _disposeMediaControllers(); // Clean up any partially initialized players
    } finally {
      notifyListeners();
    }
  }

  Future<void> _initializeContentForType() async {
    // Dispose previous controllers first
    _disposeMediaControllers();
    _excelDataSource = null; // Reset excel data on re-initialization
    _excelHeaders = [];
    _textData = null; // Reset text data

    if (_cachedFile == null) return;
    final filePath = _cachedFile!.path;

    try {
      print("Initializing content for type: $_fileType, path: $filePath");
      if (_fileType.contains('video')) {
        _player = Player();
        _videoController = VideoController(_player!);
        await _player!.open(Media(filePath));
        print("Video player initialized.");
      } else if (_fileType.contains('audio')) {
        _audioPlayer = AudioPlayer();
        _setupAudioListeners(); // Setup listeners before setting source
        await _audioPlayer!.setFilePath(filePath);
        print("Audio player initialized.");
        // Duration is handled by the stream listener
      } else if (_fileType.contains('spreadsheet') ||
          filePath.toLowerCase().endsWith('.xlsx') ||
          filePath.toLowerCase().endsWith('.xls')) {
        print("Parsing Excel file...");
        // Use compute for potentially slow parsing
        final List<List<dynamic>>? parsedData =
            await compute(_parseExcelWithSyncfusion, filePath);

        if (parsedData != null && parsedData.isNotEmpty) {
          _excelDataSource = ExcelDataSource(excelData: parsedData);
          _excelHeaders =
              _excelDataSource!.headers; // Get headers from DataSource
          print(
              "Excel parsing successful, ${_excelDataSource!.rows.length} data rows found.");
        } else {
          print("Excel parsing returned null or empty data.");
          // Set error state or provide fallback
          _contentHasError = true;
          _contentErrorMessage = 'Could not read data from Excel file.';
          // Optionally create an empty DataSource or one with an error message
          _excelDataSource = ExcelDataSource(excelData: [
            ['Error'],
            ['Could not read file data']
          ]);
          _excelHeaders = _excelDataSource!.headers;
        }
        if (_excelData == null) {
          print("Excel parsing returned null.");
          // Provide fallback data if parsing fails or file is empty
          _excelData = [
            ['Preview Error'],
            ['Could not parse Excel file data.']
          ];
          // Consider setting _contentHasError = true here as well?
          // _contentHasError = true;
          // _contentErrorMessage = 'Could not parse Excel file data.';
        } else {
          print("Excel parsing successful, ${_excelData!.length} rows found.");
        }
      } else if (_fileType.contains('text')) {
        print("Reading text file...");
        _textData = await compute<String, String>(
            (path) => File(path).readAsString(), filePath);
        print("Text file read successfully.");
      }
      // PDF and DOCX are handled directly by their respective widgets in the View
      // Image is handled by Image.file in the View
      else {
        print("File type '$_fileType' handled by View widget directly.");
      }
    } catch (e, s) {
      print('Error during specific content initialization: $e\n$s');
      _contentHasError = true;
      _contentErrorMessage = 'Failed to initialize $_fileType content: $e';
      _disposeMediaControllers(); // Clean up again on error
      // Rethrow or handle specific errors if needed
    }
  }

  static Future<List<List<dynamic>>?> _parseExcelWithSyncfusion(
      String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync() || file.lengthSync() == 0) {
        debugPrint('Excel file invalid or empty: $filePath');
        return null;
      }
      final List<int> bytes = await file.readAsBytes();
      // Load the workbook.
      final xlsio.Workbook workbook = xlsio.Workbook();
      // Get the first worksheet.
      // Consider handling multiple sheets or letting user choose if necessary
      if (workbook.worksheets.count == 0) {
        workbook.dispose();
        return null;
      }
      final xlsio.Worksheet sheet = workbook.worksheets[0];

      // Get the last row and column
      final int lastRow = sheet.getLastRow();
      final int lastColumn = sheet.getLastColumn();
      if (lastRow == 0 || lastColumn == 0) {
        workbook.dispose();
        return null;
      }

      List<List<dynamic>> excelData = [];

      // Iterate through rows and columns to extract data.
      // Start from 1 as XlsIO is 1-based index
      for (int row = 1; row <= lastRow; row++) {
        List<dynamic> rowData = [];
        for (int col = 1; col <= lastColumn; col++) {
          // Get cell value - use displayText for formatted value as string
          final dynamic cellValue = sheet.getRangeByIndex(row, col).displayText;
          rowData.add(cellValue ?? ''); // Add empty string for null values
        }
        excelData.add(rowData);
      }

      // Dispose the workbook.
      workbook.dispose();

      return excelData.isNotEmpty ? excelData : null;
    } catch (e, s) {
      debugPrint('Error parsing Excel with Syncfusion in compute: $e\n$s');
      return null; // Return null on any error
    }
  }

  // --- Media Control Methods ---

  void _setupAudioListeners() {
    _audioStateSubscription = _audioPlayer?.playerStateStream.listen((state) {
      _isAudioPlaying = state.playing;
      notifyListeners();
      // Handle completed state: reset position and pause
      if (state.processingState == ProcessingState.completed) {
        _audioPlayer?.seek(Duration.zero);
        _audioPlayer?.pause();
      }
    }, onError: (e) {
      print("Audio Player State Stream Error: $e");
      _contentHasError = true;
      _contentErrorMessage = "Audio playback error: $e";
      notifyListeners();
    });

    _audioPositionSubscription = _audioPlayer?.positionStream.listen((pos) {
      // Throttle updates slightly if needed, but usually fine
      _audioPosition = pos;
      notifyListeners();
    }, onError: (e) {
      print("Audio Player Position Stream Error: $e");
    });

    _audioDurationSubscription = _audioPlayer?.durationStream.listen((dur) {
      _audioDuration = dur ?? Duration.zero;
      notifyListeners();
    }, onError: (e) {
      print("Audio Player Duration Stream Error: $e");
    });
  }

  Future<void> toggleAudioPlayPause() async {
    if (_audioPlayer == null) return;
    try {
      if (_isAudioPlaying) {
        await _audioPlayer!.pause();
      } else {
        // Ensure source is loaded before playing, might be redundant if already set
        // await _audioPlayer.load(); // Usually not needed after setFilePath/setUrl
        await _audioPlayer!.play();
      }
    } catch (e) {
      print("Error playing/pausing audio: $e");
      _snackbarService.showSnackbar(message: "Error controlling audio: $e");
      _contentHasError = true;
      _contentErrorMessage = "Audio playback error: $e";
      notifyListeners();
    }
  }

  Future<void> seekAudio(Duration position) async {
    if (_audioPlayer == null) return;
    try {
      // Ensure position is within bounds
      final clampedPosition = position.isNegative
          ? Duration.zero
          : (position > _audioDuration && _audioDuration > Duration.zero
              ? _audioDuration
              : position);
      await _audioPlayer!.seek(clampedPosition);
    } catch (e) {
      print("Error seeking audio: $e");
      _snackbarService.showSnackbar(message: "Error seeking audio: $e");
    }
  }

  Future<void> seekAudioRelative(Duration offset) async {
    if (_audioPlayer == null || _audioDuration == Duration.zero) return;
    var newPosition = _audioPosition + offset;
    // Clamp position within 0 and duration
    if (newPosition < Duration.zero) newPosition = Duration.zero;
    if (newPosition > _audioDuration) newPosition = _audioDuration;
    await seekAudio(newPosition);
  }

  // --- Document Parsing (Static for compute) ---

  static List<List<dynamic>>? _parseExcelFile(String filePath) {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        debugPrint('Excel file does not exist at path: $filePath');
        return null;
      }
      final fileSize = file.lengthSync();
      if (fileSize == 0) {
        debugPrint('Excel file is empty (0 bytes): $filePath');
        return null;
      }

      final bytes = file.readAsBytesSync();
      if (bytes.isEmpty) {
        debugPrint('Excel file bytes are empty: $filePath');
        return null;
      }

      final excel = Excel.decodeBytes(bytes);
      if (excel.tables.isEmpty) {
        debugPrint('Excel file has no tables: $filePath');
        return null;
      }

      final sheetName = excel.tables.keys.first;
      final table = excel.tables[sheetName];
      if (table == null) {
        debugPrint('Could not access first sheet "$sheetName": $filePath');
        return null;
      }

      List<List<dynamic>> excelData = [];
      int maxColms = table.maxCols; // Get max columns for padding

      for (var row in table.rows) {
        // Ensure all rows have the same number of columns, padding with empty strings
        List<dynamic> rowData = List.filled(maxColms, '');
        for (int i = 0; i < row.length && i < maxColms; i++) {
          rowData[i] = row[i]?.value ?? '';
        }
        excelData.add(rowData);
      }

      // Return null if only header exists or no data rows
      return excelData.length > 1 ? excelData : null;
    } catch (e, s) {
      debugPrint('Error parsing Excel in compute: $e\n$s');
      return null; // Return null on any error
    }
  }

  // --- UI Actions ---

  void toggleFullScreen() {
    _isFullScreen = !_isFullScreen;
    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      // Allow all orientations in fullscreen
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      // Restrict to portrait when not fullscreen
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    notifyListeners();
  }

  Future<void> downloadFile() async {
    if (_cachedFile == null) {
      _snackbarService.showSnackbar(
          message: 'File not available locally for download.');
      // Optionally trigger a download first if needed
      // await retryLoadContent(); // Or a specific download method
      return;
    }
    _isDownloading = true;
    notifyListeners();
    try {
      final fileName = path.basename(_lesson!.fileName ?? 'downloaded_file');
      final downloadsDir = await getDownloadsDirectory(); // More reliable

      if (downloadsDir == null) {
        throw Exception('Could not access downloads directory');
      }

      final destinationPath = path.join(downloadsDir.path, fileName);
      int attempt = 0;
      String finalPath = destinationPath;
      // Handle potential file name conflicts by adding (1), (2), etc.
      while (await File(finalPath).exists() && attempt < 100) {
        attempt++;
        final ext = path.extension(fileName);
        final nameWithoutExt = path.basenameWithoutExtension(fileName);
        finalPath =
            path.join(downloadsDir.path, '$nameWithoutExt ($attempt)$ext');
      }

      if (attempt >= 100) {
        // Extremely unlikely, but prevents infinite loop
        throw Exception('Too many conflicting filenames in Downloads.');
      }

      print('Copying ${_cachedFile!.path} to $finalPath');
      // Use compute for file copy to avoid blocking UI thread
      await compute<Map<String, String>, void>(
        _copyFileCompute,
        {'source': _cachedFile!.path, 'destination': finalPath},
      );
      print('File copy complete.');

      _snackbarService.showCustomSnackBar(
        variant: SnackbarType.success,
        message: 'File saved to Downloads',
        duration: const Duration(seconds: 5),
        mainButtonTitle: 'OPEN',
        onMainButtonTapped: () async {
          final result = await OpenFile.open(finalPath);
          if (result.type != ResultType.done) {
            _snackbarService.showSnackbar(
                message: 'Could not open file: ${result.message}');
          }
        },
      );
    } catch (e) {
      print('Error downloading file: $e');
      _snackbarService.showCustomSnackBar(
        variant: SnackbarType.error,
        message: 'Download failed: ${e.toString()}',
        duration: const Duration(seconds: 4),
      );
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  // Static function for compute (file copy)
  static Future<void> _copyFileCompute(Map<String, String> params) async {
    final sourcePath = params['source']!;
    final destinationPath = params['destination']!;
    // Ensure the source file exists before copying
    final sourceFile = File(sourcePath);
    if (await sourceFile.exists()) {
      await sourceFile.copy(destinationPath);
    } else {
      throw Exception("Source file not found for copying: $sourcePath");
    }
  }

  Future<void> retryLoadContent() async {
    if (!_hasValidLesson) {
      _snackbarService.showSnackbar(message: "Cannot retry: Invalid lesson.");
      return;
    }
    if (!_fileService.hasFile(lesson)) {
      _snackbarService.showSnackbar(
          message: "Cannot retry: Lesson has no associated file.");
      return;
    }

    print("Retrying content load...");
    // Reset error state and trigger loading again
    _contentHasError = false;
    _contentErrorMessage = null;
    _contentLoading = true;
    notifyListeners();
    // Call the loading logic again
    await _loadFileAndInitializeContent();
  }

  // --- Other Actions (Share, Edit, Delete, Completion) ---

  Future<void> shareLesson() async {
    if (!_hasValidLesson) return;
    try {
      String shareText = 'Check out this lesson: ${lesson.label}';
      List<XFile> filesToShare = [];

      // Share the file itself if cached and exists
      if (_cachedFile != null && await _cachedFile!.exists()) {
        filesToShare.add(XFile(_cachedFile!.path, name: lesson.fileName));
        print("Sharing cached file: ${_cachedFile!.path}");
      } else if (lesson.fileUrl != null && lesson.fileUrl!.isNotEmpty) {
        // Fallback to sharing the URL if file not cached locally
        shareText += '\n${lesson.fileUrl}';
        print("Sharing lesson URL: ${lesson.fileUrl}");
      }

      if (filesToShare.isNotEmpty) {
        await Share.shareXFiles(filesToShare, text: shareText);
      } else {
        await Share.share(shareText);
      }
    } catch (e) {
      print("Share failed: $e");
      await _dialogService.showDialog(
        title: 'Share Failed',
        description: 'Could not share the lesson: $e',
      );
    }
  }

  void editLesson() {
    if (!_hasValidLesson || _lesson!.id < 0) return; // Don't edit placeholder
    _navigationService.navigateTo(Routes.addLessonView, arguments: lesson);
  }

  Future<void> deleteLesson() async {
    if (!_hasValidLesson || _lesson!.id < 0) return; // Don't delete placeholder

    final dialogResponse = await _dialogService.showConfirmationDialog(
      title: 'Delete Lesson',
      description:
          'Are you sure you want to delete "${lesson.label}"? This action cannot be undone.',
      confirmationTitle: 'Delete',
      cancelTitle: 'Cancel',
      barrierDismissible: true,
    );

    if (dialogResponse?.confirmed ?? false) {
      setBusy(true);
      try {
        final success = await _lessonsService.deleteLesson(lesson.id);
        if (success) {
          _snackbarService.showSnackbar(
              message: 'Lesson "${lesson.label}" deleted.');
          _navigationService.back(); // Go back after successful deletion
        } else {
          // If service returns false without throwing
          throw Exception('Failed to delete lesson. Please try again.');
        }
      } catch (e) {
        print("Delete failed: $e");
        await _dialogService.showDialog(
          title: 'Error',
          description: 'Failed to delete lesson: $e',
        );
      } finally {
        setBusy(false);
      }
    }
  }

  Future<void> toggleLessonCompletion() async {
    if (!_hasValidLesson || !isLearner) return;

    try {
      setBusy(true);

      print("Toggling completion for lesson ${lesson.id} (${lesson.label})");
      print("Current completion status: $_isLessonCompleted");

      // Toggle the lesson completion using the CompletedLessonService
      final success =
          await _completedLessonService.toggleLessonCompletion(lesson.id);

      if (success) {
        // Update the local state - opposite of current state
        _isLessonCompleted = !_isLessonCompleted;
        print("New completion status: $_isLessonCompleted");

        // Update the current lesson
        _lesson = _lesson!.copyWith(isCompleted: _isLessonCompleted);

        // Refresh all lessons for this course to ensure UI consistency
        if (_lesson?.courseId != null) {
          // First do a full reset to ensure accurate data
          print("Performing full reset of completion data after toggle...");
          await _completedLessonService.resetAndRefreshAllCompletionData();

          // Then fix any potential inversions
          print("Running fix for potential inverted statuses...");
          await _lessonsService
              .fixInvertedCompletionStatus(_lesson!.courseId.toString());

          // Force check this lesson's status again to be sure
          print("Double-checking this lesson's status after fixes...");
          final verifiedStatus = await _completedLessonService
              .forceCheckLessonCompletion(lesson.id);
          print("Verified status for lesson ${lesson.id}: $verifiedStatus");

          // Update if different from what we expect
          if (verifiedStatus != _isLessonCompleted) {
            print(
                "WARNING: Verified status differs from expected! Updating to verified value.");
            _isLessonCompleted = verifiedStatus;
            _lesson = _lesson!.copyWith(isCompleted: verifiedStatus);
          }

          // Update registration progress in the background
          _updateCourseProgress();
        }

        // Snackbar is now shown in the service, no need to show it here
      } else {
        // Only show error here if the service didn't show it
        print("Failed to toggle lesson completion status");
      }
    } catch (e) {
      print('Error toggling lesson completion: $e');
      // Only show error snackbar if it wasn't shown in the service
      if (e.toString().contains('connection') ||
          e.toString().contains('timeout')) {
        _snackbarService.showCustomSnackBar(
          message: 'Network error: Please check your connection',
          variant: SnackbarType.error,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      setBusy(false);
      notifyListeners(); // Make sure UI updates
    }
  }

  // Method to update course progress when a lesson is completed/incompleted
  Future<void> _updateCourseProgress() async {
    try {
      if (_lesson == null) return;

      print("Updating course progress after lesson completion change");

      // Use the new public method to synchronize lesson completion with course progress
      await _completedLessonService.refreshAllCompletionData();
      await _completedLessonService.syncLessonCompletionWithCourseProgress(
          _lesson!.id, _isLessonCompleted);

      print("Course progress data synchronized");

      // Get the course service to update ratings as well
      final courseService = locator<CourseService>();

      // Refresh course data to update ratings and other metrics
      print("Refreshing course data for courseId: ${_lesson!.courseId}");
      await courseService.getCourseById(_lesson!.courseId.toString());
      print("Course data refreshed to reflect new ratings");

      // Set flag to indicate courses should be refreshed when returning
      _shouldRefreshCoursesOnBack = true;
      print("Flag set to refresh courses when returning to courses view");
    } catch (e) {
      print("Error updating course progress: $e");
    }
  }

  // Add a flag to track if courses should be refreshed when navigating back
  bool _shouldRefreshCoursesOnBack = false;

  // --- Navigation ---

  bool handleBackPress() {
    if (_isFullScreen) {
      toggleFullScreen(); // Exit fullscreen first
      return false; // Prevent default back navigation (handled by toggleFullScreen)
    }

    // Check if we should refresh courses on back navigation
    if (_shouldRefreshCoursesOnBack) {
      print(
          "Back navigation with refresh courses flag - returning refresh result");
      _navigationService.back(result: {'refreshCourses': true});
      return false; // We've handled navigation ourselves
    }

    return true; // Allow default back navigation
  }

  // --- Cleanup ---

  void _disposeMediaControllers() {
    print("Disposing media controllers...");
    // Cancel audio subscriptions safely
    _audioPositionSubscription?.cancel();
    _audioDurationSubscription?.cancel();
    _audioStateSubscription?.cancel();
    _audioPositionSubscription = null;
    _audioDurationSubscription = null;
    _audioStateSubscription = null;

    // Dispose audio player safely
    try {
      _audioPlayer?.dispose();
    } catch (e) {
      print("Error disposing audio player: $e");
    }
    _audioPlayer = null;

    // Dispose video player safely
    try {
      // Disposing the Player should handle the VideoController as well
      _player?.dispose();
    } catch (e) {
      print("Error disposing video player: $e");
    }
    _player = null;
    _videoController = null; // Explicitly nullify
    print("Media controllers disposed.");
  }

  @override
  void dispose() {
    print('LessonDetailsViewModel disposing...');
    _disposeMediaControllers();
    _excelDataSource = null; // Clear data source on dispose
    _excelHeaders = [];
    // Reset System UI only if view is closing (not just orientation change)
    // Check if fullscreen is active, if so, reset it.
    if (_isFullScreen) {
      print("Resetting System UI from fullscreen on dispose.");
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    super.dispose();
  }
}
