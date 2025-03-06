import 'package:code_bolanon/models/course.dart';
import 'package:code_bolanon/models/lessons_model.dart';
import 'package:code_bolanon/ui/common/app_colors.dart' show AppColors;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';

import 'course_details_viewmodel.dart';

class CourseDetailsView extends StackedView<CourseDetailsViewModel> {
  final Course? course;

  const CourseDetailsView({
    Key? key,
    this.course,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CourseDetailsViewModel viewModel,
    Widget? child,
  ) {
    if (viewModel.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 240.0,
                floating: true,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: innerBoxIsScrolled ? 4 : 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.black),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 16),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                  title: AnimatedOpacity(
                    opacity: innerBoxIsScrolled ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      course!.title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Course image
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 80, 16, 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: viewModel.getCourseImageWidget(
                          fit: BoxFit.cover,
                          placeholder: Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Gradient overlay for better text visibility
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Course Title and Rating
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              course!.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  course!.rating.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Course Meta Info
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.timer,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  '2 Weeks',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.language,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  'English',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  const TabBar(
                    splashBorderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    tabs: [
                      Tab(text: 'Overview'),
                      Tab(text: 'Lessons'),
                      Tab(text: 'Reviews'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildOverviewTab(viewModel),
              _buildLessonsTab(viewModel, context),
              _buildReviewsTab(viewModel),
            ],
          ),
        ),
        floatingActionButton: viewModel.selectedTabIndex == 1
            ? FloatingActionButton(
                onPressed: () => viewModel.navigateToAddLesson(course!),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  Widget _buildOverviewTab(CourseDetailsViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course!.description,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'Instructor',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.person),
                ),
                title: Text(viewModel.userName),
                subtitle: const Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text('7.2'),
                    SizedBox(width: 8),
                    Text('Reviews (75)'),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Mentor',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.person),
                ),
                title: const Text('Marie'),
                subtitle: const Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text('8.2'),
                    SizedBox(width: 8),
                    Text('Reviews (33)'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // Widget _buildEmptyLessonsState(CourseDetailsViewModel viewModel) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 32),
  //     child: Center(
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Icon(
  //             Icons.video_library_outlined,
  //             size: 64,
  //             color: Colors.grey[400],
  //           ),
  //           const SizedBox(height: 16),
  //           Text(
  //             'No lessons available yet',
  //             style: TextStyle(
  //               fontSize: 18,
  //               color: Colors.grey[600],
  //             ),
  //           ),
  //           const SizedBox(height: 8),
  //           Text(
  //             'Add your first lesson to get started',
  //             style: TextStyle(
  //               color: Colors.grey[500],
  //             ),
  //           ),
  //           const SizedBox(height: 16),
  //           ElevatedButton.icon(
  //             onPressed: () => viewModel.navigateToAddLesson(),
  //             icon: const Icon(Icons.add),
  //             label: const Text('Add First Lesson'),
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: AppColors.primary,
  //               foregroundColor: Colors.white,
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildLessonsTab(
      CourseDetailsViewModel viewModel, BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Lessons',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => viewModel.navigateToAddLesson(course!),
              icon: const Icon(Icons.add, size: 20, color: Colors.white),
              label: const Text('Add Lesson'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              '${viewModel.lessons.length} Lessons',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(width: 16),
            Text(
              viewModel.totalDuration,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Show first 3 lessons or all if less than 3
        for (int i = 0; i < viewModel.lessons.length && i < 3; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildLessonItem(
              i,
              context,
              viewModel,
            ),
          ),

        // View All button
        if (viewModel.lessons.length > 3)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: TextButton(
              onPressed: () => viewModel.navigateToLessonsFullView(),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View All Lessons',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLessonItem(
      int index, BuildContext context, CourseDetailsViewModel viewModel) {
    final lesson = viewModel.lessons[index];
    return ExpansionTile(
      backgroundColor: Colors.white,
      leading: _buildBeautifiedFileIcon(index, viewModel),
      title: Text(
        lesson.label.isNotEmpty
            ? "${lesson.label[0].toUpperCase()}${lesson.label.substring(1)}"
            : "",
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: Colors.black87,
        ),
      ),
      subtitle: lesson.description != null
          ? Text.rich(
              TextSpan(
                style: TextStyle(color: Colors.grey[600]),
                children: [
                  TextSpan(
                    text: lesson.description.split(' ').take(3).join(' '),
                  ),
                  if ((lesson.description.split(' ').length > 3))
                    const TextSpan(
                      text: '...',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            )
          : const Text('No description available'),
      trailing: IconButton(
        icon: const Icon(Icons.arrow_forward_ios, size: 16),
        onPressed: () => viewModel.navigateToLessonDetails(lesson),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            lesson.description ?? '',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBeautifiedFileIcon(int index, CourseDetailsViewModel viewModel) {
    final lesson = viewModel.lessons[index];

    IconData iconData;
    Color backgroundColor;
    Color iconColor = Colors.white;

    // Determine icon and color based on file type
    if (lesson.fileType != null) {
      if (lesson.fileType!.contains('video')) {
        iconData = Icons.play_circle_filled;
        backgroundColor = Colors.red.shade400;
      } else if (lesson.fileType!.contains('audio')) {
        iconData = Icons.headphones;
        backgroundColor = Colors.purple.shade400;
      } else if (lesson.fileType!.contains('pdf')) {
        iconData = Icons.picture_as_pdf;
        backgroundColor = Colors.orange.shade400;
      } else if (lesson.fileType!.contains('doc') ||
          lesson.fileType!.contains('txt')) {
        iconData = Icons.description;
        backgroundColor = Colors.blue.shade400;
      } else if (lesson.fileType!.contains('ppt')) {
        iconData = Icons.slideshow;
        backgroundColor = Colors.deepOrange.shade400;
      } else {
        iconData = Icons.insert_drive_file;
        backgroundColor = Colors.teal.shade400;
      }
    } else {
      // Default case if fileType is null
      iconData = Icons.school;
      backgroundColor = Colors.indigo.shade400;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  Widget _buildReviewsTab(CourseDetailsViewModel viewModel) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Reviews',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Text(
                'Overall Ratings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  course!.rating.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    size: 18,
                    color: index < course!.rating.floor()
                        ? Colors.amber
                        : Colors.grey[300],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          3,
          (index) => _buildReviewItem(),
        ),
      ],
    );
  }

  Widget _buildReviewItem() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.person),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Carla',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '8.2',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lorem Ipsum Dolor Sit Amet, Consectetur Adipiscing Elit. Proin Faucibus, Sem Sed',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  CourseDetailsViewModel viewModelBuilder(BuildContext context) =>
      CourseDetailsViewModel();

  @override
  void onViewModelReady(CourseDetailsViewModel viewModel) =>
      viewModel.initialize(course);
}

// Custom SliverAppBarDelegate for the tab bar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
