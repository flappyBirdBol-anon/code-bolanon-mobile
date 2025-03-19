import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:stacked/stacked.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as path;
import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/lessons_model.dart';
import 'package:code_bolanon/services/file_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart';
import 'package:docx_viewer/docx_viewer.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:shimmer/shimmer.dart';

import 'package:stacked_services/stacked_services.dart';
import 'package:code_bolanon/ui/common/enums/enums.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';

class FileViewer extends StatefulWidget {
  final String fileUrl;
  final String fileType;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final String? title;
  final String? description;
  final Lesson? lesson;
  final File? cachedFile;
  final VoidCallback? onFileOpened;
  final VoidCallback? onFileDownloaded;
  final VoidCallback? onError;

  const FileViewer({
    Key? key,
    required this.fileUrl,
    required this.fileType,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.placeholder,
    this.errorWidget,
    this.title,
    this.description,
    this.lesson,
    this.cachedFile,
    this.onFileOpened,
    this.onFileDownloaded,
    this.onError,
  }) : super(key: key);

  @override
  _FileViewerState createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer>
    with SingleTickerProviderStateMixin {
  final FileService _fileService = locator<FileService>();
  final SnackbarService _snackbarService = locator<SnackbarService>();

  File? _cachedFile;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _isFullScreen = false;
  bool _isDownloading = false;
  String? _downloadProgress;

  // Media controllers

  AudioPlayer? _audioPlayer;
  bool _isAudioPlaying = false;
  Duration _audioPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;

// Stream subscriptions
  StreamSubscription? _audioPositionSubscription;
  StreamSubscription? _audioDurationSubscription;
  StreamSubscription? _audioStateSubscription;
  // Lazy initialization for media players
  Player? _player;
  VideoController? _videoController;

  // Document data
  List<List<dynamic>>? _excelData;

  // Animation controller for transitions
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Add a mounted check flag to prevent setState after dispose
  bool _isMounted = true;

  // Debounce timer for UI updates
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Initialize audio player
    _audioPlayer = AudioPlayer();

    // Listen to player state changes
    _audioStateSubscription = _audioPlayer?.playerStateStream.listen((state) {
      if (_isMounted) {
        setState(() {
          _isAudioPlaying = state.playing;
        });
      }
    });

    // Listen to position changes
    _audioPositionSubscription =
        _audioPlayer?.positionStream.listen((position) {
      if (_isMounted) {
        setState(() {
          _audioPosition = position;
        });
      }
    });

    // Listen to duration changes
    _audioDurationSubscription =
        _audioPlayer?.durationStream.listen((duration) {
      if (_isMounted) {
        setState(() {
          _audioDuration = duration ?? Duration.zero;
        });
      }
    });

    // Use provided cached file if available
    if (widget.cachedFile != null) {
      _cachedFile = widget.cachedFile;
      _initializeContent();
      widget.onFileOpened?.call();
    } else {
      // Load file with a slight delay to allow widget to build
      _loadFile();
    }
  }

  @override
  void didUpdateWidget(FileViewer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the file URL changed, reload the file
    if (oldWidget.fileUrl != widget.fileUrl ||
        oldWidget.cachedFile != widget.cachedFile) {
      _disposeMediaControllers();

      if (widget.cachedFile != null) {
        _cachedFile = widget.cachedFile;
        _initializeContent();
        widget.onFileOpened?.call();
      } else {
        _loadFile();
      }
    }
  }

  void _disposeMediaControllers() {
    _player?.dispose();
    _player = null;
    _videoController = null;

    _audioPositionSubscription?.cancel();
    _audioDurationSubscription?.cancel();
    _audioStateSubscription?.cancel();

    _audioPlayer?.stop();
  }

  void _safeSetState(VoidCallback fn) {
    // Cancel any pending debounce timer
    _debounceTimer?.cancel();

    // Set a new debounce timer
    _debounceTimer = Timer(const Duration(milliseconds: 50), () {
      if (_isMounted) {
        setState(fn);
      }
    });
  }

