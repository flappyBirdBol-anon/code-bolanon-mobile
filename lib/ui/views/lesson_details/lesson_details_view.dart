import 'package:code_bolanon/models/lessons_model.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/ui_helpers.dart';
import 'package:code_bolanon/ui/common/widgets/file_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: viewModel.isBusy
            ? _buildLoadingState()
            : !viewModel.hasValidLesson
                ? _buildErrorState(context, viewModel)
                : _buildContent(context, viewModel),
      ),
      floatingActionButton: viewModel.canPlayFile && !viewModel.isBusy
          ? FloatingActionButton(
              onPressed: viewModel.playLesson,
              backgroundColor: AppColors.primary,
              tooltip: 'Play Lesson',
              child: const Icon(Icons.play_arrow, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildContent(BuildContext context, LessonDetailsViewModel viewModel) {
    final fileType = viewModel.lesson.fileType ??
        viewModel.fileService.getFileType(viewModel.lesson.fileName ?? '');
    final fileUrl = viewModel.fileService.getLessonFileUrl(viewModel.lesson);

    return Column(
      children: [
        _buildNavigationBar(context, viewModel),
        if (viewModel.lesson.description.isNotEmpty)
          _buildDescription(viewModel),
        Expanded(
          child: viewModel.fileService.hasFile(viewModel.lesson)
              ? Container(
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
                  child: FileViewer(
                    fileUrl: fileUrl,
                    fileType: fileType,
                    lesson: viewModel.lesson,
                    onFileOpened: () => viewModel.onFileOpened(),
                    onFileDownloaded: () => viewModel.onFileDownloaded(),
                  ),
                )
              : _buildNoContentMessage(),
        ),
      ],
    );
  }

  Widget _buildNavigationBar(
      BuildContext context, LessonDetailsViewModel viewModel) {
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
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          horizontalSpaceSmall,
          Expanded(
            child: Text(
              viewModel.lesson.label,
              style: GoogleFonts.figtree(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (viewModel.showCompletionToggle)
            IconButton(
              icon: Icon(
                viewModel.isLessonCompleted
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                color: viewModel.isLessonCompleted ? Colors.green : Colors.grey,
                size: 28,
              ),
              onPressed: viewModel.toggleLessonCompletion,
              tooltip: viewModel.isLessonCompleted
                  ? 'Mark as incomplete'
                  : 'Mark as complete',
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onSelected: (value) {
              switch (value) {
                case 'share':
                  viewModel.shareLesson();
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
                    Icon(Icons.delete, size: 20, color: Colors.red),
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
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
        _buildNavigationBar(context, viewModel),
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

  @override
  LessonDetailsViewModel viewModelBuilder(BuildContext context) =>
      LessonDetailsViewModel();

  @override
  void onViewModelReady(LessonDetailsViewModel viewModel) =>
      viewModel.initialize(lesson);
}
