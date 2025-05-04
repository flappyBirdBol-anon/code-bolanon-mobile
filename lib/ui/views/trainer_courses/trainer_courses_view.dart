import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/courses_list_item.dart';
import 'package:code_bolanon/ui/common/widgets/custom_app_bar.dart';
import 'package:code_bolanon/ui/common/widgets/empty_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';

import 'trainer_courses_viewmodel.dart';

class TrainerCoursesView extends StackedView<TrainerCoursesViewModel> {
  const TrainerCoursesView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    TrainerCoursesViewModel viewModel,
    Widget? child,
  ) {
    // Calculate screen size adaptable values
    final size = MediaQuery.of(context).size;
    final crossAxisCount = size.width < 600
        ? 2
        : size.width < 900
            ? 3
            : 4;
    final aspectRatio = size.width < 600 ? 0.73 : 0.75;
    final padding = size.width < 600 ? 10.0 : 24.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Courses',
        showSearchButton: true,
        showNotificationButton: false,
        onSearchTap: (query) => viewModel.onSearchChanged(query),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      ),
      body: SafeArea(
        child: viewModel.isBusy
            ? _buildLoadingState(isDark)
            : viewModel.courses.isEmpty
                ? _buildEmptyState(context, viewModel, isDark)
                : CustomScrollView(
                    controller: viewModel.scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Header Section with optimized animation
                      SliverToBoxAdapter(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          switchInCurve: Curves.easeOutQuart,
                          switchOutCurve: Curves.easeInQuart,
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, -0.5),
                                end: Offset.zero,
                              ).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: viewModel.showHeader
                              ? _buildHeaderSection(context, viewModel)
                              : const SizedBox.shrink(),
                        ),
                      ),

                      // Course Stats with optimized animation
                      SliverToBoxAdapter(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          child: viewModel.showStats
                              ? _buildStatsSection(context, viewModel)
                              : const SizedBox.shrink(),
                        ),
                      ),

                      // Courses Grid Title
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: padding,
                              top: 16.0,
                              bottom: 8.0,
                              right: padding),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'My Courses',
                                style: GoogleFonts.figtree(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.blueGrey.withOpacity(0.2)
                                      : Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      size: 16,
                                      color: isDark
                                          ? Colors.amber
                                          : AppColors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Interactive',
                                      style: GoogleFonts.figtree(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Colors.amber
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Courses Grid
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: aspectRatio,
                            mainAxisSpacing: 16.0,
                            crossAxisSpacing: 16.0,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final course = viewModel.courses[index];
                              // Only animate the items visible on screen for initial render
                              return AnimationConfiguration.staggeredGrid(
                                position: index,
                                duration: const Duration(
                                    milliseconds: 375), // Reduced duration
                                columnCount: crossAxisCount,
                                child: SlideAnimation(
                                  verticalOffset: 30.0, // Reduced offset
                                  horizontalOffset:
                                      0, // Remove horizontal animation
                                  child: FadeInAnimation(
                                    child: CoursesListItem(
                                      course: course,
                                      onTap: () => viewModel
                                          .navigateToCourseDetails(course),
                                      imageService: viewModel.imageService,
                                      showStatus: true,
                                      showControls: true,
                                      tags: viewModel.getCourseTags(course),
                                      onEditTap: () =>
                                          viewModel.navigateToEditCourse(
                                              context, course),
                                      onToggleTap: () =>
                                          viewModel.toggleCourseStatus(course),
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: viewModel.courses.length,
                          ),
                        ),
                      ),

                      // Add bottom padding
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 80),
                      ),
                    ],
                  ),
      ),
      floatingActionButton: viewModel.courses.isEmpty
          ? null
          : _buildAnimatedFAB(context, viewModel),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            'Loading your courses...',
            style: GoogleFonts.figtree(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, TrainerCoursesViewModel viewModel, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: EmptyStateWidget(
          animationPath: 'assets/lottie/coding_animation.json',
          title: 'Create Your First Course',
          description:
              'Get started with creating your first course and share your knowledge with learners',
          buttonText: 'Create Course',
          onActionPressed: () => viewModel.navigateToAddCourse(context),
          animationSize: 250,
          isDark: isDark,
        ),
      ),
    );
  }

  Widget _buildHeaderSection(
      BuildContext context, TrainerCoursesViewModel viewModel) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [AppColors.primary, Colors.blue.shade700],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 4),
            blurRadius: 15,
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Your Courses',
                  style: GoogleFonts.figtree(
                    fontSize: size.width < 600 ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage and create engaging learning materials',
                  style: GoogleFonts.figtree(
                    fontSize: size.width < 600 ? 14 : 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.laptop_mac,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
      BuildContext context, TrainerCoursesViewModel viewModel) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      child: Row(
        children: [
          // Total Learners Enrolled
          Expanded(
            child: _buildStatItem(
              'Learners Enrolled',
              '${viewModel.getTotalLearnersEnrolled()}',
              Icons.people_outline,
              AppColors.primary,
              cardColor,
              isDark,
            ),
          ),

          _buildStatDivider(isDark),

          // Lessons Created
          Expanded(
            child: _buildStatItem(
              'Lessons Created',
              '${viewModel.getTotalLessonsCreated()}',
              Icons.library_books,
              AppColors.primary,
              cardColor,
              isDark,
            ),
          ),

          _buildStatDivider(isDark),

          // Total Courses
          Expanded(
            child: _buildStatItem(
              'Total Courses',
              '${viewModel.courses.length}',
              Icons.school,
              AppColors.primary,
              cardColor,
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      height: 45,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color:
          isDark ? Colors.grey.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color,
      Color cardColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 3),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.grey.withOpacity(0.1)
              : Colors.grey.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.figtree(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.figtree(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedFAB(
      BuildContext context, TrainerCoursesViewModel viewModel) {
    return Hero(
      tag: 'fab_course',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
          ],
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.secondary],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => viewModel.navigateToAddCourse(context),
            borderRadius: BorderRadius.circular(16),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
    );
  }

  @override
  TrainerCoursesViewModel viewModelBuilder(context) => TrainerCoursesViewModel(
        courseService: locator<CourseService>(),
        imageService: locator<ImageService>(),
      );

  @override
  void onViewModelReady(TrainerCoursesViewModel viewModel) => viewModel.init();
}