  Future<void> _initializeContent() async {
    if (!_isMounted) return;

    try {
      if (_cachedFile == null) {
        throw Exception('No cached file available');
      }

      // Initialize media players or parse documents based on file type
      if (widget.fileType.contains('video')) {
        await _initializeVideoPlayer(_cachedFile!.path);
      } else if (widget.fileType.contains('audio')) {
        // Initialize audio source
        try {
          await _audioPlayer?.setFilePath(_cachedFile!.path);
          debugPrint('Audio source set successfully');

          // Get initial duration
          final duration = await _audioPlayer?.duration;
          if (duration != null && _isMounted) {
            setState(() {
              _audioDuration = duration;
            });
          }
        } catch (e) {
          debugPrint('Error setting audio source: $e');
          throw Exception('Failed to load audio file: $e');
        }
      } else if (widget.fileType.contains('spreadsheet') ||
          path.extension(widget.fileUrl).toLowerCase() == '.xlsx' ||
          path.extension(widget.fileUrl).toLowerCase() == '.xls') {
        // Use compute for Excel parsing to avoid UI freezes
        _excelData = await compute(_parseExcelFile, _cachedFile!.path);

        // If parsing failed, create a placeholder
        _excelData ??= [
          ['This Excel file cannot be previewed directly'],
          ['Please use the download button to view it in an Excel application']
        ];
      }

      if (!_isMounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error initializing content: $e');
      if (!_isMounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
      widget.onError?.call();
    }
  }

  Future<void> _loadFile() async {
    if (!_isMounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Check if file URL is valid
      if (widget.fileUrl.isEmpty) {
        throw Exception('Invalid file URL');
      }

      // Get cached file
      final file = await _fileService.getCachedFile(widget.fileUrl);

      if (file == null) {
        // Try to download the file if not cached
        if (widget.lesson != null) {
          try {
            await _fileService.prefetchFile(
              widget.fileUrl,
              lessonId: widget.lesson!.id.toString(),
              fileName: widget.lesson!.fileName,
            );

            // Try to get the cached file again
            final downloadedFile =
                await _fileService.getCachedFile(widget.fileUrl);
            if (downloadedFile == null) {
              throw Exception('File download failed');
            }

            if (!_isMounted) return;
            setState(() {
              _cachedFile = downloadedFile;
            });

            // Notify parent about successful download
            widget.onFileDownloaded?.call();
          } catch (e) {
            throw Exception('File not found in cache and download failed: $e');
          }
        } else {
          throw Exception('File not found in cache');
        }
      } else {
        if (!_isMounted) return;
        setState(() {
          _cachedFile = file;
        });
      }

      await _initializeContent();
      widget.onFileOpened?.call();
    } catch (e) {
      debugPrint('Error loading file: $e');
      if (!_isMounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
      widget.onError?.call();
    }
  }

  // Static method for compute to use
  static List<List<dynamic>>? _parseExcelFile(String filePath) {
    try {
      final file = File(filePath);

      // Check if file exists and has content
      if (!file.existsSync()) {
        debugPrint('Excel file does not exist at path: $filePath');
        return null;
      }

      final fileSize = file.lengthSync();
      if (fileSize == 0) {
        debugPrint('Excel file is empty (0 bytes)');
        return null;
      }

      final bytes = file.readAsBytesSync();
      if (bytes.isEmpty) {
        debugPrint('Excel file bytes are empty');
        return null;
      }

      try {
        final excelFile = Excel.decodeBytes(bytes);
        if (excelFile.tables.isEmpty) {
          return null;
        }

        final firstSheetName = excelFile.tables.keys.first;
        final table = excelFile.tables[firstSheetName];

        if (table == null) {
          return null;
        }

        // Process the rows
        List<List<dynamic>> excelData = [];
        for (var row in table.rows) {
          List<dynamic> rowData = [];
          for (var cell in row) {
            rowData.add(cell?.value ?? '');
          }
          excelData.add(rowData);
        }

        return excelData;
      } catch (e) {
        print('Error parsing Excel: $e');
        return null;
      }
    } catch (e) {
      debugPrint('Error in Excel parsing: $e');
      return null;
    }
  }

  Future<void> _initializeVideoPlayer(String filePath) async {
    try {
      // Lazy initialize the player only when needed
      _player ??= Player();
      _videoController ??= VideoController(_player!);

      // Open the media file
      await _player!.open(Media(filePath));

      if (_isMounted) setState(() {});
    } catch (e) {
      debugPrint('Error initializing video player: $e');
      if (_isMounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Could not initialize video player: $e';
        });
      }
    }
  }

  Future<void> _downloadFile() async {
    if (_cachedFile == null) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 'Preparing download...';
    });

