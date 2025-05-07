import 'dart:io'; // Required for File checks and Image.file
import 'package:code_bolanon/models/lessons_model.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/ui_helpers.dart';
import 'package:data_table_2/data_table_2.dart'; // Excel View (DataTable2)
import 'package:docx_viewer/docx_viewer.dart'; // Docx View
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart'; // PDF View
import 'package:google_fonts/google_fonts.dart';
import 'package:media_kit_video/media_kit_video.dart'; // Video View
import 'package:path/path.dart' as path; // For basename, extension
import 'package:shimmer/shimmer.dart'; // For loading state
import 'package:stacked/stacked.dart';
import 'lesson_details_viewmodel.dart';

class LessonDetailsView extends StackedView<LessonDetailsViewModel> {
  final Lesson? lesson;

  const LessonDetailsView({
    Key? key,
    this.lesson,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LessonDetailsViewModel viewModel,
    Widget? child,
  ) {
    // Use WillPopScope to handle back button press, especially for exiting fullscreen
    return WillPopScope(
      onWillPop: () async => viewModel.handleBackPress(),
      child: Scaffold(
        // Conditionally hide AppBar in fullscreen mode
        appBar:
            viewModel.isFullScreen ? null : _buildAppBar(context, viewModel),
        // Change background color in fullscreen for better immersion (especially video/image)
        backgroundColor:
            viewModel.isFullScreen ? Colors.black : Colors.grey[50],
        body: SafeArea(
          // Disable SafeArea padding in fullscreen for true edge-to-edge
          top: !viewModel.isFullScreen,
          bottom: !viewModel.isFullScreen,
          left: !viewModel.isFullScreen,
          right: !viewModel.isFullScreen,
          child: viewModel.isBusy // Check overall ViewModel busy state first
              ? _buildLoadingState("Initializing Lesson...")
              : !viewModel.hasValidLesson
                  ? _buildErrorState(context, viewModel,
                      'Lesson data not available.') // Main error state if lesson is invalid
                  : _buildLessonContent(context, viewModel),
        ),
        // FloatingActionButton removed as controls are integrated or in AppBar/Menu
      ),
    );
  }

  // Builds the AppBar, only shown when not in fullscreen
  PreferredSizeWidget _buildAppBar(
      BuildContext context, LessonDetailsViewModel viewModel) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1, // Subtle elevation
      shadowColor: Colors.black.withOpacity(0.1),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            size: 20, color: AppColors.textPrimary),
        // Use the ViewModel's back handler which exits fullscreen if needed
        onPressed: () => viewModel.handleBackPress()
            ? Navigator.maybePop(context) // Allow pop if not exiting fullscreen
            : null,
        tooltip: 'Back',
      ),
      title: Text(
        viewModel.lesson.label,
        style: GoogleFonts.figtree(
          fontSize: 18,
          fontWeight: FontWeight.w600, // Slightly bolder
          color: AppColors.textPrimary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        // --- Completion Toggle ---
        if (viewModel.showCompletionToggle)
          IconButton(
            icon: Icon(
              viewModel.isLessonCompleted
                  ? Icons.check_circle_rounded // Use rounded variant
                  : Icons.check_circle_outline_rounded,
              color: viewModel.isLessonCompleted
                  ? Colors.green.shade600
                  : Colors.grey.shade500,
              size: 26, // Slightly smaller
            ),
            onPressed: viewModel.toggleLessonCompletion,
            tooltip: viewModel.isLessonCompleted
                ? 'Mark as incomplete'
                : 'Mark as complete',
          ),

        // --- Fullscreen Toggle ---
        // Show only if content exists and can be reasonably viewed fullscreen
        if (viewModel.cachedFile != null &&
            (viewModel.fileType.contains('video') ||
                viewModel.fileType.contains('image') ||
                viewModel.fileType.contains('pdf') ||
                viewModel.fileType.contains('text')))
          IconButton(
            icon: Icon(
              viewModel.isFullScreen
                  ? Icons.fullscreen_exit_rounded
                  : Icons.fullscreen_rounded,
              color: AppColors.textPrimary,
              size: 28,
            ),
            onPressed: viewModel.toggleFullScreen,
            tooltip: viewModel.isFullScreen ? 'Exit Fullscreen' : 'Fullscreen',
          ),

        // --- More Options Menu ---
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
          tooltip: 'More options',
          onSelected: (value) {
            switch (value) {
              case 'delete':
                viewModel.deleteLesson();
                break;
            }
          },
          itemBuilder: (context) => [
            if (!viewModel.isLearner)
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline_rounded,
                      size: 20, color: Colors.red),
                  horizontalSpaceSmall,
                  Text('Delete', style: TextStyle(color: Colors.red))
                ]),
              ),
          ],
        ),
      ],
    );
  }

  // Builds the main content area below the AppBar (or the whole screen in fullscreen)
  Widget _buildLessonContent(
      BuildContext context, LessonDetailsViewModel viewModel) {
    // Normal View: Column with Description (if any) + Content Area
    // Fullscreen View: Just the Content Area, expanded
    return Column(
      children: [
        // --- Description Section (Hidden in Fullscreen) ---
        if (!viewModel.isFullScreen && viewModel.lesson.description.isNotEmpty)
          _buildDescription(viewModel),

        if (viewModel.isFullScreen)
          SizedBox(
            height: viewModel.isFullScreen
                ? MediaQuery.of(context).size.height // Fullscreen height
                : null, // Auto height in normal mode
            width: viewModel.isFullScreen
                ? MediaQuery.of(context).size.width // Fullscreen width
                : null, // Auto width in normal mode
            child: Expanded(
              child: Container(
                // Add margin and rounded corners only when NOT in fullscreen
                margin: viewModel.isFullScreen
                    ? EdgeInsets.zero
                    : const EdgeInsets.fromLTRB(
                        16, 0, 16, 16), // Margin only bottom/sides
                decoration: viewModel.isFullScreen
                    ? const BoxDecoration(
                        color: Colors.black) // Base for fullscreen
                    : BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                // Clip content within rounded corners when not fullscreen
                clipBehavior:
                    viewModel.isFullScreen ? Clip.none : Clip.antiAlias,
                child: _buildFileContentArea(context, viewModel),
              ),
            ),
          ),

        Expanded(
          child: Container(
            // Add margin and rounded corners only when NOT in fullscreen
            margin: viewModel.isFullScreen
                ? EdgeInsets.zero
                : const EdgeInsets.fromLTRB(
                    16, 0, 16, 16), // Margin only bottom/sides
            decoration: viewModel.isFullScreen
                ? const BoxDecoration(
                    color: Colors.black) // Base for fullscreen
                : BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
            // Clip content within rounded corners when not fullscreen
            clipBehavior: viewModel.isFullScreen ? Clip.none : Clip.antiAlias,
            child: _buildFileContentArea(context, viewModel),
          ),
        ),
      ],
    );
  }

  // Determines what to show inside the content area based on ViewModel state
  Widget _buildFileContentArea(
      BuildContext context, LessonDetailsViewModel viewModel) {
    // 1. Handle Loading State
    if (viewModel.contentLoading) {
      return _buildLoadingState("Loading Content...");
    }

    // 2. Handle Content Error State
    if (viewModel.contentHasError) {
      return _buildContentErrorState(viewModel);
    }

    // 3. Handle No File Associated with Lesson
    if (viewModel.cachedFile == null) {
      return _buildNoContentMessage(viewModel);
    }

    // 4. Handle Case Where File Exists but Isn't Cached
    if (viewModel.cachedFile == null) {
      return _buildContentErrorState(viewModel,
          message: "File not downloaded. Please check connection and retry.");
    }

    // --- Render Specific Content Based on File Type ---
    final fileType = viewModel.fileType;
    final cachedFile = viewModel.cachedFile!; // Safe now due to checks above
    Widget contentWidget;

    try {
      if (fileType.contains('pdf')) {
        contentWidget = _buildPdfPreview(context, viewModel, cachedFile.path);
      } else if (fileType.contains('image')) {
        contentWidget = _buildImagePreview(context, viewModel, cachedFile);
      } else if (fileType.contains('video') &&
          viewModel.videoController != null) {
        contentWidget = _buildVideoPreview(context, viewModel);
      } else if (fileType.contains('audio') && viewModel.audioPlayer != null) {
        contentWidget = _buildAudioPreview(context, viewModel);
      } else if (fileType.contains('text') && viewModel.textData != null) {
        contentWidget =
            _buildTextPreview(context, viewModel, viewModel.textData!);
      } else if ((fileType.contains('document') ||
          cachedFile.path.toLowerCase().endsWith('.docx'))) {
        contentWidget = viewModel.isFullScreen
            ? _buildGenericFilePreview(context, viewModel,
                message:
                    "Fullscreen preview unavailable. Exit fullscreen or download.")
            : _buildDocxPreview(context, viewModel, cachedFile.path);
      } else if ((fileType.contains('spreadsheet') ||
              cachedFile.path.toLowerCase().endsWith('.xlsx') ||
              cachedFile.path.toLowerCase().endsWith('.xls')) &&
          viewModel.excelData != null) {
        contentWidget = viewModel.isFullScreen
            ? _buildGenericFilePreview(context, viewModel,
                message:
                    "Fullscreen preview unavailable. Exit fullscreen or download.")
            : _buildExcelPreview(context, viewModel, viewModel.excelData!);
      } else {
        contentWidget = _buildGenericFilePreview(context, viewModel);
      }
    } catch (e, s) {
      print("Error rendering content widget: $e\n$s");
      contentWidget = _buildContentErrorState(viewModel,
          message: "Error displaying content: $e");
    }

    // --- Add Download Button Overlay in Fullscreen (for non-media types) ---
    bool showOverlayButton = viewModel.isFullScreen &&
        !fileType.contains('video') &&
        !fileType.contains('audio');

    if (showOverlayButton) {
      return Stack(
        alignment: Alignment.bottomRight, // Align button to bottom right
        children: [
          Positioned.fill(child: contentWidget), // Content fills the stack
          Padding(
            padding: const EdgeInsets.all(16.0), // Padding for the button
            child: _buildDownloadButton(viewModel, isOverlay: true),
          ),
        ],
      );
    } else {
      // In normal view, wrap non-media content + download button in a Column
      bool showNormalDownloadButton = !viewModel.isFullScreen &&
          !fileType.contains('audio') &&
          !fileType.contains('video');

      if (showNormalDownloadButton) {
        return Column(
          children: [
            Expanded(child: contentWidget), // Content takes available space
            // Padding(
            //   padding:
            //       const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
            //   child: _buildDownloadButton(viewModel),
            // ),
          ],
        );
      }
      // Return just the content widget for Video/Audio (controls included)
      // or if in fullscreen for media types
      return contentWidget;
    }
  }

  // --- Specific Content Rendering Widgets ---

  Widget _buildPdfPreview(
      BuildContext context, LessonDetailsViewModel viewModel, String filePath) {
    return PDFView(
      filePath: filePath,
      enableSwipe: true,
      swipeHorizontal: false, // Vertical scrolling is more common
      autoSpacing: true, // Add spacing between pages
      pageFling: true, // Allow flinging through pages
      pageSnap: true, // Snap pages to view
      fitPolicy: FitPolicy.BOTH, // Fit both width and height
      preventLinkNavigation: false, // Allow links within PDF if needed
      onError: (error) {
        print('PDFView Rendering Error: $error');
        // Update ViewModel state to show error within the content area
        viewModel.retryLoadContent(); // Or set specific PDF error message
      },
      onRender: (pages) {
        print('PDF rendered with $pages pages.');
      },
      onViewCreated: (PDFViewController controller) {
        // Can use controller to jump to pages etc.
      },
      onPageError: (page, error) {
        print('Error rendering PDF page $page: $error');
      },
    );
  }

  Widget _buildImagePreview(
      BuildContext context, LessonDetailsViewModel viewModel, File imageFile) {
    return InteractiveViewer(
      panEnabled: true,
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image.file(
          imageFile,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image file: $error');
            return _buildContentErrorWidget('Unable to display image');
          },
        ),
      ),
    );
  }

  Widget _buildVideoPreview(
      BuildContext context, LessonDetailsViewModel viewModel) {
    // Ensure player and controller are not null (already checked in caller)
    return Video(
      controller: viewModel.videoController!,
      controls: AdaptiveVideoControls, // Use platform-adaptive controls
      // Adjust fit based on fullscreen state for better viewing
      fit: viewModel.isFullScreen ? BoxFit.contain : BoxFit.cover,
      // Optional: Customize controls, background color, etc.
      // Example: Use MaterialVideoControls for consistent look
      // controls: MaterialVideoControls,
    );
  }

  Widget _buildAudioPreview(
      BuildContext context, LessonDetailsViewModel viewModel) {
    final bool isFs = viewModel.isFullScreen; // Shortcut for fullscreen check
    final Color fgColor = isFs ? Colors.white : AppColors.primary;
    final Color bgColor = isFs ? Colors.black.withOpacity(0.85) : Colors.white;
    final Color secondaryColor =
        isFs ? Colors.grey[300]! : AppColors.textSecondary;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isFs ? 8 : 16, vertical: isFs ? 16 : 24),
      color: bgColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // --- Title and Filename (Optional in Fullscreen) ---
          if (!isFs) ...[
            Text(
              viewModel.lesson.label,
              style: GoogleFonts.figtree(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            verticalSpaceSmall,
            Text(
              viewModel.lesson.fileName ?? 'Audio File',
              style: GoogleFonts.figtree(
                  fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            verticalSpaceMedium,
          ],

          // --- Slider ---
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: isFs ? Colors.grey[700] : Colors.grey[300],
              thumbColor: AppColors.secondary,
              overlayColor: AppColors.secondary.withOpacity(0.2),
              trackHeight: 3, // Slightly thinner track
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: (viewModel.audioPosition.inMilliseconds.toDouble()).clamp(
                  0.0,
                  viewModel.audioDuration.inMilliseconds > 0
                      ? viewModel.audioDuration.inMilliseconds.toDouble()
                      : 1.0),
              min: 0.0,
              max: viewModel.audioDuration.inMilliseconds > 0
                  ? viewModel.audioDuration.inMilliseconds.toDouble()
                  : 1.0, // Use 1.0 if duration is 0 to avoid division by zero errors
              onChanged: (value) {
                // Seek directly on change end for better performance
              },
              onChangeEnd: (value) {
                if (viewModel.audioDuration.inMilliseconds > 0) {
                  viewModel.seekAudio(Duration(milliseconds: value.toInt()));
                }
              },
            ),
          ),

          // --- Time Labels ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(viewModel.audioPosition),
                  style:
                      GoogleFonts.figtree(fontSize: 12, color: secondaryColor),
                ),
                Text(
                  _formatDuration(viewModel.audioDuration),
                  style:
                      GoogleFonts.figtree(fontSize: 12, color: secondaryColor),
                ),
              ],
            ),
          ),
          verticalSpaceMedium,

          // --- Playback Controls Row ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rewind Button
              IconButton(
                icon: Icon(Icons.replay_10_rounded, color: fgColor),
                iconSize: 32,
                tooltip: 'Rewind 10 seconds',
                onPressed: () =>
                    viewModel.seekAudioRelative(const Duration(seconds: -10)),
              ),
              horizontalSpaceMedium, // More spacing around main button
              // Play/Pause Button
              IconButton(
                icon: Icon(
                  viewModel.isAudioPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_filled_rounded,
                  color: fgColor,
                  size: 60, // Larger central button
                ),
                tooltip: viewModel.isAudioPlaying ? 'Pause' : 'Play',
                onPressed: viewModel.toggleAudioPlayPause,
              ),
              horizontalSpaceMedium, // More spacing around main button
              // Forward Button
              IconButton(
                icon: Icon(Icons.forward_10_rounded, color: fgColor),
                iconSize: 32,
                tooltip: 'Forward 10 seconds',
                onPressed: () =>
                    viewModel.seekAudioRelative(const Duration(seconds: 10)),
              ),
            ],
          ),
          // --- Download Button (Only in Normal View) ---
          if (!isFs) ...[
            verticalSpaceMedium,
            _buildDownloadButton(viewModel),
          ]
        ],
      ),
    );
  }

  // Helper to format Duration to mm:ss or hh:mm:ss
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  Widget _buildTextPreview(BuildContext context,
      LessonDetailsViewModel viewModel, String textContent) {
    return Container(
      color: viewModel.isFullScreen ? Colors.grey[900] : Colors.white,
      child: SingleChildScrollView(
        padding: viewModel.isFullScreen ? const EdgeInsets.all(16.0) : null,
        child: SelectableText(
          textContent,
          style: GoogleFonts.robotoMono(
            // Use a monospace font for text files
            fontSize: 13,
            height: 1.4,
            color: viewModel.isFullScreen
                ? Colors.grey[300]
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildDocxPreview(
      BuildContext context, LessonDetailsViewModel viewModel, String filePath) {
    // DocxView might need the .docx extension explicitly
    final correctedPath =
        filePath.toLowerCase().endsWith('.docx') ? filePath : '$filePath.docx';

    // Check if the corrected file exists before attempting to view
    final file = File(correctedPath);
    if (!file.existsSync()) {
      // If original path exists, maybe try renaming/copying? Risky.
      // Best to show an error or the generic preview.
      print(
          "Corrected DOCX path does not exist or is inaccessible: $correctedPath");
      // Check if original path exists
      if (File(filePath).existsSync()) {
        return _buildGenericFilePreview(context, viewModel,
            message:
                "Cannot preview file. Try downloading (possible extension issue).");
      } else {
        return _buildGenericFilePreview(context, viewModel,
            message: "Cannot preview file (File not found). Try downloading.");
      }
    }

    // Add a container with background for better visibility
    return Container(
      color: Colors.white, // Ensure white background for DocxView
      child: DocxView(
        filePath: correctedPath,
        // Handle loading/error within DocxView if possible, or wrap in FutureBuilder
      ),
    );
  }

  Widget _buildExcelPreview(BuildContext context,
      LessonDetailsViewModel viewModel, List<List<dynamic>> excelData) {
    if (excelData.isEmpty || excelData[0].isEmpty) {
      return _buildContentErrorWidget(
          'Excel file appears empty or unreadable.');
    }
    // Assume first row is header
    final headers = excelData[0];
    // Ensure rows list is correctly typed
    final List<List<dynamic>> rows =
        excelData.length > 1 ? excelData.sublist(1) : [];

    return Container(
      color: Colors.white, // Ensure white background
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 600, // Enable horizontal scrolling if needed
        headingRowHeight: 48,
        dataRowHeight: 48,
        headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
        border: TableBorder(
          top: BorderSide(color: Colors.grey[300]!),
          bottom: BorderSide(color: Colors.grey[300]!),
          horizontalInside: BorderSide(color: Colors.grey[200]!, width: 0.5),
        ),
        columns: headers
            .map((header) => DataColumn2(
                  label: Text(
                    header?.toString() ?? '',
                    style: GoogleFonts.figtree(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                  size: ColumnSize.M, // Adjust sizing (S, M, L) as needed
                ))
            .toList(),
        rows: rows.map((row) {
          // Ensure each row has the same number of cells as headers, padding if necessary
          List<dynamic> paddedRow = List.from(row);
          if (paddedRow.length < headers.length) {
            paddedRow
                .addAll(List.filled(headers.length - paddedRow.length, ''));
          } else if (paddedRow.length > headers.length) {
            paddedRow = paddedRow.sublist(0, headers.length);
          }
          return DataRow2(
            cells: paddedRow
                .map((cell) => DataCell(Text(
                      cell?.toString() ?? '',
                      style: GoogleFonts.figtree(color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    )))
                .toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGenericFilePreview(
      BuildContext context, LessonDetailsViewModel viewModel,
      {String? message}) {
    final fileExtension =
        path.extension(viewModel.lesson.fileName ?? '').toLowerCase();
    final isFs = viewModel.isFullScreen;
    final Color defaultIconColor = isFs ? Colors.white70 : Colors.grey[700]!;
    final Color textColor = isFs ? Colors.white : AppColors.textPrimary;
    final Color secondaryTextColor =
        isFs ? Colors.white70 : AppColors.textSecondary;

    // Determine icon and color based on extension
    IconData iconData;
    Color iconColor;
    switch (fileExtension) {
      case '.pdf':
        iconData = Icons.picture_as_pdf_rounded;
        iconColor = isFs ? Colors.red.shade300 : Colors.red.shade700;
        break;
      case '.docx':
      case '.doc':
        iconData = Icons.description_rounded;
        iconColor = isFs ? Colors.blue.shade300 : Colors.blue.shade700;
        break;
      case '.xlsx':
      case '.xls':
        iconData = Icons.table_chart_rounded;
        iconColor = isFs ? Colors.green.shade300 : Colors.green.shade700;
        break;
      case '.pptx':
      case '.ppt':
        iconData = Icons.slideshow_rounded;
        iconColor = isFs ? Colors.orange.shade300 : Colors.orange.shade700;
        break;
      case '.txt':
        iconData = Icons.text_snippet_rounded;
        iconColor = isFs ? Colors.grey.shade400 : Colors.grey.shade700;
        break;
      case '.zip':
      case '.rar':
        iconData = Icons.archive_rounded;
        iconColor = isFs ? Colors.brown.shade300 : Colors.brown.shade500;
        break;
      // Add more specific icons as needed
      default:
        iconData = Icons.insert_drive_file_rounded;
        iconColor = defaultIconColor;
    }

    return Container(
      color: isFs ? Colors.grey[850] : Colors.white,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, size: 64, color: iconColor),
            verticalSpaceMedium,
            Text(
              viewModel.lesson.fileName ?? 'File',
              style: GoogleFonts.figtree(
                  fontSize: 18, fontWeight: FontWeight.w500, color: textColor),
              textAlign: TextAlign.center,
              maxLines: 3, // Allow more lines for long names
              overflow: TextOverflow.ellipsis,
            ),
            verticalSpaceSmall,
            Text(
              message ?? 'Preview not available for this file type.',
              style:
                  GoogleFonts.figtree(fontSize: 14, color: secondaryTextColor),
              textAlign: TextAlign.center,
            ),
            verticalSpaceLarge,
            _buildDownloadButton(viewModel), // Always show download for generic
          ],
        ),
      ),
    );
  }

  // --- Common UI Widgets (Loading, Error States, Description) ---

  Widget _buildDescription(LessonDetailsViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, // Keep description background consistent
          border: Border(bottom: BorderSide(color: Colors.grey[200]!))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Description',
              style: GoogleFonts.figtree(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          verticalSpaceSmall,
          SelectableText(
            // Allow selecting description text
            viewModel.lesson.description,
            style: GoogleFonts.figtree(
                fontSize: 14, height: 1.5, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNoContentMessage(LessonDetailsViewModel viewModel) {
    // Shown when the lesson itself has no file associated
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16), // Keep margin for this message box
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insert_drive_file_outlined, // More relevant icon
                size: 48,
                color: Colors.grey),
            verticalSpaceMedium,
            Text('No Content Attached',
                style: GoogleFonts.figtree(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            verticalSpaceSmall,
            Text(
              'This lesson does not have a file or link associated with it.',
              textAlign: TextAlign.center,
              style: GoogleFonts.figtree(fontSize: 14, color: Colors.grey[600]),
            ),
            // Optionally add Edit button if user has permission
            if (!viewModel.isLearner) ...[
              verticalSpaceMedium,
              ElevatedButton.icon(
                onPressed: viewModel.editLesson,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit Lesson'),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8)),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(String message) {
    // Use Shimmer for a nicer loading effect
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 400.0, // Adjust width as needed
              height: 400.0, // Adjust height as needed
              color: AppColors.primary,
              margin: const EdgeInsets.all(16),
            ),
            verticalSpaceMedium,
            Text(
              message,
              style: GoogleFonts.figtree(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Error state for the whole view (e.g., invalid lesson ID passed)
  Widget _buildErrorState(
      BuildContext context, LessonDetailsViewModel viewModel, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 64, color: Colors.redAccent),
            verticalSpaceMedium,
            Text(message,
                textAlign: TextAlign.center,
                style: GoogleFonts.figtree(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            verticalSpaceSmall,
            Text('Please go back and select a valid lesson.',
                textAlign: TextAlign.center,
                style:
                    GoogleFonts.figtree(fontSize: 14, color: Colors.grey[600])),
            verticalSpaceLarge,
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              onPressed: () => Navigator.maybePop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            ),
          ],
        ),
      ),
    );
  }

  // Error state specifically for the content area (e.g., file load/render fail)
  Widget _buildContentErrorState(LessonDetailsViewModel viewModel,
      {String? message}) {
    final isFs = viewModel.isFullScreen;
    final Color errorColor = Colors.red.shade400;
    final Color textColor = isFs ? Colors.white : errorColor;
    final Color secondaryTextColor =
        isFs ? Colors.white70 : AppColors.textSecondary;
    final Color bgColor = isFs ? Colors.grey.shade800 : Colors.grey.shade50;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, color: errorColor, size: 48),
            verticalSpaceMedium,
            Text(
              'Unable to Load Content',
              style: GoogleFonts.figtree(
                  color: textColor, fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            verticalSpaceSmall,
            Text(
              message ??
                  viewModel.contentErrorMessage ??
                  'An unknown error occurred.',
              style:
                  GoogleFonts.figtree(color: secondaryTextColor, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            verticalSpaceMedium,
            // Retry Button
            ElevatedButton.icon(
              onPressed: viewModel.retryLoadContent,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primary.withOpacity(isFs ? 0.7 : 1.0),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
            ),
            verticalSpaceSmall,
            // Always offer download on error, if possible
            if (viewModel.cachedFile != null ||
                viewModel.fileService.hasFile(viewModel.lesson))
              _buildDownloadButton(viewModel),
          ],
        ),
      ),
    );
  }

  // Simple placeholder for content error widgets (e.g., image load fail)
  Widget _buildContentErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey[400]),
          verticalSpaceSmall,
          Text(message,
              style: GoogleFonts.figtree(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // --- Centralized Download Button Widget ---
  Widget _buildDownloadButton(LessonDetailsViewModel viewModel,
      {bool isOverlay = false}) {
    // Button is disabled if file isn't cached (unless we implement direct download)
    final bool canDownload = viewModel.cachedFile != null;
    final VoidCallback? onPressed = (viewModel.isDownloading || !canDownload)
        ? null // Disable if downloading or not cached
        : viewModel.downloadFile;

    // Style differently for overlay vs normal button
    final ButtonStyle style = isOverlay
        ? ElevatedButton.styleFrom(
            backgroundColor: Colors.black.withOpacity(0.65),
            foregroundColor: Colors.white,
            shape: const CircleBorder(), // Circular overlay button
            padding: const EdgeInsets.all(12),
            elevation: 4,
          )
        : ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor:
                Colors.grey.shade400, // Indicate disabled state
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle:
                GoogleFonts.figtree(fontSize: 14, fontWeight: FontWeight.w500),
          );

    // Icon changes based on downloading state
    final Widget icon = viewModel.isDownloading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                    isOverlay ? AppColors.primary : Colors.white)),
          )
        : Icon(
            Icons.download_rounded,
            size: isOverlay ? 24 : 20,
            color: Colors.white,
          );

    if (isOverlay) {
      // Overlay button is just an icon
      return ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: icon,
        // tooltip: canDownload ? 'Download File' : 'File not available locally', // Tooltip doesn't work well on mobile overlay
      );
    } else {
      // Normal button includes text
      return ElevatedButton.icon(
        onPressed: onPressed,
        style: style,
        icon: icon,
        label: Text(viewModel.isDownloading
            ? 'Downloading...'
            : (canDownload ? 'Download' : 'Unavailable')),
      );
    }
  }

  // --- ViewModelBuilder ---

  @override
  LessonDetailsViewModel viewModelBuilder(BuildContext context) =>
      LessonDetailsViewModel();

  @override
  void onViewModelReady(LessonDetailsViewModel viewModel) {
    // Initialize MediaKit if needed (usually done once per app)
    // MediaKit.ensureInitialized(); // Consider doing this in main.dart
    viewModel.initialize(lesson);
  }

  // onDispose is handled by the ViewModel itself now for SystemChrome cleanup
}
