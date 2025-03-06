// lib/ui/views/lessons_full/lessons_full_view.dart
import 'package:code_bolanon/models/lessons_model.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'lessons_full_viewmodel.dart';

class LessonsFullView extends StackedView<LessonsFullViewModel> {
  final int? courseId;

  const LessonsFullView({
    Key? key,
    this.courseId,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LessonsFullViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, viewModel),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCourseInfo(viewModel),
                  verticalSpaceMedium,
                  _buildLessonsHeader(viewModel),
                ],
              ),
            ),
          ),
          _buildLessonsList(viewModel),
          SliverToBoxAdapter(
            child: verticalSpaceLarge,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: viewModel.navigateToAddLesson,
        icon: const Icon(Icons.add),
        label: const Text('Add Lesson'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSliverAppBar(
      BuildContext context, LessonsFullViewModel viewModel) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Course Lessons',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            viewModel.getCourseImageWidget(
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildCourseInfo(LessonsFullViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            viewModel.courseName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          verticalSpaceSmall,
          Row(
            children: [
              _buildInfoChip(
                Icons.timer,
                viewModel.totalDuration,
              ),
              horizontalSpaceSmall,
              _buildInfoChip(
                Icons.video_library,
                '${viewModel.lessons.length} lessons',
              ),
              horizontalSpaceSmall,
              _buildInfoChip(
                Icons.star,
                viewModel.courseRating,
              ),
            ],
          ),
          verticalSpaceSmall,
          Text(
            viewModel.courseDescription,
            style: TextStyle(
              color: Colors.grey[600],
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.textSecondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          horizontalSpaceTiny,
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsHeader(LessonsFullViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'All Lessons',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton.icon(
          onPressed: viewModel.refreshLessons,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Refresh'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildLessonsList(LessonsFullViewModel viewModel) {
    if (viewModel.isBusy) {
      return SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (viewModel.lessons.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.video_library_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              verticalSpaceMedium,
              Text(
                'No lessons available',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              verticalSpaceSmall,
              ElevatedButton(
                onPressed: viewModel.navigateToAddLesson,
                child: const Text('Add Your First Lesson'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final lesson = viewModel.lessons[index];
          return _buildLessonCard(context, lesson, viewModel);
        },
        childCount: viewModel.lessons.length,
      ),
    );
  }

  Widget _buildLessonCard(
    BuildContext context,
    Lesson lesson,
    LessonsFullViewModel viewModel,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => viewModel.navigateToLessonDetails(lesson),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLessonThumbnail(lesson),
                    horizontalSpaceMedium,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson.label,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          verticalSpaceSmall,
                          Row(
                            children: [
                              Icon(
                                Icons.timer,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              horizontalSpaceTiny,
                              Text(
                                lesson.duration,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              horizontalSpaceMedium,
                              Icon(
                                Icons.play_circle_outline,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              horizontalSpaceTiny,
                              Text(
                                'Play',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                      onSelected: (value) {
                        if (value == 'edit') {
                          viewModel.navigateToEditLesson(lesson);
                        } else if (value == 'delete') {
                          viewModel.deleteLesson(lesson);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (lesson.description != null &&
                    lesson.description!.isNotEmpty) ...[
                  verticalSpaceSmall,
                  Text(
                    lesson.description!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                verticalSpaceSmall,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton(
                      'Download',
                      Icons.download,
                      Colors.green,
                      () => viewModel.downloadLesson(lesson),
                    ),
                    horizontalSpaceSmall,
                    _buildActionButton(
                      'Share',
                      Icons.share,
                      Colors.blue,
                      () => viewModel.shareLesson(lesson),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonThumbnail(Lesson lesson) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.textSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // if (lesson.fileType!.contains('video'))
          //   const Icon(
          //     Icons.play_circle_fill,
          //     size: 32,
          //     color: Colors.white,
          //   )
          // else if (lesson.fileType!.contains('audio'))
          //   const Icon(
          //     Icons.audiotrack,
          //     size: 32,
          //     color: Colors.white,
          //   )
          // else if (lesson.fileType!.contains('pdf'))
          //   const Icon(
          //     Icons.picture_as_pdf,
          //     size: 32,
          //     color: Colors.white,
          //   )
          // else
          const Icon(
            Icons.insert_drive_file,
            size: 32,
            color: Colors.white,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            horizontalSpaceTiny,
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  LessonsFullViewModel viewModelBuilder(BuildContext context) =>
      LessonsFullViewModel();

  @override
  void onViewModelReady(LessonsFullViewModel viewModel) =>
      viewModel.initialize(courseId ?? 0);
}
