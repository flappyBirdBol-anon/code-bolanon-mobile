import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/lessons_model.dart';
import 'package:code_bolanon/services/lesson_service.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/ui_helpers.dart';
import 'package:code_bolanon/ui/common/widgets/file_viewer.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: viewModel.isBusy
            ? _buildLoadingState()
            : !viewModel.hasValidLesson
                ? _buildErrorState(context, viewModel)
                : _buildMainContent(context, viewModel),
      ),
      floatingActionButton: viewModel.canPlayFile && !viewModel.isBusy
          ? FloatingActionButton(
              onPressed: viewModel.playLesson,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.play_arrow, color: Colors.white),
              tooltip: 'Play Lesson',
            )
          : null,
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          verticalSpaceMedium,
          Text(
            'Loading lesson content...',
            style: GoogleFonts.figtree(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, LessonDetailsViewModel viewModel) {
    return Column(
      children: [
        _buildAppBar(context, viewModel, title: 'Lesson Details'),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Colors.grey[400],
                ),
                verticalSpaceMedium,
                Text(
                  'No lesson data available',
                  style: GoogleFonts.figtree(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                verticalSpaceSmall,
                Text(
                  'Please try again or select another lesson',
                  style: GoogleFonts.figtree(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                verticalSpaceMedium,
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Go Back',
                    style: GoogleFonts.figtree(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(
      BuildContext context, LessonDetailsViewModel viewModel) {
    return Column(
      children: [
        // Custom App Bar
        _buildAppBar(context, viewModel, title: viewModel.lesson.label),

        // Lesson Description
        if (viewModel.lesson.description.isNotEmpty)
          _buildDescription(viewModel),

        // File Viewer - Main Content
        Expanded(
          child: viewModel.fileService.hasFile(viewModel.lesson)
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LessonContentViewer(
                    lesson: viewModel.lesson,
                  ),
                )
              : _buildNoContentMessage(),
        ),

        // Bottom Action Bar
        _buildBottomActionBar(viewModel),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, LessonDetailsViewModel viewModel,
      {required String title}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: viewModel.navigateBack,
          ),
          horizontalSpaceSmall,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.figtree(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (viewModel.hasValidLesson)
                  Row(
                    children: [
                      viewModel.getFileTypeIconWidget(
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      horizontalSpaceTiny,
                      Text(
                        viewModel.fileSize,
                        style: GoogleFonts.figtree(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (viewModel.hasValidLesson)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
              onSelected: (value) {
                switch (value) {
                  case 'share':
                    viewModel.shareLesson();
                    break;
                  case 'download':
                    viewModel.downloadLesson();
                    break;
                  case 'edit':
                    viewModel.editLesson();
                    break;
                  case 'delete':
                    viewModel.deleteLesson();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share, size: 20),
                      horizontalSpaceSmall,
                      Text('Share'),
                    ],
                  ),
                ),
                if (viewModel.isFileDownloadable)
                  const PopupMenuItem(
                    value: 'download',
                    child: Row(
                      children: [
                        Icon(Icons.download, size: 20),
                        horizontalSpaceSmall,
                        Text('Download'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      horizontalSpaceSmall,
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      horizontalSpaceSmall,
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDescription(LessonDetailsViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: GoogleFonts.figtree(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          verticalSpaceSmall,
          Text(
            viewModel.lesson.description,
            style: GoogleFonts.figtree(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoContentMessage() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16),
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
            verticalSpaceMedium,
            Text(
              'No Content Available',
              style: GoogleFonts.figtree(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            verticalSpaceSmall,
            Text(
              'This lesson does not have any file content to display.',
              textAlign: TextAlign.center,
              style: GoogleFonts.figtree(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(LessonDetailsViewModel viewModel) {
    final hasFile = viewModel.fileService.hasFile(viewModel.lesson);
    final isDownloadable = viewModel.isFileDownloadable;

    if (!hasFile) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Download Button - Only show if file exists and is downloadable
          if (isDownloadable)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: viewModel.isDownloading
                    ? null
                    : (viewModel.isFileCached
                        ? null
                        : viewModel.prefetchLessonFile),
                icon: viewModel.isDownloading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        viewModel.isFileCached
                            ? Icons.check
                            : Icons.download_rounded,
                        size: 20,
                      ),
                label: Text(
                  viewModel.isDownloading
                      ? 'Downloading...'
                      : (viewModel.isFileCached ? 'Downloaded' : 'Download'),
                  style: GoogleFonts.figtree(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: viewModel.isFileCached
                      ? Colors.grey[300]
                      : AppColors.primary,
                  foregroundColor:
                      viewModel.isFileCached ? Colors.grey[700] : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          if (isDownloadable) horizontalSpaceMedium,

          // Open Button - Always show if file exists
          Expanded(
            child: ElevatedButton.icon(
              onPressed: viewModel.isFileLoading ? null : viewModel.openLesson,
              icon: viewModel.isFileLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.open_in_new_rounded, size: 20),
              label: Text(
                viewModel.isFileLoading ? 'Opening...' : 'Open File',
                style: GoogleFonts.figtree(
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  LessonDetailsViewModel viewModelBuilder(BuildContext context) =>
      LessonDetailsViewModel();

  @override
  void onViewModelReady(LessonDetailsViewModel viewModel) =>
      viewModel.initialize(lesson);
}
