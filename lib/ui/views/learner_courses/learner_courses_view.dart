import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/services/registration_service.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/custom_app_bar.dart';
import 'package:code_bolanon/ui/common/widgets/learner_course_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';

import 'learner_courses_viewmodel.dart';

class LearnerCoursesView extends StackedView<LearnerCoursesViewModel> {
  const LearnerCoursesView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LearnerCoursesViewModel viewModel,
    Widget? child,
  ) {
    // Check theme
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen for navigation results from Course Details page
    Future.microtask(() {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null) {
        viewModel.handleNavigationResult(args);
      }
    });

    return WillPopScope(
      onWillPop: () async {
        // Allow default back navigation
        return true;
      },
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0F172A) : AppColors.background,
        appBar: CustomAppBar(
          title: 'My Courses',
          showSearchButton: true,
          showNotificationButton: false,
          onSearchTap: (query) => viewModel.onSearchChanged(query),
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          actions: [
            // Add refresh button to app bar
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: isDark ? Colors.white : Colors.black87,
              ),
              onPressed: () {
                // Show feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Refreshing your courses...'),
                    duration: Duration(seconds: 1),
                  ),
                );
                // Trigger refresh
                viewModel.fetchCourses();
              },
              tooltip: 'Refresh courses',
            ),
          ],
        ),
        body: SafeArea(
          child: Builder(
            builder: (context) {
              if (viewModel.isBusy) {
                return _buildLoadingState(isDark);
              }

              if (viewModel.hasError) {
                return _buildErrorState(viewModel, isDark);
              }

              if (viewModel.courses.isEmpty) {
                return _buildEmptyState(viewModel, isDark);
              }

              return _buildCoursesList(context, viewModel, isDark);
            },
          ),
        ),
      ),
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

  Widget _buildErrorState(LearnerCoursesViewModel viewModel, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 60,
            color: isDark ? Colors.red[300] : Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading courses',
            style: GoogleFonts.figtree(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              viewModel.modelError?.toString() ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: GoogleFonts.figtree(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => viewModel.initialise(),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(LearnerCoursesViewModel viewModel, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.indigo.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school_outlined,
              size: 80,
              color: isDark ? Colors.indigo[300] : AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Courses Yet',
            style: GoogleFonts.figtree(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'You haven\'t enrolled in any courses yet. Explore our catalog to find courses that match your interests!',
              textAlign: TextAlign.center,
              style: GoogleFonts.figtree(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => viewModel.navigateToCourses(),
            icon: const Icon(Icons.explore),
            label: const Text('Explore Courses'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => viewModel.initialise(),
            child: Text(
              'Refresh',
              style: GoogleFonts.figtree(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList(
      BuildContext context, LearnerCoursesViewModel viewModel, bool isDark) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      onRefresh: () async {
        // Show a toast message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Refreshing your courses...'),
            duration: Duration(seconds: 1),
          ),
        );

        // Call the fetchCourses method to refresh data
        await viewModel.fetchCourses();
      },
      child: CustomScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(), // Enable scrolling even when content fits screen
        slivers: [
          // Header Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Continue Learning',
                    style: GoogleFonts.figtree(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your enrolled courses',
                    style: GoogleFonts.figtree(
                      fontSize: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Course List with animations
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final course = viewModel.courses[index];
                  // Calculate progress once
                  final progress = viewModel.computeProgress(course);
                  // Get course tags
                  final tags = viewModel.getCourseTags(course);

                  // Count lessons from the registration data
                  // First check if registration has progress data with total_lessons
                  int actualLessonCount = 0;
                  if (course.registration?.progress != null) {
                    actualLessonCount =
                        course.registration!.progress!.totalLessons;
                  } else if (course.registration?.lessons != null) {
                    // Fallback to the lessons array length
                    actualLessonCount = course.registration!.lessons!.length;
                  } else {
                    // Final fallback to default values
                    actualLessonCount = course.lessonCount ?? course.lessons;
                  }

                  // Only show reviews if they exist and are greater than zero
                  final hasReviews = course.reviews > 0 && course.rating > 0;

                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 30.0,
                      child: FadeInAnimation(
                        child: LearnerCourseCard(
                          id: course.id,
                          title: course.title,
                          description: course.description,
                          thumbnail: course.thumbnail,
                          progress: progress,
                          rating: course.rating,
                          reviews: hasReviews ? course.reviews : null,
                          lessonCount: actualLessonCount,
                          level: course.level,
                          duration: course.duration,
                          tags: tags,
                          onTap: () =>
                              viewModel.navigateToCourseDetails(course),
                          imageService: viewModel.imageService,
                        ),
                      ),
                    ),
                  );
                },
                childCount: viewModel.courses.length,
              ),
            ),
          ),

          // Footer padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  @override
  LearnerCoursesViewModel viewModelBuilder(context) => LearnerCoursesViewModel(
        registrationService: locator<RegistrationService>(),
        courseService: locator<CourseService>(),
        imageService: locator<ImageService>(),
      );

  @override
  void onViewModelReady(LearnerCoursesViewModel viewModel) {
    super.onViewModelReady(viewModel);
    // Always refresh the courses when this view becomes active
    // This ensures we have the latest progress and ratings
    viewModel.fetchCourses();
  }
}
