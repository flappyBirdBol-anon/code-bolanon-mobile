import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/models/registration_model.dart';
import 'package:code_bolanon/ui/common/app_colors.dart' show AppColors;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';

import 'course_details_viewmodel.dart';

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class CourseDetailsView extends StackedView<CourseDetailsViewModel> {
  final CourseModel? course;

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
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            final isScrolled = viewModel.manualOverrideEnabled
                ? viewModel.innerBoxIsScrolled
                : innerBoxIsScrolled;
            return [
              SliverAppBar(
                expandedHeight: 260.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: isScrolled ? 4 : 1,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color.fromARGB(255, 105, 92, 92),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  // Show edit icon only if the user is the creator of the course
                  if (viewModel.isCreator)
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Color.fromARGB(255, 105, 92, 92),
                      ),
                      onPressed: () =>
                          viewModel.navigateToEditCourse(context, course!),
                      tooltip: 'Edit Course',
                    ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Color.fromARGB(255, 105, 92, 92),
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.share_outlined,
                      color: Color.fromARGB(255, 105, 92, 92),
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                  title: AnimatedOpacity(
                    opacity: isScrolled ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      course!.title,
                      style: GoogleFonts.figtree(
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
                      Hero(
                        tag: 'course-${course!.id}',
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                      Positioned(
                        bottom: 20,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course!.title,
                              style: GoogleFonts.figtree(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(0, 1),
                                    blurRadius: 3.0,
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
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
                                          color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        viewModel.averageRating.toString(),
                                        style: GoogleFonts.figtree(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${viewModel.reviews.length} Reviews',
                                  style: GoogleFonts.figtree(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Course Title and Buttons
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Course Contents',
                              style: GoogleFonts.figtree(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Action Buttons
                          Row(
                            children: [
                              // Wishlist Button - only show if not registered
                              if (viewModel.showWishlistButton)
                                Container(
                                  height: 48,
                                  width: 48,
                                  decoration: BoxDecoration(
                                    color: viewModel.isInWishlist
                                        ? Colors.red.withOpacity(0.15)
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: viewModel.isInWishlist
                                            ? Colors.red.withOpacity(0.2)
                                            : Colors.grey.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () async {
                                        final result =
                                            await viewModel.toggleWishlist();
                                        if (result != null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                result['message'] ??
                                                    'Error updating wishlist',
                                                style: GoogleFonts.figtree(),
                                              ),
                                              duration:
                                                  const Duration(seconds: 1),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      },
                                      child: AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        transitionBuilder: (child, animation) {
                                          return ScaleTransition(
                                            scale: animation,
                                            child: child,
                                          );
                                        },
                                        child: Icon(
                                          viewModel.isInWishlist
                                              ? Icons.favorite_rounded
                                              : Icons.favorite_border_rounded,
                                          color: viewModel.isInWishlist
                                              ? Colors.red
                                              : Colors.grey[600],
                                          size: 24,
                                          key: ValueKey(viewModel.isInWishlist),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 12),
                              // Register/Enrolled Button
                              if (viewModel.showEnrollButton) ...[
                                Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: viewModel.isRegistered
                                          ? [
                                              Colors.green,
                                              Colors.green.shade600
                                            ]
                                          : [
                                              AppColors.primary,
                                              AppColors.primary.withBlue(255)
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: viewModel.isRegistered
                                            ? Colors.green.withOpacity(0.3)
                                            : AppColors.primary
                                                .withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: viewModel.isRegistered
                                          ? null
                                          : viewModel.showRegistrationDialog,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              viewModel.enrollButtonIcon,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              viewModel.enrollButtonText,
                                              style: GoogleFonts.figtree(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
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
                                  course!.duration.isNotEmpty
                                      ? course!.duration.capitalize()
                                      : 'N/A',
                                  style: GoogleFonts.figtree(
                                      color: Colors.grey[600]),
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
                                  style: GoogleFonts.figtree(
                                      color: Colors.grey[600]),
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
                  TabBar(
                    splashBorderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Lessons'),
                      Tab(text: 'Reviews'),
                    ],
                    labelStyle: GoogleFonts.figtree(),
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
              _buildReviewsTab(viewModel, context),
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
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Summary Card
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About This Course',
                    style: GoogleFonts.figtree(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    course!.description,
                    style: GoogleFonts.figtree(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildKeyMetric(
                          Icons.access_time, course!.duration, 'Duration'),
                      _buildKeyMetric(Icons.bar_chart, course!.level, 'Level'),
                      _buildKeyMetric(Icons.people_outline,
                          '${course!.studentsEnrolled}+', 'Learners'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // What You'll Learn Section
          Text(
            'What You\'ll Learn',
            style: GoogleFonts.figtree(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (course?.learningExpectations.first == '')
            _buildEmptyLearningExpectations()
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: course!.learningExpectations
                  .map((expectation) => _buildLearningPoint(expectation))
                  .toList(),
            ),
          const SizedBox(height: 24),

          // Instructor Section
          Text(
            'Your Instructor',
            style: GoogleFonts.figtree(
              fontSize: 20,
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
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[200],
                    child: ClipOval(
                      child: viewModel.course?.author_image == null
                          ? Icon(Icons.person,
                              size: 30, color: Colors.white.withOpacity(0.7))
                          : viewModel.getProfileImageWidget(
                              fit: BoxFit.cover,
                              placeholder: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              errorWidget: Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course?.author ?? "John Doe",
                          style: GoogleFonts.figtree(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Senior Developer & Instructor',
                          style: GoogleFonts.figtree(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '4.8',
                              style: GoogleFonts.figtree(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(120 reviews)',
                              style: GoogleFonts.figtree(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Requirements Section
          Text(
            'Requirements',
            style: GoogleFonts.figtree(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          if (course?.requirements.first == '')
            _buildEmptyRequirements()
          else
            ...course!.requirements
                .map((requirement) => _buildRequirementItem(requirement))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyLearningExpectations() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 40,
            color: AppColors.primary.withOpacity(0.7),
          ),
          const SizedBox(height: 12),
          Text(
            'Learning outcomes coming soon!',
            textAlign: TextAlign.center,
            style: GoogleFonts.figtree(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The instructor will be adding detailed learning outcomes for this course.',
            textAlign: TextAlign.center,
            style: GoogleFonts.figtree(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRequirements() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 40,
            color: Colors.green.withOpacity(0.7),
          ),
          const SizedBox(height: 12),
          Text(
            'No prerequisites needed!',
            textAlign: TextAlign.center,
            style: GoogleFonts.figtree(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This course is accessible to all learners regardless of prior experience.',
            textAlign: TextAlign.center,
            style: GoogleFonts.figtree(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetric(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.figtree(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.figtree(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLearningPoint(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline,
              size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.figtree(
              color: Colors.grey[800],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.arrow_right, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.figtree(
                fontSize: 15,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsTab(
      CourseDetailsViewModel viewModel, BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.all(16),
      children: [
        // Stats Cards
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 10, bottom: 10, left: 0, right: 0),
                    child: Column(
                      children: [
                        const Icon(Icons.school_outlined,
                            color: AppColors.primary, size: 35),
                        const SizedBox(height: 8),
                        Text(
                          '${viewModel.lessons.length}',
                          style: GoogleFonts.figtree(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Total Lessons',
                          style: GoogleFonts.figtree(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 10, bottom: 10, left: 0, right: 0),
                    child: Column(
                      children: [
                        Icon(Icons.timer_outlined,
                            color: Colors.orange[400], size: 35),
                        const SizedBox(height: 8),
                        Text(
                          viewModel.totalDuration,
                          style: GoogleFonts.figtree(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Duration',
                          style: GoogleFonts.figtree(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Header with Add Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Course Lesson Content',
              style: GoogleFonts.figtree(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (course?.author == viewModel.userName) // Only show for trainers
              if (viewModel.lessons.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () => viewModel.navigateToAddLesson(course!),
                  icon: const Icon(
                    Icons.add,
                    size: 20,
                    color: Colors.white,
                  ),
                  label: Text(
                    'New Lesson',
                    style: GoogleFonts.figtree(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
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

        // Empty state placeholder or lessons list
        if (viewModel.lessons.isEmpty)
          _buildEmptyLessonsPlaceholder(viewModel)
        else
          Column(
            children: [
              // Lessons List
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: Column(
                  children: [
                    for (int i = 0;
                        i < viewModel.lessons.length &&
                            (viewModel.showAllLessons || i < 3);
                        i++)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: _buildLessonItem(i, context, viewModel),
                      ),
                  ],
                ),
              ),

              // View All/Less Button
              if (viewModel.lessons.length > 3)
                TextButton(
                  onPressed: () => viewModel.toggleShowAllLessons(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side:
                          BorderSide(color: AppColors.primary.withOpacity(0.3)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        viewModel.showAllLessons
                            ? 'Show Less'
                            : 'View All Lessons',
                        style: GoogleFonts.figtree(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        viewModel.showAllLessons
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }

  // New widget for empty lessons placeholder
  Widget _buildEmptyLessonsPlaceholder(CourseDetailsViewModel viewModel) {
    final bool isTrainer = course?.author == viewModel.userName;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_lesson_rounded,
              size: 64,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isTrainer ? 'No Lessons Created Yet' : 'No Lessons Available Yet',
            textAlign: TextAlign.center,
            style: GoogleFonts.figtree(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isTrainer
                ? 'Start creating engaging content for your students by adding your first lesson.'
                : 'The instructor hasn\'t added any lessons to this course yet. Check back soon!',
            textAlign: TextAlign.center,
            style: GoogleFonts.figtree(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          if (isTrainer)
            ElevatedButton.icon(
              onPressed: () => viewModel.navigateToAddLesson(course!),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Create First Lesson'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLessonItem(
      int index, BuildContext context, CourseDetailsViewModel viewModel) {
    final lesson = viewModel.lessons[index];
    final isLocked = viewModel.isLearner && !viewModel.isRegistered;
    final isTrainer = course?.author == viewModel.userName;

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
          color: isLocked ? Colors.grey : Colors.black87,
        ),
      ),
      subtitle: Text.rich(
        TextSpan(
          style: GoogleFonts.figtree(color: Colors.grey[600]),
          children: [
            TextSpan(
              text: isLocked
                  ? 'Enroll to access this lesson'
                  : lesson.description.split(' ').take(3).join(' '),
            ),
            if (!isLocked && lesson.description.split(' ').length > 3)
              TextSpan(
                text: '...',
                style: GoogleFonts.figtree(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isTrainer)
            IconButton(
              icon: const Icon(
                Icons.edit,
                size: 20,
                color: AppColors.primary,
              ),
              onPressed: () =>
                  viewModel.navigateToAddLesson(course!, lesson: lesson),
            ),
          IconButton(
            icon: Icon(
              isLocked ? Icons.lock_outline : Icons.arrow_forward_ios,
              size: 16,
              color: isLocked ? Colors.grey[300] : null,
            ),
            onPressed: () => viewModel.navigateToLessonDetails(lesson),
          ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLocked)
                Row(
                  children: [
                    Icon(Icons.lock_outline, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Please enroll in this course to access the full lesson content.',
                        style: GoogleFonts.figtree(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Text(
                  lesson.description,
                  style: GoogleFonts.figtree(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
            ],
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

  Widget _buildReviewsTab(
      CourseDetailsViewModel viewModel, BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.all(16),
      children: [
        // Overall Rating Card
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall Rating',
                          style: GoogleFonts.figtree(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              viewModel.averageRating.toStringAsFixed(1),
                              style: GoogleFonts.figtree(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[700],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'out of 5',
                              style: GoogleFonts.figtree(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < viewModel.averageRating
                              ? Icons.star
                              : (index < viewModel.averageRating + 0.5 &&
                                      index >= viewModel.averageRating
                                  ? Icons.star_half
                                  : Icons.star_border),
                          size: 24,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRatingBar(5, viewModel.ratingDistribution[5] ?? 0,
                        '${((viewModel.ratingDistribution[5] ?? 0) * 100).toInt()}%'),
                    _buildRatingBar(4, viewModel.ratingDistribution[4] ?? 0,
                        '${((viewModel.ratingDistribution[4] ?? 0) * 100).toInt()}%'),
                    _buildRatingBar(3, viewModel.ratingDistribution[3] ?? 0,
                        '${((viewModel.ratingDistribution[3] ?? 0) * 100).toInt()}%'),
                    _buildRatingBar(2, viewModel.ratingDistribution[2] ?? 0,
                        '${((viewModel.ratingDistribution[2] ?? 0) * 100).toInt()}%'),
                    _buildRatingBar(1, viewModel.ratingDistribution[1] ?? 0,
                        '${((viewModel.ratingDistribution[1] ?? 0) * 100).toInt()}%'),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Based on ${viewModel.reviews.length} reviews',
                  style: GoogleFonts.figtree(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Latest Reviews Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Latest Reviews',
              style: GoogleFonts.figtree(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: viewModel.setReviewSortBy,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'latest',
                  child: Text('Sort by Latest'),
                ),
                const PopupMenuItem(
                  value: 'highest',
                  child: Text('Sort by Highest Rating'),
                ),
                const PopupMenuItem(
                  value: 'lowest',
                  child: Text('Sort by Lowest Rating'),
                ),
              ],
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sort, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Sort by ${viewModel.reviewSortBy.capitalize()}',
                      style: GoogleFonts.figtree(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Write Review ExpansionTile (Only for registered learners)
        if (viewModel.canWriteReview)
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ExpansionTile(
              backgroundColor: Colors.white,
              collapsedBackgroundColor: Colors.white,
              title: Text(
                'Write a Review',
                style: GoogleFonts.figtree(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                'Share your experience with other students',
                style: GoogleFonts.figtree(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.rate_review_outlined,
                  color: AppColors.primary,
                ),
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rate this course',
                        style: GoogleFonts.figtree(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            5,
                            (index) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: InkWell(
                                onTap: () => viewModel.setRating(index + 1.0),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    index < viewModel.userRating
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    color: index < viewModel.userRating
                                        ? Colors.amber
                                        : Colors.grey[400],
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: viewModel.reviewController,
                        maxLines: 4,
                        style: GoogleFonts.figtree(
                          fontSize: 15,
                          color: Colors.grey[800],
                        ),
                        decoration: InputDecoration(
                          hintText: 'Share your thoughts about this course...',
                          hintStyle: GoogleFonts.figtree(
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: Text(
                                    'Report Course',
                                    style: GoogleFonts.figtree(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Please provide details about your concerns:',
                                        style: GoogleFonts.figtree(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      TextField(
                                        controller:
                                            viewModel.reportReasonController,
                                        maxLines: 3,
                                        decoration: InputDecoration(
                                          hintText: 'Describe the issue...',
                                          filled: true,
                                          fillColor: Colors.grey[50],
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'Cancel',
                                        style: GoogleFonts.figtree(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        viewModel.submitReport();
                                        // Navigator.pop(context);
                                      },
                                      icon: const Icon(
                                        Icons.flag_outlined,
                                        size: 18,
                                      ),
                                      label: const Text('Submit Report'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.flag_outlined,
                              color: Colors.red[400],
                              size: 20,
                            ),
                            label: Text(
                              'Report Issue',
                              style: GoogleFonts.figtree(
                                color: Colors.red[400],
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: viewModel.submitReview,
                            icon: const Icon(
                              Icons.send_rounded,
                              size: 18,
                            ),
                            label: const Text('Submit Review'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Existing reviews
        if (viewModel.reviews.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No reviews yet',
                    style: GoogleFonts.figtree(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to share your experience!',
                    style: GoogleFonts.figtree(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...viewModel.reviews.map(
              (review) => _buildEnhancedReviewItem(review, viewModel, context)),
      ],
    );
  }

  Widget _buildRatingBar(int rating, double percentage, String label) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              '$rating',
              style: GoogleFonts.figtree(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.star, size: 12, color: Colors.amber),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey[200],
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 40,
                height: 100 * percentage,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.figtree(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedReviewItem(RegistrationModel review,
      CourseDetailsViewModel viewModel, BuildContext context) {
    final isCurrentUserReview = viewModel.isReviewByCurrentUser(review);
    print('Is current user review? $isCurrentUserReview');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[200],
                  child: ClipOval(
                    child: review.userProfilePicture != null
                        ? viewModel.getReviewerImageWidget(
                            review,
                            width: 48,
                            height: 48,
                          )
                        : const Icon(Icons.person,
                            size: 24, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userFullName,
                        style: GoogleFonts.figtree(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        viewModel.formatDate(review.createdAt),
                        style: GoogleFonts.figtree(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      if (review.createdAt != review.updatedAt)
                        Text(
                          '(Edited ${viewModel.formatDate(review.updatedAt)})',
                          style: GoogleFonts.figtree(
                            color: Colors.grey[500],
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (isCurrentUserReview)
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        color: AppColors.primary,
                        onPressed: () {
                          // Pre-fill the review data outside of build
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            viewModel.setRating(review.rating?.toDouble() ?? 0);
                            viewModel.reviewController.text =
                                review.feedback ?? '';

                            showDialog(
                              context: context,
                              builder: (dialogContext) => Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Edit Your Review',
                                        style: GoogleFonts.figtree(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        'Rate this course',
                                        style: GoogleFonts.figtree(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.1),
                                              spreadRadius: 1,
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(
                                            5,
                                            (index) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4),
                                              child: InkWell(
                                                onTap: () => viewModel
                                                    .setRating(index + 1.0),
                                                child: Icon(
                                                  index < viewModel.userRating
                                                      ? Icons.star_rounded
                                                      : Icons
                                                          .star_outline_rounded,
                                                  color: index <
                                                          viewModel.userRating
                                                      ? Colors.amber
                                                      : Colors.grey[400],
                                                  size: 32,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      TextField(
                                        controller: viewModel.reviewController,
                                        maxLines: 4,
                                        style: GoogleFonts.figtree(
                                          fontSize: 15,
                                          color: Colors.grey[800],
                                        ),
                                        decoration: InputDecoration(
                                          hintText:
                                              'Share your updated thoughts...',
                                          hintStyle: GoogleFonts.figtree(
                                            color: Colors.grey[400],
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: AppColors.primary,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(dialogContext),
                                            child: Text(
                                              'Cancel',
                                              style: GoogleFonts.figtree(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              viewModel.updateReview(review);
                                              Navigator.pop(dialogContext);
                                            },
                                            icon: const Icon(
                                              Icons.save_outlined,
                                              size: 18,
                                            ),
                                            label: const Text('Save Changes'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primary,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 12,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                        },
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
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${review.rating}',
                            style: GoogleFonts.figtree(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              review.feedback ?? 'No feedback provided',
              style: GoogleFonts.figtree(
                color: Colors.grey[800],
                fontSize: 14,
                height: 1.5,
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
  void onViewModelReady(CourseDetailsViewModel viewModel) {
    viewModel.initialize(course);
    viewModel.scrollController.addListener(() {
      if (viewModel.manualOverrideEnabled) {
        // Update innerBoxIsScrolled based on scroll position
        viewModel.setInnerBoxIsScrolled(viewModel.scrollController.offset > 0);
      } else {
        viewModel.setInnerBoxIsScrolled(false);
      }
    });
    super.onViewModelReady(viewModel);
  }
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
