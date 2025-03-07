import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:stacked/stacked.dart';
import 'package:chewie/chewie.dart';
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
  ChewieController? _chewieController;
  AudioPlayer? _audioPlayer;
  bool _isAudioPlaying = false;

  Player? _player;
  VideoController? _videoController;

  // Document data
  List<List<dynamic>>? _excelData;

  // Animation controller for transitions
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Theme colors
  final Color primaryColor = const Color(0xFF3F51B5);
  final Color accentColor = const Color(0xFF536DFE);
  final Color backgroundColor = const Color(0xFFF5F5F5);
  final Color textColor = const Color(0xFF212121);
  final Color secondaryTextColor = const Color(0xFF757575);

  // Add a mounted check flag to prevent setState after dispose
  bool _isMounted = true;

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

    // Use provided cached file if available
    if (widget.cachedFile != null) {
      _cachedFile = widget.cachedFile;
      Future.microtask(_initializeContent);
    } else {
      // Load file with a slight delay to allow widget to build
      Future.microtask(_loadFile);
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
      } else {
        _loadFile();
      }
    }
  }

  void _disposeMediaControllers() {
    _videoController = null;
    _player?.dispose();
    _chewieController?.dispose();
    _chewieController = null;

    _audioPlayer?.dispose();
    _audioPlayer = null;
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
        await _initializeAudioPlayer(_cachedFile!.path);
      } else if (widget.fileType.contains('spreadsheet') ||
          path.extension(widget.fileUrl).toLowerCase() == '.xlsx' ||
          path.extension(widget.fileUrl).toLowerCase() == '.xls') {
        await _parseExcelFile(_cachedFile!);
      }

      if (!_isMounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing content: $e');
      if (!_isMounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
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
    } catch (e) {
      print('Error loading file: $e');
      if (!_isMounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _parseExcelFile(File file) async {
    try {
      final oldPath = file.path;
      final newPath = oldPath.endsWith('.xlsx') || oldPath.endsWith('.xls')
          ? oldPath
          : '$oldPath.xlsx';
      file = await file.rename(newPath);

      // First check if the file exists
      if (!await file.exists()) {
        throw Exception('Excel file does not exist');
      }

      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('Excel file is empty (0 bytes)');
      }

      // Read file as bytes
      List<int> bytes;
      try {
        bytes = await file.readAsBytes();
        if (bytes.isEmpty) {
          throw Exception('Bytes list is empty');
        }
      } catch (e) {
        throw Exception('Failed to read Excel file: $e');
      }

      // Use a compute function to parse Excel in a separate isolate
      try {
        final excelFile = Excel.decodeBytes(bytes);

        if (excelFile.tables.isEmpty) {
          throw Exception('Excel file has no sheets');
        }

        final firstSheetName = excelFile.tables.keys.first;
        final table = excelFile.tables[firstSheetName];

        if (table == null) {
          throw Exception('Sheet data is null');
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

        if (_isMounted) {
          setState(() {
            _excelData = excelData;
          });
        }
      } catch (e) {
        print('Error decoding Excel file: $e');
        // Create a placeholder for failed Excel parsing
        List<List<dynamic>> data = [
          ['This Excel file cannot be previewed directly'],
          ['Please use the download button to view it in an Excel application']
        ];

        if (_isMounted) {
          setState(() {
            _excelData = data;
          });
        }
      }
    } catch (e) {
      print('Error parsing Excel file: $e');
      if (_isMounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Could not parse Excel file: $e';
        });
      }
    }
  }

  Future<void> _initializeVideoPlayer(String filePath) async {
    try {
      // Initialize the player
      _player = Player();
      _videoController = VideoController(_player!);

      // Open the media file
      await _player!.open(Media(filePath));

      if (_isMounted) setState(() {});
    } catch (e) {
      print('Error initializing video player: $e');
      if (_isMounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Could not initialize video player: $e';
        });
      }
    }
  }

  Future<void> _initializeAudioPlayer(String filePath) async {
    try {
      _audioPlayer = AudioPlayer();
      await _audioPlayer!.setFilePath(filePath);

      _audioPlayer!.playerStateStream.listen((state) {
        if (_isMounted) {
          setState(() {
            _isAudioPlaying = state.playing;
          });
        }
      });

      if (_isMounted) setState(() {});
    } catch (e) {
      print('Error initializing audio player: $e');
      if (_isMounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Could not initialize audio player: $e';
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

      await _cachedFile!.copy(destinationPath);

      setState(() {
        _isDownloading = false;
        _downloadProgress = null;
      });

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
      print('Error downloading file: $e');
      setState(() {
        _isDownloading = false;
        _downloadProgress = null;
      });

      _snackbarService.showCustomSnackBar(
        variant: SnackbarType.error,
        message: 'Failed to download file: ${e.toString()}',
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _toggleFullScreen() {
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
    _isMounted = false;
    _disposeMediaControllers();
    _animationController.dispose();
    _player?.dispose();

    // Reset orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Row(
          children: [
            Icon(
              _getFileIcon(),
              size: 20,
              color: accentColor,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                path.basename(widget.fileUrl),
                style: GoogleFonts.figtree(
                  fontSize: 14,
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8),
          ],
        ),
        Divider(height: 24, thickness: 1),
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
                  offset: Offset(0, 2),
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
                  print('Error rendering PDF: $error');
                },
                onPageError: (page, error) {
                  print('Error rendering PDF page $page: $error');
                },
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        _buildFullScreenButton(),
      ],
    );
  }

  Widget _buildDocxPreview() {
    if (_cachedFile == null) {
      return _buildShimmerLoading();
    }

    final oldPath = _cachedFile!.path;
    final newPath = oldPath.endsWith('.docx') ? oldPath : oldPath + '.docx';

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
        SizedBox(height: 16),
        _buildFullScreenButton(),
      ],
    );
  }

  Widget _buildExcelPreview() {
    if (_excelData == null || _excelData!.isEmpty) {
      return _buildShimmerLoading();
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
                offset: Offset(0, 2),
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
                        color: textColor,
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
                              color: textColor,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        _buildFullScreenButton(),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        Container(
          constraints: BoxConstraints(
            maxHeight: 300,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _cachedFile!,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: 16),
        _buildFullScreenButton(),
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
                  offset: Offset(0, 2),
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
        SizedBox(height: 16),
        _buildFullScreenButton(),
      ],
    );
  }

  Widget _buildAudioPreview() {
    if (_audioPlayer == null) {
      return _buildShimmerLoading();
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.05),
            accentColor.withOpacity(0.1),
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
                  color: primaryColor.withOpacity(0.1),
                ),
                child: IconButton(
                  icon: Icon(
                    _isAudioPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 36,
                    color: primaryColor,
                  ),
                  onPressed: () {
                    if (_isAudioPlaying) {
                      _audioPlayer?.pause();
                    } else {
                      _audioPlayer?.play();
                    }
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audio File',
                      style: GoogleFonts.figtree(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      path.basename(widget.fileUrl),
                      style: GoogleFonts.figtree(
                        fontSize: 14,
                        color: secondaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          StreamBuilder<Duration>(
            stream: _audioPlayer!.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final duration = _audioPlayer!.duration ?? Duration.zero;

              return Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
                      activeTrackColor: primaryColor,
                      inactiveTrackColor: Colors.grey[300],
                      thumbColor: accentColor,
                      overlayColor: accentColor.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: position.inMilliseconds.toDouble().clamp(
                          0,
                          duration.inMilliseconds.toDouble() > 0
                              ? duration.inMilliseconds.toDouble()
                              : 1),
                      max: duration.inMilliseconds.toDouble() > 0
                          ? duration.inMilliseconds.toDouble()
                          : 1,
                      onChanged: (value) {
                        _audioPlayer
                            ?.seek(Duration(milliseconds: value.toInt()));
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(position),
                          style: GoogleFonts.figtree(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                        Text(
                          _formatDuration(duration),
                          style: GoogleFonts.figtree(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
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
      future: _cachedFile!.readAsString(),
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
              constraints: BoxConstraints(
                maxHeight: 300,
              ),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Text(
                  text,
                  style: GoogleFonts.figtree(
                    fontSize: 14,
                    height: 1.5,
                    color: textColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildFullScreenButton(),
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
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
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
          SizedBox(height: 16),
          Text(
            path.basename(widget.fileUrl),
            style: GoogleFonts.figtree(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _downloadFile,
            icon: Icon(Icons.download_rounded),
            label: Text('Download File'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: GoogleFonts.figtree(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullScreenButton() {
    return ElevatedButton.icon(
      onPressed: _toggleFullScreen,
      icon: Icon(Icons.fullscreen_rounded),
      label: Text('Full Screen View'),
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

  Widget _buildLoadingWidget() {
    return widget.placeholder ?? _buildShimmerLoading();
  }

  Widget _buildErrorWidget({String? message}) {
    return widget.errorWidget ??
        Container(
          width: widget.width,
          height: widget.height ?? 200,
          decoration: BoxDecoration(
            color: backgroundColor,
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
                SizedBox(height: 16),
                Text(
                  'Unable to load file',
                  style: GoogleFonts.figtree(
                    color: Colors.red[400],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    message ?? _errorMessage ?? 'The file could not be loaded',
                    style: GoogleFonts.figtree(
                      color: secondaryTextColor,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadFile,
                  icon: Icon(Icons.refresh_rounded),
                  label: Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    return AnimatedBuilder(
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
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
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
        ),
      );
    } else if (widget.fileType.contains('video') && _videoController != null) {
      return Video(
        controller: _videoController!,
        controls: AdaptiveVideoControls,
      );
    } else if (path.extension(widget.fileUrl).toLowerCase() == '.docx') {
      final oldPath = _cachedFile!.path;
      final newPath = oldPath.endsWith('.docx') ? oldPath : oldPath + '.docx';
      return DocxView(
        filePath: newPath,
      );
    } else if (widget.fileType.contains('spreadsheet') ||
        path.extension(widget.fileUrl).toLowerCase() == '.xlsx' ||
        path.extension(widget.fileUrl).toLowerCase() == '.xls') {
      if (_excelData == null || _excelData!.isEmpty) {
        return _buildShimmerLoading();
      }
      // final oldPath = _cachedFile!.path;
      // final newPath = oldPath.endsWith('.docx') ? oldPath + '.docx' : oldPath ;
      print('Excel Data: $_excelData');
      // Extract headers from the first row
      final headers = _excelData![0];
      // Data rows (excluding header)
      final rows = _excelData!.length > 1 ? _excelData!.sublist(1) : [];

      return Container(
        color: Colors.white,
        padding: EdgeInsets.all(16),
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
                    color: textColor,
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
                          color: textColor,
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
        future: _cachedFile!.readAsString(),
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
            padding: EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Text(
                text,
                style: GoogleFonts.figtree(
                  fontSize: 16,
                  height: 1.6,
                  color: textColor,
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
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
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

  LessonContentViewer({
    Key? key,
    required this.lesson,
    this.title,
    this.description,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fileService = locator<FileService>();

    if (!fileService.hasFile(lesson)) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
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
              SizedBox(height: 16),
              Text(
                'No Content Available',
                style: GoogleFonts.figtree(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
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
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
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
          SizedBox(height: 16),
          Text(
            'Content Unavailable',
            style: GoogleFonts.figtree(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'There was a problem loading the lesson content. Please try again later.',
            textAlign: TextAlign.center,
            style: GoogleFonts.figtree(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16),
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
            icon: Icon(Icons.refresh_rounded),
            label: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3F51B5),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