    try {
      final fileName = path.basename(widget.fileUrl);
      final directory = await getExternalStorageDirectory();

      if (directory == null) {
        throw Exception('Could not access external storage');
      }

      final downloadsDir = Directory('${directory.path}/Downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final destinationPath = '${downloadsDir.path}/$fileName';

      // Copy the file
      setState(() {
        _downloadProgress = 'Copying file...';
      });

      // Use compute to perform file copy in a separate isolate
      await compute<Map<String, String>, void>(
        (params) async {
          final source = params['source']!;
          final destination = params['destination']!;
          await File(source).copy(destination);
        },
        {'source': _cachedFile!.path, 'destination': destinationPath},
      );

      setState(() {
        _isDownloading = false;
        _downloadProgress = null;
      });

      // Notify parent about successful download
      widget.onFileDownloaded?.call();

      // Show success message using the SnackbarService
      _snackbarService.showCustomSnackBar(
        variant: SnackbarType.success,
        message: 'File saved to Downloads folder',
        duration: const Duration(seconds: 3),
        mainButtonTitle: 'SHARE',
        onMainButtonTapped: () => Share.shareXFiles([XFile(destinationPath)],
            text: 'Sharing ${widget.title ?? fileName}'),
      );
    } catch (e) {
      debugPrint('Error downloading file: $e');
      setState(() {
        _isDownloading = false;
        _downloadProgress = null;
      });

      // Show error message using the SnackbarService
      _snackbarService.showCustomSnackBar(
        variant: SnackbarType.error,
        message: 'Failed to download file: ${e.toString()}',
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _toggleFullScreen() {
    // Prevent multiple rapid toggles
    if (_animationController.isAnimating) return;

    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      _animationController.forward();
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    // Cancel any pending debounce timer
    _debounceTimer?.cancel();

    // Cancel audio subscriptions
    _audioPositionSubscription?.cancel();
    _audioDurationSubscription?.cancel();
    _audioStateSubscription?.cancel();

    // Dispose audio player
    final playerToDispose = _audioPlayer;
    _audioPlayer = null;
    playerToDispose?.dispose();

    // Dispose media controllers
    _disposeMediaControllers();

    _animationController.dispose();

    // Reset orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _isMounted = false;
    super.dispose();
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(
              _getFileIcon(),
              size: 20,
              color: AppColors.secondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                path.basename(widget.fileUrl),
                style: GoogleFonts.figtree(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        const Divider(height: 24, thickness: 1),
      ],
    );
  }

  IconData _getFileIcon() {
    if (widget.fileType.contains('pdf')) {
      return Icons.picture_as_pdf_rounded;
    } else if (widget.fileType.contains('document')) {
      return Icons.description_rounded;
    } else if (widget.fileType.contains('spreadsheet')) {
      return Icons.table_chart_rounded;
    } else if (widget.fileType.contains('presentation')) {
      return Icons.slideshow_rounded;
    } else if (widget.fileType.contains('image')) {
      return Icons.image_rounded;
    } else if (widget.fileType.contains('video')) {
      return Icons.videocam_rounded;
    } else if (widget.fileType.contains('audio')) {
      return Icons.audiotrack_rounded;
    } else if (widget.fileType.contains('text')) {
      return Icons.text_snippet_rounded;
    } else {
      return Icons.insert_drive_file_rounded;
    }
  }

  Widget _buildFilePreview() {
    if (_isLoading) {
      return _buildShimmerLoading();
    }

    if (_hasError || _cachedFile == null) {
      return _buildErrorWidget();
    }

    // Determine content based on file type
    if (widget.fileType.contains('pdf')) {
      return _buildPdfPreview();
    } else if (widget.fileType.contains('image')) {
      return _buildImagePreview();
    } else if (widget.fileType.contains('video')) {
      return _buildVideoPreview();
    } else if (widget.fileType.contains('audio')) {
      return _buildAudioPreview();
    } else if (widget.fileType.contains('text')) {
      return _buildTextPreview();
    } else if (path.extension(widget.fileUrl).toLowerCase() == '.docx' ||
        path.extension(widget.fileUrl).toLowerCase() == '.doc') {
      return _buildDocxPreview();
    } else if (widget.fileType.contains('spreadsheet') ||
        path.extension(widget.fileUrl).toLowerCase() == '.xlsx' ||
        path.extension(widget.fileUrl).toLowerCase() == '.xls') {
      return _buildExcelPreview();
    } else {
      return _buildGenericFilePreview();
    }
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: widget.width,
        height: widget.height ?? 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildPdfPreview() {
    // First check if file exists and has content
    return FutureBuilder<int>(
      future: _cachedFile!.length(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerLoading();
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == 0) {
          return _buildErrorWidget(message: 'PDF file is empty or corrupted');
        }

        return Column(
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: PDFView(
                    filePath: _cachedFile!.path,
                    enableSwipe: true,
                    swipeHorizontal: false,
                    autoSpacing: true,
                    pageFling: true,
                    pageSnap: true,
                    fitPolicy: FitPolicy.BOTH,
                    preventLinkNavigation: false,
                    onError: (error) {
                      debugPrint('Error rendering PDF: $error');
                      // Force rebuild on error
                      if (_isMounted) {
                        setState(() {
                          _hasError = true;
                          _errorMessage = 'Error rendering PDF: $error';
                        });
                      }
                    },
                    onPageError: (page, error) {
                      debugPrint('Error rendering PDF page $page: $error');
                    },
                    onViewCreated: (controller) {
                      // PDF view created successfully
                      debugPrint('PDF view created successfully');
                    },
                    onRender: (pages) {
                      debugPrint('PDF rendered with $pages pages');
                    },
                    onPageChanged: (page, total) {
                      debugPrint('PDF page changed: $page/$total');
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        );
      },
    );
  }

  Widget _buildDocxPreview() {
    if (_cachedFile == null) {
      return _buildShimmerLoading();
    }

    final oldPath = _cachedFile!.path;
    final newPath = oldPath.endsWith('.docx') ? oldPath : '$oldPath.docx';

    return Column(
      children: [
        Container(
          height: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: DocxView(
              filePath: newPath,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildExcelPreview() {
    if (_excelData == null) {
      return _buildShimmerLoading();
    }

    if (_excelData!.isEmpty) {
      return Center(
        child: Text(
          'No data found in Excel file',
          style: GoogleFonts.figtree(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    // Extract headers from the first row
    final headers = _excelData![0];
    // Data rows (excluding header)
    final rows = _excelData!.length > 1 ? _excelData!.sublist(1) : [];

    return Column(
      children: [
        Container(
          height: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 600,
              fixedLeftColumns: 1,
              headingRowHeight: 50,
              headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
              border: TableBorder(
                horizontalInside: BorderSide(color: Colors.grey[300]!),
              ),
              columns: [
                for (var header in headers)
                  DataColumn2(
                    label: Text(
                      header.toString(),
                      style: GoogleFonts.figtree(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    size: ColumnSize.M,
                  ),
              ],
              rows: [
                for (var row in rows)
                  DataRow2(
                    cells: [
                      for (var cell in row)
                        DataCell(
                          Text(
                            cell.toString(),
                            style: GoogleFonts.figtree(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(
            maxHeight: 300,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _cachedFile!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Error loading image: $error');
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.broken_image,
                          size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'Unable to load image',
                        style: GoogleFonts.figtree(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildVideoPreview() {
    if (_player == null || _videoController == null) {
      return _buildShimmerLoading();
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Video(
                controller: _videoController!,
                controls: AdaptiveVideoControls,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildAudioPreview() {
    if (_audioPlayer == null) {
      return _buildShimmerLoading();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                ),
                child: IconButton(
                  icon: Icon(
                    _isAudioPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 36,
                    color: AppColors.primary,
                  ),
                  onPressed: () async {
                    try {
                      if (_isAudioPlaying) {
                        await _audioPlayer?.pause();
                      } else {
                        await _audioPlayer?.play();
                      }
                    } catch (e) {
                      debugPrint('Error controlling audio: $e');
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title ?? 'Audio File',
                      style: GoogleFonts.figtree(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      path.basename(widget.fileUrl),
                      style: GoogleFonts.figtree(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 14),
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: Colors.grey[300],
                  thumbColor: AppColors.secondary,
                  overlayColor: AppColors.secondary.withOpacity(0.2),
                ),
                child: Slider(
                  value: _audioDuration.inMilliseconds > 0
                      ? (_audioPosition.inMilliseconds.toDouble())
                          .clamp(0, _audioDuration.inMilliseconds.toDouble())
                      : 0.0,
                  min: 0,
                  max: _audioDuration.inMilliseconds > 0
                      ? _audioDuration.inMilliseconds.toDouble()
                      : 1.0,
                  onChanged: (value) {
                    if (_isMounted && _audioDuration.inMilliseconds > 0) {
                      _safeSetState(() {
                        _audioPosition = Duration(milliseconds: value.toInt());
                      });
                    }
                  },
                  onChangeEnd: (value) async {
                    try {
                      if (_audioDuration.inMilliseconds > 0) {
                        final position = Duration(milliseconds: value.toInt());
                        await _audioPlayer?.seek(position);
                      }
                    } catch (e) {
                      debugPrint('Error seeking audio: $e');
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_audioPosition),
                      style: GoogleFonts.figtree(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      _formatDuration(_audioDuration),
                      style: GoogleFonts.figtree(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.replay_10_rounded, color: AppColors.primary),
                onPressed: () async {
                  try {
                    final newPosition =
                        _audioPosition - const Duration(seconds: 10);
                    await _audioPlayer?.seek(
                        newPosition.isNegative ? Duration.zero : newPosition);
                  } catch (e) {
                    debugPrint('Error seeking audio backward: $e');
                  }
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  _isAudioPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_filled_rounded,
                  color: AppColors.primary,
                  size: 48,
                ),
                onPressed: () async {
                  try {
                    if (_isAudioPlaying) {
                      await _audioPlayer?.pause();
                    } else {
                      await _audioPlayer?.play();
                    }
                  } catch (e) {
                    debugPrint('Error controlling audio: $e');
                  }
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.forward_10_rounded, color: AppColors.primary),
                onPressed: () async {
                  try {
                    final newPosition =
                        _audioPosition + const Duration(seconds: 10);
                    await _audioPlayer?.seek(newPosition > _audioDuration
                        ? _audioDuration
                        : newPosition);
                  } catch (e) {
                    debugPrint('Error seeking audio forward: $e');
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  Widget _buildTextPreview() {
    return FutureBuilder<String>(
      future: compute<String, String>(
        (path) => File(path).readAsString(),
        _cachedFile!.path,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerLoading();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorWidget(message: 'Could not read text file');
        }

        final text = snapshot.data!;

        return Column(
          children: [
            Container(
              constraints: const BoxConstraints(
                maxHeight: 300,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Text(
                  text,
                  style: GoogleFonts.figtree(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        );
      },
    );
  }

  Widget _buildGenericFilePreview() {
    final fileExtension = path.extension(widget.fileUrl).toLowerCase();
    Color iconColor;
    IconData iconData;

    if (fileExtension == '.docx' || fileExtension == '.doc') {
      iconColor = Colors.blue[700]!;
      iconData = Icons.description_rounded;
    } else if (fileExtension == '.xlsx' || fileExtension == '.xls') {
      iconColor = Colors.green[700]!;
      iconData = Icons.table_chart_rounded;
    } else if (fileExtension == '.pptx' || fileExtension == '.ppt') {
      iconColor = Colors.orange[700]!;
      iconData = Icons.slideshow_rounded;
    } else {
      iconColor = Colors.grey[700]!;
      iconData = Icons.insert_drive_file_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              size: 40,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            path.basename(widget.fileUrl),
            style: GoogleFonts.figtree(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          _buildDownloadButton(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: _toggleFullScreen,
          icon: const Icon(Icons.fullscreen_rounded),
          label: const Text('Full Screen'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: GoogleFonts.figtree(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildDownloadButton(),
      ],
    );
  }

  Widget _buildDownloadButton() {
    return ElevatedButton.icon(
      onPressed: _isDownloading ? null : _downloadFile,
      icon: _isDownloading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.download_rounded),
      label: Text(_isDownloading ? 'Downloading...' : 'Download'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.figtree(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildErrorWidget({String? message}) {
    return widget.errorWidget ??
        Container(
          width: widget.width,
          height: widget.height ?? 200,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red[400],
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Unable to load file',
                  style: GoogleFonts.figtree(
                    color: Colors.red[400],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    message ?? _errorMessage ?? 'The file could not be loaded',
                    style: GoogleFonts.figtree(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadFile,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: GoogleFonts.figtree(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
  }

  Widget _buildFullScreenContent() {
    return WillPopScope(
      onWillPop: () async {
        if (_isFullScreen) {
          _toggleFullScreen();
          return false;
        }
        return true;
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            color: Colors.white,
            child: Stack(
              children: [
                Center(
                  child: _buildFullScreenFileContent(),
                ),
                Positioned(
                  top: 40,
                  right: 16,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _toggleFullScreen,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFullScreenFileContent() {
    if (_cachedFile == null) {
      return _buildErrorWidget();
    }

    if (widget.fileType.contains('pdf')) {
      return PDFView(
        filePath: _cachedFile!.path,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        pageSnap: true,
        fitPolicy: FitPolicy.BOTH,
      );
    } else if (widget.fileType.contains('image')) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 3.0,
        child: Image.file(
          _cachedFile!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading image in fullscreen: $error');
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.broken_image, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Unable to load image',
                    style: GoogleFonts.figtree(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    } else if (widget.fileType.contains('video') && _videoController != null) {
      return Video(
        controller: _videoController!,
        controls: AdaptiveVideoControls,
      );
    } else if (widget.fileType.contains('audio')) {
      return _buildAudioPreview();
    } else if (path.extension(widget.fileUrl).toLowerCase() == '.docx') {
      final oldPath = _cachedFile!.path;
      final newPath = oldPath.endsWith('.docx') ? oldPath : '$oldPath.docx';
      return DocxView(
        filePath: newPath,
      );
    } else if (widget.fileType.contains('spreadsheet') ||
        path.extension(widget.fileUrl).toLowerCase() == '.xlsx' ||
        path.extension(widget.fileUrl).toLowerCase() == '.xls') {
      if (_excelData == null || _excelData!.isEmpty) {
        return _buildShimmerLoading();
      }

      // Extract headers from the first row
      final headers = _excelData![0];
      // Data rows (excluding header)
      final rows = _excelData!.length > 1 ? _excelData!.sublist(1) : [];

      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 600,
          fixedLeftColumns: 1,
          headingRowHeight: 50,
          headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey[300]!),
          ),
          columns: [
            for (var header in headers)
              DataColumn2(
                label: Text(
                  header.toString(),
                  style: GoogleFonts.figtree(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                size: ColumnSize.M,
              ),
          ],
          rows: [
            for (var row in rows)
              DataRow2(
                cells: [
                  for (var cell in row)
                    DataCell(
                      Text(
                        cell.toString(),
                        style: GoogleFonts.figtree(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      );
    } else if (widget.fileType.contains('text')) {
      return FutureBuilder<String>(
        future: compute<String, String>(
          (path) => File(path).readAsString(),
          _cachedFile!.path,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _buildErrorWidget(message: 'Could not read text file');
          }

          final text = snapshot.data!;

          return Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Text(
                text,
                style: GoogleFonts.figtree(
                  fontSize: 16,
                  height: 1.6,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      );
    } else {
      return _buildGenericFilePreview();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullScreen) {
      return _buildFullScreenContent();
    }

    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildFilePreview(),
        ],
      ),
    );
  }
}

// Extension to help with file type icons
extension LessonFileTypeExtension on Lesson {
  IconData getFileIcon() {
    if (fileName == null || fileName!.isEmpty) {
      return Icons.insert_drive_file;
    }

    final extension = path.extension(fileName!).toLowerCase();

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
}

// Helper widget for lesson content display
class LessonContentViewer extends StatelessWidget {
  final ReactiveValue<String> _filesUrl = ReactiveValue<String>("");
  String get fileUrls => _filesUrl.value;
  set fileUrls(String value) => _filesUrl.value = value;

  final Lesson lesson;
  final String? title;
  final String? description;
  final Function()? onRetry;
  final VoidCallback? onFileOpened;
  final VoidCallback? onFileDownloaded;

  LessonContentViewer({
    Key? key,
    required this.lesson,
    this.title,
    this.description,
    this.onRetry,
    this.onFileOpened,
    this.onFileDownloaded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fileService = locator<FileService>();

    if (!fileService.hasFile(lesson)) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No Content Available',
                style: GoogleFonts.figtree(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This lesson does not have any file content to display.',
                textAlign: TextAlign.center,
                style: GoogleFonts.figtree(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final fileUrl = fileService.getLessonFileUrl(lesson);
    final fileType =
        lesson.fileType ?? fileService.getFileType(lesson.fileName!);

    return FutureBuilder<File?>(
      future: fileService.getCachedFile(fileUrl),
      builder: (context, fileSnapshot) {
        if (fileSnapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerLoading();
        }

        final cachedFile = fileSnapshot.data;

        if (fileSnapshot.hasError || cachedFile == null) {
          return _buildErrorWidget(
            onRetry: onRetry ??
                () {
                  fileService.handleLessonFileCacheUpdate(lesson);
                },
          );
        }

        fileUrls = fileUrl;
        return FileViewer(
          fileUrl: fileUrl,
          fileType: fileType,
          title: title ?? lesson.label,
          description: description ?? lesson.description,
          lesson: lesson,
          cachedFile: cachedFile,
          onFileOpened: onFileOpened,
          onFileDownloaded: onFileDownloaded,
          errorWidget: _buildErrorWidget(
            onRetry: onRetry ??
                () {
                  fileService.handleLessonFileCacheUpdate(lesson);
                },
          ),
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildErrorWidget({Function()? onRetry}) {
    final SnackbarService _snackbarService = locator<SnackbarService>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Content Unavailable',
            style: GoogleFonts.figtree(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There was a problem loading the lesson content. Please try again later.',
            textAlign: TextAlign.center,
            style: GoogleFonts.figtree(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              if (onRetry != null) {
                onRetry();
              } else {
                final fileService = locator<FileService>();
                fileService.handleLessonFileCacheUpdate(lesson);
              }

              _snackbarService.showCustomSnackBar(
                variant: SnackbarType.info,
                message: 'Refreshing content...',
                duration: const Duration(seconds: 2),
              );
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: GoogleFonts.figtree(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
